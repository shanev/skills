---
name: tmux-task-runner
description: Run build processes, test suites, deployments, and development servers in monitored tmux sessions with persistent logging. Use when executing long-running tasks that need background execution with real-time monitoring, or when running commands like npm build, pytest, deployment scripts, or dev servers that should continue running while you work on other tasks.
---

# Tmux Long-Running Task Skill

## Overview

This skill provides a robust solution for running long-running tasks in tmux sessions, offering superior flexibility compared to standard background process execution. It enables:

- **Detached execution**: Tasks run in isolated tmux sessions
- **Real-time monitoring**: Capture and analyze logs via `tmux capture-pane`
- **Developer control**: Attach to sessions for interactive debugging
- **Persistent logging**: All output saved to timestamped log files (configurable via `LOG_DIR`)
- **Status metadata**: Exit codes, timings, and environment details saved for later review
- **Session management**: List, monitor, summarize, and clean up active sessions

## Critical Workflow

When a user requests execution of a long-running task (builds, tests, deployments, servers, etc.):

1. **Detect task type**: Identify if the task is long-running (>30s expected duration)
2. **Create session**: Generate unique session name (e.g., `task-build-1729519263`)
3. **Execute in tmux**: Run command in detached tmux session with logging
4. **Monitor output**: Use `tmux capture-pane` to read session output
5. **Report status**: Inform user of session name, log/status file locations, and monitoring options
6. **Provide access**: Give user commands to tail logs, use the `tail` helper, or attach to the session

**CRITICAL:** Always check if tmux is installed before proceeding. If not found, inform the user to install it first.

## How It Works

1. User requests a long-running task execution
2. Skill creates a tmux session with descriptive name
3. Task runs in a detached session with output captured to a timestamped log in `${LOG_DIR:-/tmp}`
4. Skill records status metadata (exit code, timings, command, overrides) in `${STATUS_DIR:-/tmp}`
5. User can monitor via log tailing, the built-in `tail` helper, the `status` summary, or by attaching
6. Session persists until task completes or user kills it

## Setup Instructions

Ensure tmux is installed on your system:

```bash
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt-get install tmux

# Fedora/RHEL
sudo dnf install tmux
```

Verify installation:
```bash
tmux -V
```

## Execution Pattern

### Step 1: Validate tmux availability

```javascript
// Check if tmux is installed
const { execSync } = require('child_process');

try {
  execSync('which tmux', { stdio: 'pipe' });
} catch (error) {
  throw new Error('tmux is not installed. Please install it first.');
}
```

### Step 2: Prepare session metadata

```bash
# Generate unique session name and resolve directories
SESSION_NAME="task-${TASK_TYPE}-$(date +%s)"
LOG_DIR="${LOG_DIR:-/tmp}"
STATUS_DIR="${STATUS_DIR:-/tmp}"
LOG_FILE="$LOG_DIR/${SESSION_NAME}.log"
STATUS_FILE="$STATUS_DIR/${SESSION_NAME}.status"

# Optional overrides
WORKDIR="${WORKDIR:-$PWD}"                 # run command from a different folder
ENV_OVERRIDES=("NODE_ENV=ci" "DEBUG=1")    # repeatable KEY=VALUE pairs
NOTIFY=1                                   # enable desktop notifications if available
```

### Step 3: Launch tmux session with logging and status tracking

```bash
tmux new-session -d -s "$SESSION_NAME" -c "$WORKDIR" bash -lc '
  set -o pipefail

  # Export requested environment overrides
  export NODE_ENV=ci DEBUG=1

  START_EPOCH=$(date +%s)
  START_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  your-command-here 2>&1 | tee "'"$LOG_FILE"'"
  exit_code=${PIPESTATUS[0]}

  END_EPOCH=$(date +%s)
  END_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  DURATION=$((END_EPOCH - START_EPOCH))

  {
    printf "exit_code=%q\n" "$exit_code"
    printf "command=%q\n" "your-command-here"
    printf "started_at_iso=%q\n" "$START_ISO"
    printf "finished_at_iso=%q\n" "$END_ISO"
    printf "duration_seconds=%q\n" "$DURATION"
    printf "log_file=%q\n" "'"$LOG_FILE"'"
    printf "workdir=%q\n" "'"$WORKDIR"'"
    printf "env_vars=%q\n" "NODE_ENV=ci; DEBUG=1"
  } > "'"$STATUS_FILE"'"

  if [ '"$NOTIFY"' -eq 1 ]; then
    message="[$SESSION_NAME] "
    if [ "$exit_code" -eq 0 ]; then
      message+="completed successfully"
    else
      message+="failed (exit $exit_code)"
    fi
    command -v notify-send >/dev/null 2>&1 && notify-send "tmux-task-runner" "$message"
  fi

  exit "$exit_code"
'
```

