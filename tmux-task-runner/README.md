# `tmux` Task Runner

Execute long-running tasks in tmux sessions with real-time monitoring. Tasks run in detached sessions with persistent logging and easy monitoring.

## Features

- Detached tmux sessions for long-running tasks
- Persistent logs and status metadata (configurable via `LOG_DIR` / `STATUS_DIR`)
- Flexible run options: `--workdir`, repeatable `--env` overrides, and optional notifications
- Real-time output monitoring via `tmux`, the built-in `tail` helper, or log files
- Session management (list, status, check, attach, kill)
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

# Provide a working directory and environment overrides
./run.sh run test --workdir ./services/api --env NODE_ENV=ci --env DEBUG=1 "npm test -- --runInBand"

# Enable notifications when the command finishes (best effort)
./run.sh run deploy --notify "./scripts/deploy.sh production"

# Check status
./run.sh check task-build-1729519263

# List all tasks
./run.sh list

# Summarize recent runs or inspect a specific session
./run.sh status
./run.sh status task-build-1729519263

# Tail output without attaching
./run.sh tail task-build-1729519263 --interval 5 --lines 80

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
3. Captures all output to `${LOG_DIR:-/tmp}/task-{name}.log`
4. Provides monitoring commands for real-time output
5. Session persists until task completes or you kill it

## Monitoring Sessions

**View logs in real-time (`LOG_DIR` defaults to `/tmp`):**
```bash
tail -f "$LOG_DIR"/task-build-1729519263.log
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

**Poll output without attaching:**
```bash
./run.sh tail task-build-1729519263 --interval 5 --lines 80
```

## Configuration

Set the following environment variables before invoking `run.sh` (or exporting them in your shell) to customize behavior:

- `LOG_DIR` (default `/tmp`): where log files are written
- `STATUS_DIR` (default `/tmp`): stores status metadata for each task
- `PRUNE_RETENTION_DAYS` (default `7`): automatically removes logs/status files older than this many days
- `STATUS_SUMMARY_LIMIT` (default `10`): number of entries shown by `list`/`status`
- `TAIL_DEFAULT_LINES` (default `50`): lines captured per refresh by `tail`
- `TAIL_DEFAULT_INTERVAL` (default `2`): seconds between refreshes in `tail`

Directories are created automatically if they do not exist.

## Troubleshooting

**tmux not found:**
Install tmux using your system package manager (see Prerequisites)

**Session closed unexpectedly:**
Check the log file for errors: `cat "$LOG_DIR"/task-{name}.log`

**Can't find session:**
List all sessions: `tmux list-sessions` or `./run.sh list`

**Too many old sessions:**
Kill all task sessions: `./run.sh kill all`

**Task appears hung:**
Inspect the session with `./run.sh check <session>` and kill it if needed: `./run.sh kill <session>`
