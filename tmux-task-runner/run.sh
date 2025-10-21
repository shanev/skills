#!/bin/bash
# Tmux Task Runner - Execute commands in managed tmux sessions
# Usage: ./run.sh <task-type> <command...>

set -e

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is not installed"
    echo "Install tmux:"
    echo "  macOS:         brew install tmux"
    echo "  Ubuntu/Debian: sudo apt-get install tmux"
    echo "  Fedora/RHEL:   sudo dnf install tmux"
    exit 1
fi

LOG_DIR="${LOG_DIR:-/tmp}"
STATUS_DIR="${STATUS_DIR:-/tmp}"
PRUNE_RETENTION_DAYS="${PRUNE_RETENTION_DAYS:-7}"
STATUS_SUMMARY_LIMIT="${STATUS_SUMMARY_LIMIT:-10}"
TAIL_DEFAULT_LINES="${TAIL_DEFAULT_LINES:-50}"
TAIL_DEFAULT_INTERVAL="${TAIL_DEFAULT_INTERVAL:-2}"

# Normalize directory paths (strip trailing slashes)
LOG_DIR="${LOG_DIR%/}"
STATUS_DIR="${STATUS_DIR%/}"

mkdir -p "$LOG_DIR" "$STATUS_DIR"

# Prune artifacts older than retention window
prune_artifacts() {
    local target_dir=$1
    local pattern=$2

    find "$target_dir" -maxdepth 1 -type f -name "$pattern" -mtime +"$PRUNE_RETENTION_DAYS" -print0 2>/dev/null | xargs -0 rm -f 2>/dev/null || true
}

format_duration() {
    local seconds=$1
    if [ -z "$seconds" ] || [ "$seconds" -lt 0 ] 2>/dev/null; then
        echo "n/a"
        return
    fi

    local hrs=$((seconds / 3600))
    local mins=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    local formatted=""

    if [ "$hrs" -gt 0 ]; then
        formatted+="${hrs}h"
    fi

    if [ "$mins" -gt 0 ] || [ "$hrs" -gt 0 ]; then
        formatted+="${mins}m"
    fi

    formatted+="${secs}s"
    echo "$formatted"
}

abbreviate() {
    local input=$1
    local max=${2:-60}
    if [ -z "$input" ]; then
        echo ""
        return
    fi
    if [ "${#input}" -le "$max" ]; then
        echo "$input"
    else
        local truncated="${input:0:$((max - 3))}"
        echo "${truncated}..."
    fi
}

load_status() {
    local status_file=$1
    local prefix=$2

    if [ ! -f "$status_file" ]; then
        return 1
    fi

    local exit_code=""
    local command=""
    local started_at_iso=""
    local finished_at_iso=""
    local duration_seconds=""
    local log_file=""
    local workdir=""
    local env_vars=""

    # shellcheck disable=SC1090
    source "$status_file"

    printf "%s_exit_code=%q\n" "$prefix" "${exit_code:-}"
    printf "%s_command=%q\n" "$prefix" "${command:-}"
    printf "%s_started_at_iso=%q\n" "$prefix" "${started_at_iso:-}"
    printf "%s_finished_at_iso=%q\n" "$prefix" "${finished_at_iso:-}"
    printf "%s_duration_seconds=%q\n" "$prefix" "${duration_seconds:-}"
    printf "%s_log_file=%q\n" "$prefix" "${log_file:-}"
    printf "%s_workdir=%q\n" "$prefix" "${workdir:-}"
    printf "%s_env_vars=%q\n" "$prefix" "${env_vars:-}"
    return 0
}

# Function to run a task in tmux
TMUX_SUPPORTS_C=""

tmux_supports_c() {
    if [ -n "$TMUX_SUPPORTS_C" ]; then
        [ "$TMUX_SUPPORTS_C" -eq 1 ]
        return
    fi

    local test_session="task-tmuxc-test-$$-$RANDOM"
    if tmux new-session -d -s "$test_session" -c "$PWD" "true" 2>/dev/null; then
        tmux kill-session -t "$test_session" >/dev/null 2>&1 || true
        TMUX_SUPPORTS_C=1
    else
        TMUX_SUPPORTS_C=0
    fi

    [ "$TMUX_SUPPORTS_C" -eq 1 ]
}