### Step 4: Provide monitoring and summary commands

```bash
# Tail the log file directly
tail -f "$LOG_FILE"

# Poll output without attaching
./run.sh tail "$SESSION_NAME" --interval 5 --lines 80

# Summarize session metadata (exit status, duration, timestamps)
./run.sh status "$SESSION_NAME"

# Attach to the session (interactive)
tmux attach-session -t "$SESSION_NAME"
```

## Common Patterns

### Build Tasks

```bash
./run.sh run build "npm run build"
# Monitor tail:   ./run.sh tail task-build-... --interval 5
# Summarize:      ./run.sh status task-build-...
```

### Test Suites

```bash
./run.sh run test --env NODE_ENV=ci "npm test -- --coverage"
```

### Development Server

```bash
./run.sh run server --workdir ./services/web "npm run dev"
```

### Deployment Scripts

```bash
./run.sh run deploy --notify "./deploy.sh production"
```

## Run Script Enhancements

### Working Directory Overrides
- Use `--workdir <path>` to run the command from a different directory without wrapping the command in `cd ... &&`.
- The script attempts to use `tmux new-session -c` when available and falls back to an inline `cd` if necessary.

### Environment Variable Injection
- Repeatable `--env KEY=VALUE` flags export additional environment variables for the task.
- Variable names are validated to prevent invalid shell identifiers.

### Completion Notifications
- `--notify` triggers a best-effort desktop notification (`notify-send`, `osascript`, or `terminal-notifier`) when the job ends.
- Notifications include the session name and whether the command succeeded.

### Status Metadata and Summaries
- Each run writes a status file to `${STATUS_DIR:-/tmp}` containing exit code, timestamps, duration, command, workdir, and env overrides.
- `./run.sh status` lists recent runs; `./run.sh status <session>` prints detailed metadata and the latest log lines.
- Status files enable tooling to expose job history without attaching to tmux directly.

### Tail Helper
- `./run.sh tail <session> [--interval N] [--lines M]` polls `tmux capture-pane` on a timer for lightweight monitoring.
- Falls back to the log file if the session has already exited.

### Configurable Directories and Pruning
- Override `LOG_DIR` and `STATUS_DIR` to store artifacts outside `/tmp`.
- `PRUNE_RETENTION_DAYS` (default 7) automatically removes stale log/status files.
- `STATUS_SUMMARY_LIMIT`, `TAIL_DEFAULT_LINES`, and `TAIL_DEFAULT_INTERVAL` tune command defaults without editing the script.

## Session Management

### List Active Sessions

```bash
# List all tmux sessions
tmux list-sessions

# List only task sessions
tmux list-sessions 2>/dev/null | grep "^task-" || echo "No active task sessions"
```

### Monitor Session Output

```bash
# Capture last 100 lines
tmux capture-pane -t SESSION_NAME -p -S -100

# Capture entire scrollback buffer
tmux capture-pane -t SESSION_NAME -p -S -

# Save to file
tmux capture-pane -t SESSION_NAME -p -S - > session-capture.txt
```

### Kill Sessions

```bash
# Kill specific session
tmux kill-session -t SESSION_NAME

# Kill all task sessions
tmux list-sessions -F "#{session_name}" | grep "^task-" | xargs -I {} tmux kill-session -t {}
```

## Helper Script Example

Create a reusable helper for common operations:

```bash
#!/bin/bash
# tmux-task.sh - Tmux task runner helper

run_task() {
  local task_type=$1
  shift
  local command="$@"

  local session="task-${task_type}-$(date +%s)"
  local logfile="/tmp/${session}.log"

  # Create session
  tmux new-session -d -s "$session" "$command 2>&1 | tee $logfile"

  # Output info
  echo "✓ Task started in session: $session"
  echo "  Log file: $logfile"
  echo ""
  echo "Monitoring commands:"
  echo "  tail -f $logfile              # Follow log output"
  echo "  tmux attach-session -t $session   # Attach to session"
  echo "  tmux kill-session -t $session     # Stop task"
}

check_session() {
  local session=$1

  if tmux has-session -t "$session" 2>/dev/null; then
    echo "Session '$session' is running"
    echo ""
    echo "Recent output:"
    tmux capture-pane -t "$session" -p -S -20
  else
    echo "Session '$session' has completed or doesn't exist"
  fi
}

list_tasks() {
  echo "Active task sessions:"
  tmux list-sessions 2>/dev/null | grep "^task-" || echo "  No active tasks"
}

# Usage example
case "$1" in
  run)
    run_task "$2" "${@:3}"
    ;;
  check)
    check_session "$2"
    ;;
  list)
    list_tasks
    ;;
  *)
    echo "Usage: $0 {run|check|list} [args...]"
    exit 1
esac
```

