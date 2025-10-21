# Tmux Task Runner - Claude Code Skill

Execute long-running tasks in tmux sessions with real-time monitoring. Tasks run in detached sessions with persistent logging and easy monitoring.

## Features

- Detached tmux sessions for long-running tasks
- Timestamped log files in `/tmp/`
- Real-time output monitoring via `tmux capture-pane`
- Session management (list, check, attach, kill)
- Color-coded status output

## Installation

### Plugin System (Recommended)

```
/plugin marketplace add shanev/skills
/plugin install tmux-task-runner@skills
```

Then install tmux if needed:
```bash
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt-get install tmux
```

Verify with `/help` - the skill should appear in the list.

### Manual Installation

**Global (all projects):**
```bash
cd ~/.claude/skills
git clone https://github.com/shanev/skills.git
cd skills/skills/tmux-task-runner
chmod +x run.sh
```

**Project-specific:**
```bash
mkdir -p .claude/skills
cd .claude/skills
git clone https://github.com/shanev/skills.git
cd skills/skills/tmux-task-runner
chmod +x run.sh
```

## Usage

Claude automatically invokes this skill for long-running tasks:

**User:** "Run the test suite in the background"

**Claude:** Executes tests in a tmux session with monitoring commands

### Manual Commands

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

## Requirements

- Claude Code CLI
- tmux
- Bash shell

## Troubleshooting

**Skill not loading:** Run `/help` to verify, ensure `SKILL.md` exists in the skill directory

**Permission errors:** `chmod +x ~/.claude/skills/skills/skills/tmux-task-runner/run.sh`

**tmux not found:** Install tmux using your package manager

## License

MIT
