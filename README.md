# Claude Code Skills

This repository contains custom skills for Claude Code that extend its capabilities.

## Available Skills

### Tmux Task Runner

**Location:** `skills/tmux-task-runner/`

Execute long-running tasks in tmux sessions with real-time monitoring capabilities. This skill provides a more flexible alternative to standard background process execution by:

- Running tasks in detached tmux sessions
- Capturing all output to timestamped log files
- Enabling real-time monitoring via log tailing
- Allowing interactive session attachment for debugging
- Managing multiple concurrent task sessions

**Use Cases:**
- Build processes (npm run build, webpack, etc.)
- Test suites (jest, pytest, etc.)
- Development servers
- Deployment scripts
- Any long-running command requiring monitoring

**Key Features:**
- Automatic log file creation in `/tmp/`
- Session management (list, check, kill)
- Real-time output capture via `tmux capture-pane`
- Color-coded status output
- Helper script for easy task execution

**Setup:**

1. Install tmux:
   ```bash
   # macOS
   brew install tmux

   # Ubuntu/Debian
   sudo apt-get install tmux

   # Fedora/RHEL
   sudo dnf install tmux
   ```

2. Make the run script executable:
   ```bash
   chmod +x skills/tmux-task-runner/run.sh
   ```

**Usage Examples:**

```bash
# Run a build task
./skills/tmux-task-runner/run.sh run build "npm run build"

# Run tests
./skills/tmux-task-runner/run.sh run test "npm test"

# Start a development server
./skills/tmux-task-runner/run.sh run server "npm run dev"

# Check task status
./skills/tmux-task-runner/run.sh check task-build-1729519263

# List all active tasks
./skills/tmux-task-runner/run.sh list

# Attach to interactive session
./skills/tmux-task-runner/run.sh attach task-server-1729519263

# Kill a task
./skills/tmux-task-runner/run.sh kill task-build-1729519263
```

## How Skills Work

Claude Code skills are autonomously invoked by Claude when relevant to the user's request. Each skill consists of:

- **SKILL.md**: Instructions that Claude reads to understand how to use the skill
- **run.sh** or **run.js**: Executable script that performs the skill's operations
- **package.json**: Metadata and setup instructions

## Creating New Skills

To create a new skill:

1. Create a directory under `skills/` with your skill name
2. Add a `SKILL.md` file with detailed instructions following this structure:
   - Header metadata (name, description, version, author, tags)
   - Critical workflow steps
   - How it works explanation
   - Setup instructions
   - Common usage patterns
   - Tips and troubleshooting
   - Example usage scenarios
3. Add executable scripts (run.sh, run.js, etc.)
4. Add package.json with metadata
5. Update this README with your skill documentation

## Installation

To use these skills with Claude Code, ensure this directory is accessible and the skills are properly configured. Claude will automatically discover and use skills when relevant to user requests.

## Requirements

- Claude Code CLI
- Tmux (for tmux-task-runner skill)
- Bash shell

## License

MIT