## Tips

- **CRITICAL:** Always use unique session names to avoid conflicts
- **CRITICAL:** Include timestamps in session names for easy identification
- **CRITICAL:** Always provide log file paths to users for monitoring
- Use descriptive task type prefixes (build, test, deploy, server, etc.)
- Use `LOG_DIR` (defaults to `/tmp`) to avoid cluttering project directories
- Use `tmux capture-pane -p -S -100` to get reasonable output chunks
- For very long output, save to file instead of displaying inline
- Remind users they can attach to sessions for interactive debugging
- Clean up completed sessions periodically to avoid clutter

## Troubleshooting

**Problem:** "session not found" error
- **Solution:** Session may have completed. Check if process finished in log file.

**Problem:** Unable to capture pane output
- **Solution:** Ensure session name is correct: `tmux list-sessions`

**Problem:** Log file not updating
- **Solution:** Verify command includes `2>&1 | tee $LOG_FILE` for proper output capture

**Problem:** tmux not found
- **Solution:** Install tmux using system package manager (brew, apt, dnf, etc.)

**Problem:** Session already exists
- **Solution:** Use unique names with timestamps or kill existing session first

## Example Usage

**User:** "Run the full test suite in the background and let me monitor it"

**Claude:** I'll run your test suite in a tmux session so you can monitor it easily.

```bash
./run.sh run test --env NODE_ENV=ci "npm test -- --runInBand"
```

Your tests are now running in the background. Here's how to monitor:

**Monitor the logs:**
```bash
./run.sh tail task-test-1729519263 --interval 5 --lines 80
# or tail -f "$LOG_DIR"/task-test-1729519263.log
```

**Attach to the session:**
```bash
tmux attach-session -t task-test-1729519263
```
(Press `Ctrl+b` then `d` to detach without stopping the tests)

**Check current status summary:**
```bash
./run.sh status task-test-1729519263
```

The summary includes exit code, duration, timestamps, workdir, and environment overrides once the command finishes.

---

## Advanced Features

### Multi-Pane Monitoring

Run multiple related tasks in split panes:

```bash
SESSION="task-multiview-$(date +%s)"

# Create session with first task
tmux new-session -d -s "$SESSION" "npm run build"

# Split horizontally and run tests
tmux split-window -h -t "$SESSION" "npm test"

# Split first pane vertically for logs
tmux select-pane -t 0
tmux split-window -v -t "$SESSION" "tail -f /tmp/app.log"

echo "Multi-pane session created: $SESSION"
echo "Attach with: tmux attach-session -t $SESSION"
```

### Persistent Sessions

Configure tmux to save sessions across reboots (requires tmux-resurrect plugin):

```bash
# Install tmux plugin manager (TPM)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Add to ~/.tmux.conf
echo "set -g @plugin 'tmux-plugins/tmux-resurrect'" >> ~/.tmux.conf
echo "run '~/.tmux/plugins/tpm/tpm'" >> ~/.tmux.conf
```

### Integration with CI/CD

Use tmux sessions for local CI/CD simulation:

```bash
SESSION="task-ci-$(date +%s)"
LOG="/tmp/${SESSION}.log"

tmux new-session -d -s "$SESSION" bash -c "
  echo '=== Linting ===' && npm run lint &&
  echo '=== Testing ===' && npm test &&
  echo '=== Building ===' && npm run build &&
  echo '=== CI Complete ===' || echo '=== CI Failed ==='
" 2>&1 | tee $LOG
```

## Best Practices

1. **Always provide monitoring commands** to users after starting a session
2. **Use descriptive task types** in session names (build, test, deploy, etc.)
3. **Capture initial output** after starting to confirm task began successfully
4. **Use LOG_DIR (defaults to /tmp)** to keep project directories clean
5. **Include cleanup instructions** for when tasks complete
6. **Check session status** before attempting operations
7. **Provide both tail and attach options** for different monitoring preferences
8. **Use tee for logging** to enable both file and real-time capture
