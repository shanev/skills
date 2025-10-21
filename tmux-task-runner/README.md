# `tmux` Task Runner

Execute long-running tasks in tmux sessions with real-time monitoring. Tasks run in detached sessions with persistent logging and easy monitoring.

## Features

- Detached tmux sessions for long-running tasks
- Timestamped log files in `/tmp/`
- Real-time output monitoring via `tmux capture-pane`
- Session management (list, check, attach, kill)
- Clean output optimized for Claude Code

## Prerequisites

This skill requires tmux to be installed:

```bash
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt-get install tmux

# Fedora/RHEL
sudo dnf install tmux
```

## Usage

Once installed, Claude automatically invokes this skill when you request long-running tasks.

**Examples:**

- **You:** "Run the test suite in the background"
- **Claude:** Executes tests in a tmux session with monitoring commands

- **You:** "Start the build process and let me monitor it"
- **Claude:** Creates a tmux session with the build command and provides monitoring instructions

## Manual Commands

You can also use the run script directly:

```bash
# Run a task
./run.sh run build "npm run build"

# Check status
./run.sh check task-build-1729519263

# List all tasks
./run.sh list

# Attach to session
./run.sh attach task-build-1729519263

# Kill a task
./run.sh kill task-build-1729519263

# Get help
./run.sh help
```

## Use Cases

- Build processes (webpack, npm build, etc.)
- Test suites (jest, pytest, etc.)
- Development servers
- Deployment scripts
- Any command requiring background execution with monitoring

## Examples

See [EXAMPLES.md](EXAMPLES.md) for detailed usage examples including:
- CI/CD pipeline simulation
- Running multiple concurrent tasks
- Database migrations
- Load testing
- And more

## How It Works

1. Creates a uniquely-named tmux session (e.g., `task-build-1729519263`)
2. Runs your command in the detached session
3. Captures all output to `/tmp/task-{name}.log`
4. Provides monitoring commands for real-time output
5. Session persists until task completes or you kill it

## Monitoring Sessions

**View logs in real-time:**
```bash
tail -f /tmp/task-build-1729519263.log
```

**Attach to session interactively:**
```bash
tmux attach-session -t task-build-1729519263
# Press Ctrl+b then d to detach
```

**Quick output snapshot:**
```bash
tmux capture-pane -t task-build-1729519263 -p
```

## Troubleshooting

**tmux not found:**
Install tmux using your system package manager (see Prerequisites)

**Session closed unexpectedly:**
Check the log file for errors: `cat /tmp/task-{name}.log`

**Can't find session:**
List all sessions: `tmux list-sessions` or `./run.sh list`

**Too many old sessions:**
Kill all task sessions: `./run.sh kill all`

**Task appears hung:**
Inspect the session with `./run.sh check <session>` and kill it if needed: `./run.sh kill <session>`
