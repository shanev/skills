# Claude Code Skills

A collection of skills for Claude Code to enhance development workflows.

## Available Skills

### Tmux Task Runner

Run long-running tasks (builds, tests, deployments, dev servers) in monitored tmux sessions with persistent logging and real-time output monitoring.

## Installation

```
/plugin marketplace add shanev/skills
/plugin install tmux-task-runner@shanev-skills
```

The tmux-task-runner skill should appear in the skills list.

## Prerequisites

The tmux-task-runner skill requires tmux to be installed:

```bash
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt-get install tmux

# Fedora/RHEL
sudo dnf install tmux
```

## Usage

Once installed, Claude automatically invokes skills when relevant:

**Example:**
- **You:** "Run the test suite in the background"
- **Claude:** Uses tmux-task-runner to execute tests in a monitored session

See [skills/tmux-task-runner/EXAMPLES.md](skills/tmux-task-runner/EXAMPLES.md) for detailed examples.

## Troubleshooting

**Skill not appearing:** Run `/plugin` in Claude Code to verify installation

**tmux not found:** Install tmux using your system package manager (see Prerequisites)

## License

MIT