run_task() {
    local task_type=$1
    shift

    local workdir=""
    local notify=0
    local -a env_vars=()
    local -a command_args=()

    while [ $# -gt 0 ]; do
        case "$1" in
            --workdir)
                if [ $# -lt 2 ]; then
                    echo "Error: --workdir requires a directory argument"
                    exit 1
                fi
                workdir=$2
                shift 2
                ;;
            --env)
                if [ $# -lt 2 ]; then
                    echo "Error: --env requires KEY=VALUE"
                    exit 1
                fi
                env_vars+=("$2")
                shift 2
                ;;
            --notify)
                notify=1
                shift
                ;;
            --help|-h)
                echo "Usage: $0 run <task-type> [--workdir <dir>] [--env KEY=VALUE ...] [--notify] [--] <command...>"
                return
                ;;
            --)
                shift
                while [ $# -gt 0 ]; do
                    command_args+=("$1")
                    shift
                done
                break
                ;;
            --*)
                echo "Unknown option: $1"
                echo "Usage: $0 run <task-type> [--workdir <dir>] [--env KEY=VALUE ...] [--notify] [--] <command...>"
                exit 1
                ;;
            *)
                command_args+=("$1")
                shift
                ;;
        esac
    done

    if [ ${#command_args[@]} -eq 0 ]; then
        echo "Error: No command provided"
        echo "Usage: $0 run <task-type> [--workdir <dir>] [--env KEY=VALUE ...] [--notify] [--] <command...>"
        exit 1
    fi

    if [ -n "$workdir" ] && [ ! -d "$workdir" ]; then
        echo "Error: workdir not found: $workdir"
        exit 1
    fi

    prune_artifacts "$LOG_DIR" "task-*.log"
    prune_artifacts "$STATUS_DIR" "task-*.status"

    local session="task-${task_type}-$(date +%s)"
    local logfile="$LOG_DIR/${session}.log"
    local status_file="$STATUS_DIR/${session}.status"
    local resolved_workdir="${workdir:-$PWD}"

    rm -f "$status_file"

    local command_string
    command_string=$(printf "%q " "${command_args[@]}")
    command_string="${command_string% }"

    local command_display
    command_display=$(printf "%s " "${command_args[@]}")
    command_display="${command_display% }"

    local command_display_escaped
    command_display_escaped=$(printf "%q" "$command_display")

    local workdir_escaped
    workdir_escaped=$(printf "%q" "$resolved_workdir")

    local env_exports=""
    local env_display=""
    local env_display_escaped=""
    if [ ${#env_vars[@]} -gt 0 ]; then
        local first=1
        for kv in "${env_vars[@]}"; do
            if [[ "$kv" != *=* ]]; then
                echo "Invalid --env value (expected KEY=VALUE): $kv"
                exit 1
            fi
            local key=${kv%%=*}
            local value=${kv#*=}
            if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
                echo "Invalid environment variable name: $key"
                exit 1
            fi
            env_exports+="export $key=$(printf "%q" "$value")"$'\n'
            if [ $first -eq 1 ]; then
                env_display="$key=$value"
                first=0
            else
                env_display="$env_display; $key=$value"
            fi
        done
        env_display_escaped=$(printf "%q" "$env_display")
    fi

    local notify_flag=$notify
    local notify_message_success_escaped
    local notify_message_failure_escaped
    notify_message_success_escaped=$(printf "%q" "[$session] completed successfully")
    notify_message_failure_escaped=$(printf "%q" "[$session] failed with exit")

    local tmux_command
    tmux_command=$(cat <<EOF
set -o pipefail
SESSION_NAME="$session"
LOG_FILE="$logfile"
STATUS_FILE="$status_file"
COMMAND_DISPLAY=$command_display_escaped
ENV_DISPLAY=${env_display_escaped:-''}
WORKDIR_VALUE=$workdir_escaped
NOTIFY_FLAG=$notify_flag
NOTIFY_MESSAGE_SUCCESS=$notify_message_success_escaped
NOTIFY_MESSAGE_FAILURE=$notify_message_failure_escaped
${env_exports}
START_EPOCH=\$(date +%s)
START_ISO=\$(date -u +"%Y-%m-%dT%H:%M:%SZ")
${command_string} 2>&1 | tee "$logfile"
exit_code=\${PIPESTATUS[0]}
END_EPOCH=\$(date +%s)
END_ISO=\$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DURATION=\$((END_EPOCH - START_EPOCH))
if [ \$exit_code -eq 0 ]; then
  echo "Task completed successfully." | tee -a "$logfile"
else
  echo "Task failed with exit code \$exit_code." | tee -a "$logfile"
fi
{
  printf "exit_code=%q\\n" "\$exit_code"
  printf "command=%q\\n" "\$COMMAND_DISPLAY"
  printf "started_at_iso=%q\\n" "\$START_ISO"
  printf "started_at_epoch=%q\\n" "\$START_EPOCH"
  printf "finished_at_iso=%q\\n" "\$END_ISO"
  printf "finished_at_epoch=%q\\n" "\$END_EPOCH"
  printf "duration_seconds=%q\\n" "\$DURATION"
  printf "log_file=%q\\n" "\$LOG_FILE"
  printf "workdir=%q\\n" "\$WORKDIR_VALUE"
  printf "env_vars=%q\\n" "\$ENV_DISPLAY"
} > "$STATUS_FILE"
if [ \$NOTIFY_FLAG -eq 1 ]; then
  message=""
  if [ \$exit_code -eq 0 ]; then
    message="$NOTIFY_MESSAGE_SUCCESS"
  else
    message="$NOTIFY_MESSAGE_FAILURE \$exit_code"
  fi
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "tmux-task-runner" "\$message"
  elif command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"\$message\" with title \"tmux-task-runner\""
  elif command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -title "tmux-task-runner" -message "\$message"
  fi
fi
exit \$exit_code
EOF
)

    local wrapped_command
    wrapped_command=$(printf "%q" "$tmux_command")

    local tmux_args=(-d -s "$session")
    if [ -n "$workdir" ] && tmux_supports_c; then
        tmux_args+=(-c "$workdir")
    fi

    if ! tmux new-session "${tmux_args[@]}" bash -lc "$wrapped_command"; then
        if [ -n "$workdir" ]; then
            local cd_prefix command_with_cd
            cd_prefix=$(printf "cd %q" "$workdir")
            command_with_cd=$(printf "%s\n%s" "$cd_prefix" "$tmux_command")
            wrapped_command=$(printf "%q" "$command_with_cd")
            if ! tmux new-session -d -s "$session" bash -lc "$wrapped_command"; then
                echo "Failed to create tmux session (workdir: $workdir)" >&2
                exit 1
            fi
        else
            echo "Failed to create tmux session" >&2
            exit 1
        fi
    fi

    echo "Task started in tmux session"
    echo "Session: $session"
    echo "Log file: $logfile"
    echo "Status file: $status_file"
    echo "Workdir: $resolved_workdir"
    if [ -n "$env_display" ]; then
        echo "Environment overrides: $env_display"
    fi
    if [ "$notify" -eq 1 ]; then
        echo "Notifications: enabled (best effort)"
    fi
    echo "Monitoring commands:"
    echo "  tail -f $logfile                    # Follow log output"
    echo "  tmux attach-session -t $session     # Attach to session (Ctrl+b, d to detach)"
    echo "  tmux capture-pane -t $session -p    # View current output"
    echo "  $0 tail $session                    # Poll output without attaching"
    echo "  tmux kill-session -t $session       # Stop task and close session"

    sleep 1

    echo "Initial output:"
    if tmux has-session -t "$session" 2>/dev/null; then
        tmux capture-pane -t "$session" -p -S -20 2>/dev/null || echo "(Waiting for output...)"
    else
        echo "Session ended immediately - check if command is valid"
        [ -f "$logfile" ] && tail -20 "$logfile"
    fi
}

# Function to check session status
check_session() {
    local session=$1
    local status_file="$STATUS_DIR/${session}.status"
    local logfile="$LOG_DIR/${session}.log"

    if [ -z "$session" ]; then
        echo "Error: No session name provided"
        echo "Usage: $0 check <session-name>"
        exit 1
    fi

    local status_data=""
    local status_exit_code=""
    local status_command=""
    local status_started_at_iso=""
    local status_finished_at_iso=""
    local status_duration_seconds=""
    local status_log_file=""
    local status_workdir=""
    local status_env_vars=""

    if status_data=$(load_status "$status_file" status 2>/dev/null); then
        eval "$status_data"
    fi

    if tmux has-session -t "$session" 2>/dev/null; then
        echo "Session '$session' is running"
        if [ -n "$status_started_at_iso" ]; then
            echo "Started at: $status_started_at_iso"
        fi
        if [ -n "$status_workdir" ]; then
            echo "Working directory: $status_workdir"
        fi
        if [ -n "$status_env_vars" ]; then
            echo "Environment overrides: $status_env_vars"
        fi
        [ -n "$status_command" ] && echo "Command: $status_command"
        echo "Recent output (last 30 lines):"
        tmux capture-pane -t "$session" -p -S -30
        echo "Session info:"
        tmux list-sessions | grep "^$session" || true
    else
        echo "Session '$session' has completed or doesn't exist"

        if [ -n "$status_exit_code" ]; then
            if [ "$status_exit_code" -eq 0 ] 2>/dev/null; then
                echo "Recorded exit status: success (0)"
            else
                echo "Recorded exit status: failure ($status_exit_code)"
            fi
            [ -n "$status_command" ] && echo "Command: $status_command"
            [ -n "$status_workdir" ] && echo "Working directory: $status_workdir"
            if [ -n "$status_env_vars" ]; then
                echo "Environment overrides: $status_env_vars"
            fi
            if [ -n "$status_started_at_iso" ]; then
                echo "Started at: $status_started_at_iso"
            fi
            if [ -n "$status_finished_at_iso" ]; then
                echo "Finished at: $status_finished_at_iso"
            fi
            if [ -n "$status_duration_seconds" ]; then
                echo "Duration: $(format_duration "$status_duration_seconds")"
            fi
        fi

        if [ -f "$logfile" ]; then
            echo "Log file found: $logfile"
            echo "Last 30 lines of log:"
            tail -30 "$logfile"
        fi
    fi
}

# Function to list all task sessions
print_status_summary() {
    local limit=${1:-$STATUS_SUMMARY_LIMIT}
    local status_paths

    status_paths=$(ls -t "$STATUS_DIR"/task-*.status 2>/dev/null | head -n "$limit" || true)

    if [ -z "$status_paths" ]; then
        echo "  No status files found"
        return
    fi

    while IFS= read -r status_path; do
        [ -z "$status_path" ] && continue
        local summary_data=""
        if summary_data=$(load_status "$status_path" summary 2>/dev/null); then
            eval "$summary_data"
            local session_name outcome="unknown" duration_display="n/a" command_short=""
            session_name=$(basename "$status_path" .status)
            if [ -n "$summary_exit_code" ]; then
                if [ "$summary_exit_code" -eq 0 ] 2>/dev/null; then
                    outcome="success"
                else
                    outcome="failed ($summary_exit_code)"
                fi
            fi
            if [ -n "$summary_duration_seconds" ]; then
                duration_display=$(format_duration "$summary_duration_seconds")
            fi
            command_short=$(abbreviate "${summary_command:-}" 70)

            printf "  %-35s | %-12s | %s" "$session_name" "$outcome" "$duration_display"
            if [ -n "$summary_started_at_iso" ]; then
                printf " | %s" "$summary_started_at_iso"
            fi
            printf "\n"
            if [ -n "$command_short" ]; then
                printf "    cmd: %s\n" "$command_short"
            fi
        fi
    done <<< "$status_paths"
}

list_tasks() {
    echo "Active task sessions:"
    local sessions
    sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep "^task-" || true)

    if [ -z "$sessions" ]; then
        echo "  No active task sessions"
    else
        while IFS= read -r s; do
            [ -z "$s" ] && continue
            local status_path="$STATUS_DIR/${s}.status"
            local display="  $s"
            local session_data=""
            if session_data=$(load_status "$status_path" current 2>/dev/null); then
                eval "$session_data"
                if [ -n "$current_started_at_iso" ]; then
                    display="$display | started $current_started_at_iso"
                fi
                if [ -n "$current_workdir" ]; then
                    display="$display | wd $current_workdir"
                fi
            fi
            echo "$display"
        done <<< "$sessions"
    fi

    echo "Recent log files (from $LOG_DIR):"
    local log_glob=("$LOG_DIR"/task-*.log)
    if [ "${log_glob[0]}" = "$LOG_DIR/task-*.log" ]; then
        echo "  No log files found"
    else
        ls -t "${log_glob[@]}" 2>/dev/null | head -n 10 | while read -r log; do
            [ -z "$log" ] && continue
            echo "  $log"
        done
    fi

    echo "Recent task statuses (newest first):"
    print_status_summary "$STATUS_SUMMARY_LIMIT"
}

# Function to kill task sessions
kill_task() {
    local session=$1

    if [ -z "$session" ]; then
        echo "Error: No session name provided"
        echo "Usage: $0 kill <session-name>"
        echo "       $0 kill all  # Kill all task sessions"
        exit 1
    fi

    if [ "$session" = "all" ]; then
        local sessions
        sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep "^task-" || true)

        if [ -z "$sessions" ]; then
            echo "No task sessions to kill"
        else
            echo "Killing all task sessions:"
            while IFS= read -r s; do
                [ -z "$s" ] && continue
                tmux kill-session -t "$s" 2>/dev/null || true
                rm -f "$STATUS_DIR/${s}.status"
                echo "  Killed: $s"
            done <<< "$sessions"
        fi
    else
        if tmux has-session -t "$session" 2>/dev/null; then
            tmux kill-session -t "$session"
            echo "Killed session: $session"
            rm -f "$STATUS_DIR/${session}.status"
        else
            echo "Session not found: $session"
            exit 1
        fi
    fi
}

# Function to attach to session
attach_session() {
    local session=$1

    if [ -z "$session" ]; then
        echo "Error: No session name provided"
        echo "Usage: $0 attach <session-name>"
        exit 1
    fi

    if tmux has-session -t "$session" 2>/dev/null; then
        echo "Attaching to session: $session"
        echo "Press Ctrl+b then d to detach without killing the session"
        sleep 1
        tmux attach-session -t "$session"
    else
        echo "Session not found: $session"
        exit 1
    fi
}

status_command() {
    local target=$1

    if [ -z "$target" ]; then
        echo "Recent task statuses (limit $STATUS_SUMMARY_LIMIT):"
        print_status_summary "$STATUS_SUMMARY_LIMIT"
        return
    fi

    local status_file="$STATUS_DIR/${target}.status"
    if [ ! -f "$status_file" ]; then
        echo "Status file not found for session: $target"
        echo "Expected at: $status_file"
        exit 1
    fi

    local detail_data=""
    if ! detail_data=$(load_status "$status_file" detail 2>/dev/null); then
        echo "Unable to read status file: $status_file"
        exit 1
    fi
    eval "$detail_data"

    echo "Session: $target"
    [ -n "$detail_command" ] && echo "Command: $detail_command"
    [ -n "$detail_workdir" ] && echo "Workdir: $detail_workdir"
    if [ -n "$detail_env_vars" ]; then
        echo "Environment overrides: $detail_env_vars"
    fi
    [ -n "$detail_started_at_iso" ] && echo "Started: $detail_started_at_iso"
    [ -n "$detail_finished_at_iso" ] && echo "Finished: $detail_finished_at_iso"
    if [ -n "$detail_duration_seconds" ]; then
        echo "Duration: $(format_duration "$detail_duration_seconds")"
    fi

    if [ -n "$detail_exit_code" ]; then
        if [ "$detail_exit_code" -eq 0 ] 2>/dev/null; then
            echo "Exit code: $detail_exit_code (success)"
        else
            echo "Exit code: $detail_exit_code (failure)"
        fi
    else
        echo "Exit code: unknown"
    fi

    if [ -n "$detail_log_file" ]; then
        echo "Log file: $detail_log_file"
        if [ -f "$detail_log_file" ]; then
            echo "Last 20 lines:"
            tail -20 "$detail_log_file"
        else
            echo "Log file not found on disk."
        fi
    fi
}

tail_session() {
    local session=""
    local interval=$TAIL_DEFAULT_INTERVAL
    local lines=$TAIL_DEFAULT_LINES

    while [ $# -gt 0 ]; do
        case "$1" in
            --interval)
                if [ $# -lt 2 ]; then
                    echo "Error: --interval requires seconds"
                    exit 1
                fi
                interval=$2
                shift 2
                ;;
            --lines)
                if [ $# -lt 2 ]; then
                    echo "Error: --lines requires a value"
                    exit 1
                fi
                lines=$2
                shift 2
                ;;
            --help|-h)
                echo "Usage: $0 tail <session-name> [--interval seconds] [--lines count]"
                return
                ;;
            *)
                if [ -z "$session" ]; then
                    session=$1
                    shift
                else
                    echo "Unexpected argument: $1"
                    echo "Usage: $0 tail <session-name> [--interval seconds] [--lines count]"
                    exit 1
                fi
                ;;
        esac
    done

    if [ -z "$session" ]; then
        echo "Error: No session name provided"
        echo "Usage: $0 tail <session-name> [--interval seconds] [--lines count]"
        exit 1
    fi

    echo "Tailing session '$session' (Ctrl+C to stop)"
    echo "Interval: ${interval}s, Lines: $lines"

    while true; do
        if tmux has-session -t "$session" 2>/dev/null; then
            echo "=== $(date '+%Y-%m-%d %H:%M:%S') ==="
            tmux capture-pane -t "$session" -p -S -"$lines"
            echo ""
            sleep "$interval"
        else
            echo "Session '$session' is no longer running."
            local logfile="$LOG_DIR/${session}.log"
            if [ -f "$logfile" ]; then
                echo "Log file available at: $logfile"
                echo "Last $lines lines:"
                tail -"$lines" "$logfile"
            fi
            break
        fi
    done
}

# Function to show help
show_help() {
    cat << EOF
Tmux Task Runner

Execute long-running tasks in managed tmux sessions with logging.

Usage:
  $0 run <task-type> [options] <command...>
  $0 check <session-name>            Check status and output of a session
  $0 list                            List all active task sessions and logs
  $0 status [session-name]           Show recent session history or a specific session
  $0 tail <session-name>             Poll output from a session without attaching
  $0 attach <session-name>           Attach to an interactive session
  $0 kill <session-name>             Kill a specific session
  $0 kill all                        Kill all task sessions
  $0 help                            Show this help message

Examples:
  $0 run build "npm run build"
  $0 run test --notify --env NODE_ENV=ci "npm test -- --runInBand"
  $0 run server --workdir ./api "npm run dev"
  $0 check task-build-1729519263
  $0 attach task-server-1729519263
  $0 list
  $0 status
  $0 status task-build-1729519263
  $0 tail task-build-1729519263 --interval 5 --lines 100
  $0 kill task-build-1729519263

Task Types:
  Common task types: build, test, deploy, server, script, job
  Use descriptive names to easily identify sessions later.

Monitoring:
  tail -f $LOG_DIR/task-NAME.log     Follow log output in real-time
  tmux attach-session -t NAME        Interactive session access
  tmux capture-pane -t NAME -p       Quick output snapshot
  $0 tail NAME                       Periodic polling without attaching

Run Options:
  --workdir <dir>                    Run the command from a specific directory
  --env KEY=VALUE                    Export additional environment variables (repeatable)
  --notify                           Attempt desktop notification on completion
  --                                 Treat the remaining arguments as the command

Current Directories:
  Logs:    $LOG_DIR
  Status:  $STATUS_DIR

EOF
}

# Main command handler
case "$1" in
    run)
        shift
        run_task "$@"
        ;;
    check)
        check_session "$2"
        ;;
    list)
        list_tasks
        ;;
    status)
        shift
        status_command "$@"
        ;;
    attach)
        attach_session "$2"
        ;;
    tail)
        shift
        tail_session "$@"
        ;;
    kill)
        kill_task "$2"
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
