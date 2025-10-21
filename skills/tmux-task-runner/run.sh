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

# Function to run a task in tmux
run_task() {
    local task_type=$1
    shift
    local command="$@"

    if [ -z "$command" ]; then
        echo "Error: No command provided"
        echo "Usage: $0 <task-type> <command...>"
        exit 1
    fi

    local session="task-${task_type}-$(date +%s)"
    local logfile="/tmp/${session}.log"

    # Create tmux session with logging
    tmux new-session -d -s "$session" "$command 2>&1 | tee $logfile; echo ''; echo 'Task completed. Session will remain open.'; echo 'Press Ctrl+b then d to detach, or Ctrl+c to close.'; read"

    echo "Task started in tmux session"
    echo "Session: $session"
    echo "Log file: $logfile"
    echo "Monitoring commands:"
    echo "  tail -f $logfile                    # Follow log output"
    echo "  tmux attach-session -t $session     # Attach to session (Ctrl+b, d to detach)"
    echo "  tmux capture-pane -t $session -p    # View current output"
    echo "  tmux kill-session -t $session       # Stop task and close session"

    # Wait a moment for task to start
    sleep 1

    # Show initial output
    echo "Initial output:"
    if tmux has-session -t "$session" 2>/dev/null; then
        tmux capture-pane -t "$session" -p -S -20 2>/dev/null || echo "(Waiting for output...)"
    else
        echo "Session ended immediately - check if command is valid"
        [ -f "$logfile" ] && cat "$logfile"
    fi
}

# Function to check session status
check_session() {
    local session=$1

    if [ -z "$session" ]; then
        echo "Error: No session name provided"
        echo "Usage: $0 check <session-name>"
        exit 1
    fi

    if tmux has-session -t "$session" 2>/dev/null; then
        echo "Session '$session' is running"
        echo "Recent output (last 30 lines):"
        tmux capture-pane -t "$session" -p -S -30
        echo "Session info:"
        tmux list-sessions | grep "^$session"
    else
        echo "Session '$session' has completed or doesn't exist"

        # Check for log file
        local logfile="/tmp/${session}.log"
        if [ -f "$logfile" ]; then
            echo "Log file found: $logfile"
            echo "Last 30 lines of log:"
            tail -30 "$logfile"
        fi
    fi
}

# Function to list all task sessions
list_tasks() {
    echo "Active task sessions:"
    local sessions=$(tmux list-sessions 2>/dev/null | grep "^task-" || echo "")

    if [ -z "$sessions" ]; then
        echo "  No active task sessions"
    else
        echo "$sessions"
    fi

    echo "Available log files:"
    local logs=$(ls -t /tmp/task-*.log 2>/dev/null | head -10 || echo "")

    if [ -z "$logs" ]; then
        echo "  No log files found"
    else
        echo "$logs"
    fi
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
        local sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep "^task-" || echo "")

        if [ -z "$sessions" ]; then
            echo "No task sessions to kill"
        else
            echo "Killing all task sessions:"
            echo "$sessions" | while read -r s; do
                tmux kill-session -t "$s"
                echo "  Killed: $s"
            done
        fi
    else
        if tmux has-session -t "$session" 2>/dev/null; then
            tmux kill-session -t "$session"
            echo "Killed session: $session"
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

# Function to show help
show_help() {
    cat << EOF
Tmux Task Runner

Execute long-running tasks in managed tmux sessions with logging.

Usage:
  $0 run <task-type> <command...>    Run a command in a new tmux session
  $0 check <session-name>            Check status and output of a session
  $0 list                            List all active task sessions and logs
  $0 attach <session-name>           Attach to an interactive session
  $0 kill <session-name>             Kill a specific session
  $0 kill all                        Kill all task sessions
  $0 help                            Show this help message

Examples:
  $0 run build "npm run build"
  $0 run test "pytest --verbose"
  $0 run server "python -m http.server 8000"
  $0 check task-build-1729519263
  $0 attach task-server-1729519263
  $0 list
  $0 kill task-build-1729519263

Task Types:
  Common task types: build, test, deploy, server, script, job
  Use descriptive names to easily identify sessions later.

Monitoring:
  tail -f /tmp/task-NAME.log         Follow log output in real-time
  tmux attach-session -t NAME        Interactive session access
  tmux capture-pane -t NAME -p       Quick output snapshot

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
    attach)
        attach_session "$2"
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
