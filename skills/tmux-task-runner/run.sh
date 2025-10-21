#!/bin/bash
# Tmux Task Runner - Execute commands in managed tmux sessions
# Usage: ./run.sh <task-type> <command...>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo -e "${RED}Error: tmux is not installed${NC}"
    echo ""
    echo "Install tmux:"
    echo "  macOS:        brew install tmux"
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
        echo -e "${RED}Error: No command provided${NC}"
        echo "Usage: $0 <task-type> <command...>"
        exit 1
    fi

    local session="task-${task_type}-$(date +%s)"
    local logfile="/tmp/${session}.log"

    # Create tmux session with logging
    tmux new-session -d -s "$session" "$command 2>&1 | tee $logfile; echo ''; echo 'Task completed. Session will remain open.'; echo 'Press Ctrl+b then d to detach, or Ctrl+c to close.'; read"

    echo -e "${GREEN}✓ Task started in tmux session${NC}"
    echo ""
    echo -e "${BLUE}Session:${NC} $session"
    echo -e "${BLUE}Log file:${NC} $logfile"
    echo ""
    echo -e "${YELLOW}Monitoring commands:${NC}"
    echo "  tail -f $logfile                    # Follow log output"
    echo "  tmux attach-session -t $session     # Attach to session (Ctrl+b, d to detach)"
    echo "  tmux capture-pane -t $session -p    # View current output"
    echo "  tmux kill-session -t $session       # Stop task and close session"
    echo ""

    # Wait a moment for task to start
    sleep 1

    # Show initial output
    echo -e "${YELLOW}Initial output:${NC}"
    if tmux has-session -t "$session" 2>/dev/null; then
        tmux capture-pane -t "$session" -p -S -20 2>/dev/null || echo "(Waiting for output...)"
    else
        echo -e "${RED}Session ended immediately - check if command is valid${NC}"
        [ -f "$logfile" ] && cat "$logfile"
    fi
}

# Function to check session status
check_session() {
    local session=$1

    if [ -z "$session" ]; then
        echo -e "${RED}Error: No session name provided${NC}"
        echo "Usage: $0 check <session-name>"
        exit 1
    fi

    if tmux has-session -t "$session" 2>/dev/null; then
        echo -e "${GREEN}✓ Session '$session' is running${NC}"
        echo ""
        echo -e "${YELLOW}Recent output (last 30 lines):${NC}"
        tmux capture-pane -t "$session" -p -S -30
        echo ""
        echo -e "${BLUE}Session info:${NC}"
        tmux list-sessions | grep "^$session"
    else
        echo -e "${YELLOW}Session '$session' has completed or doesn't exist${NC}"

        # Check for log file
        local logfile="/tmp/${session}.log"
        if [ -f "$logfile" ]; then
            echo ""
            echo -e "${BLUE}Log file found:${NC} $logfile"
            echo ""
            echo -e "${YELLOW}Last 30 lines of log:${NC}"
            tail -30 "$logfile"
        fi
    fi
}

# Function to list all task sessions
list_tasks() {
    echo -e "${BLUE}Active task sessions:${NC}"
    local sessions=$(tmux list-sessions 2>/dev/null | grep "^task-" || echo "")

    if [ -z "$sessions" ]; then
        echo "  No active task sessions"
    else
        echo "$sessions"
    fi

    echo ""
    echo -e "${BLUE}Available log files:${NC}"
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
        echo -e "${RED}Error: No session name provided${NC}"
        echo "Usage: $0 kill <session-name>"
        echo "       $0 kill-all  # Kill all task sessions"
        exit 1
    fi

    if [ "$session" = "all" ]; then
        local sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep "^task-" || echo "")

        if [ -z "$sessions" ]; then
            echo "No task sessions to kill"
        else
            echo -e "${YELLOW}Killing all task sessions:${NC}"
            echo "$sessions" | while read -r s; do
                tmux kill-session -t "$s"
                echo "  ✓ Killed: $s"
            done
        fi
    else
        if tmux has-session -t "$session" 2>/dev/null; then
            tmux kill-session -t "$session"
            echo -e "${GREEN}✓ Killed session: $session${NC}"
        else
            echo -e "${RED}Session not found: $session${NC}"
            exit 1
        fi
    fi
}

# Function to attach to session
attach_session() {
    local session=$1

    if [ -z "$session" ]; then
        echo -e "${RED}Error: No session name provided${NC}"
        echo "Usage: $0 attach <session-name>"
        exit 1
    fi

    if tmux has-session -t "$session" 2>/dev/null; then
        echo -e "${BLUE}Attaching to session: $session${NC}"
        echo -e "${YELLOW}Press Ctrl+b then d to detach without killing the session${NC}"
        sleep 1
        tmux attach-session -t "$session"
    else
        echo -e "${RED}Session not found: $session${NC}"
        exit 1
    fi
}

# Function to show help
show_help() {
    cat << EOF
${BLUE}Tmux Task Runner${NC}

Execute long-running tasks in managed tmux sessions with logging.

${YELLOW}Usage:${NC}
  $0 run <task-type> <command...>    Run a command in a new tmux session
  $0 check <session-name>            Check status and output of a session
  $0 list                            List all active task sessions and logs
  $0 attach <session-name>           Attach to an interactive session
  $0 kill <session-name>             Kill a specific session
  $0 kill all                        Kill all task sessions
  $0 help                            Show this help message

${YELLOW}Examples:${NC}
  $0 run build "npm run build"
  $0 run test "pytest --verbose"
  $0 run server "python -m http.server 8000"
  $0 check task-build-1729519263
  $0 attach task-server-1729519263
  $0 list
  $0 kill task-build-1729519263

${YELLOW}Task Types:${NC}
  Common task types: build, test, deploy, server, script, job
  Use descriptive names to easily identify sessions later.

${YELLOW}Monitoring:${NC}
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
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
