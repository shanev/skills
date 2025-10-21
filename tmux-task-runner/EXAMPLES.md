# Tmux Task Runner - Examples

This document provides practical examples of using the tmux-task-runner skill.

## Quick Start

### Example 1: Running a Build Process

```bash
# Start a build in a tmux session
./run.sh run build "npm run build"

# Output:
# ✓ Task started in tmux session
#
# Session: task-build-1729519263
# Log file: $LOG_DIR/task-build-1729519263.log   (LOG_DIR defaults to /tmp)
# Status file: $STATUS_DIR/task-build-1729519263.status
# Workdir: /Users/you/project
#
# Monitoring commands:
#   tail -f $LOG_DIR/task-build-1729519263.log
#   tmux attach-session -t task-build-1729519263
#   ./run.sh tail task-build-1729519263
#   tmux kill-session -t task-build-1729519263
```

Monitor the build:
```bash
tail -f "$LOG_DIR"/task-build-1729519263.log
```

### Example 2: Running Tests

```bash
# Run pytest with verbose output and CI environment
./run.sh run test --env NODE_ENV=ci "pytest tests/ --verbose --cov"

# Or with npm/yarn (preserve exit status with coverage)
./run.sh run test --notify "npm test -- --coverage"
```

Check test status:
```bash
./run.sh check task-test-1729519263
# Or review the recorded metadata:
./run.sh status task-test-1729519263
```

### Example 3: Starting a Development Server

```bash
# Start a Python HTTP server
./run.sh run server "python -m http.server 8000"

# Start a Node.js dev server
./run.sh run server --workdir ./apps/frontend "npm run dev"

# Start a Django dev server
./run.sh run server "python manage.py runserver"
```

Attach to the server session to see real-time requests:
```bash
./run.sh attach task-server-1729519263
# Press Ctrl+b then d to detach
```

### Example 4: Running Deployment Scripts

```bash
# Deploy to production
./run.sh run deploy --notify "./deploy.sh production"

# Or with a deployment tool
./run.sh run deploy "terraform apply -auto-approve"
```

Monitor deployment progress:
```bash
# Poll the last 80 lines every 5 seconds
./run.sh tail task-deploy-1729519263 --interval 5 --lines 80
```

## Advanced Usage

### Example 5: Managing Multiple Concurrent Tasks

```bash
# Start multiple tasks
./run.sh run build "npm run build"
./run.sh run test "npm test"
./run.sh run lint "npm run lint"

# List all active tasks
./run.sh list

# Output:
# Active task sessions:
# task-build-1729519263: 1 windows (created Tue Oct 21 10:30:00 2025)
# task-test-1729519264: 1 windows (created Tue Oct 21 10:30:05 2025)
# task-lint-1729519265: 1 windows (created Tue Oct 21 10:30:10 2025)
```

### Example 6: Long-Running Data Processing

```bash
# Process large dataset
./run.sh run process "python scripts/process_data.py --input large_dataset.csv"

# Machine learning training
./run.sh run train "python train_model.py --epochs 100"
```

Check progress periodically:
```bash
# Every 30 seconds, check the last 20 lines
./run.sh tail task-train-1729519263 --interval 30 --lines 20
```

### Example 7: Database Migrations

```bash
# Run database migrations
./run.sh run migrate "alembic upgrade head"

# Or with Django
./run.sh run migrate "python manage.py migrate"
```

### Example 8: Cleanup Operations

```bash
# Check all running tasks
./run.sh list

# Kill a specific task
./run.sh kill task-build-1729519263

# Kill all task sessions
./run.sh kill all
```

## Real-World Scenarios

### Scenario 1: CI/CD Pipeline Simulation

```bash
# Run a complete CI/CD pipeline locally
./run.sh run ci "bash -c '
  echo \"=== Installing dependencies ===\" &&
  npm install &&
  echo \"=== Running linter ===\" &&
  npm run lint &&
  echo \"=== Running tests ===\" &&
  npm test &&
  echo \"=== Building application ===\" &&
  npm run build &&
  echo \"=== CI Pipeline Complete ===\"
'"

# Monitor the pipeline
tail -f "$LOG_DIR"/task-ci-*.log
```

### Scenario 2: Monitoring API Load Testing

```bash
# Start API load test
./run.sh run loadtest "ab -n 10000 -c 100 http://localhost:8000/api/endpoint"

# Or with a more advanced tool
./run.sh run loadtest "artillery run load-test-config.yml"

# Attach to watch real-time metrics
./run.sh attach task-loadtest-1729519263
```

### Scenario 3: File Processing Pipeline

```bash
# Process video files
./run.sh run encode "ffmpeg -i input.mp4 -c:v libx264 -preset slow output.mp4"

# Batch image optimization
./run.sh run optimize "find ./images -name '*.jpg' -exec mogrify -quality 85 {} \;"
```

### Scenario 4: Development Workflow

```bash
# Terminal 1: Start backend server
./run.sh run backend "python manage.py runserver"

# Terminal 2: Start frontend dev server
./run.sh run frontend "npm run dev"

# Terminal 3: Watch tests
./run.sh run test-watch "npm run test:watch"

# Terminal 4: Monitor all logs
./run.sh list
# Then tail specific logs as needed
```

## Integration with Claude Code

When working with Claude Code, you can request task execution like this:

**User:** "Run the test suite in the background so I can continue working"

**Claude:** I'll run your test suite in a tmux session using the tmux-task-runner skill.

```bash
./skills/tmux-task-runner/run.sh run test "npm test -- --coverage"
```

Your tests are now running in session `task-test-1729519263`.

Monitor progress:
```bash
./skills/tmux-task-runner/run.sh tail task-test-1729519263 --lines 80
# Or follow the log directly:
tail -f "$LOG_DIR"/task-test-1729519263.log
```

I'll check the initial output:
```bash
tmux capture-pane -t task-test-1729519263 -p -S -20
```

The tests are running. You can continue working, and I'll check back on the results in a few moments.

---

**User:** "Check on the test results"

**Claude:** Let me check the test session status:

```bash
./skills/tmux-task-runner/run.sh check task-test-1729519263
```

[Shows output with test results]

The tests have completed successfully! All 127 tests passed with 92% coverage.

## Tips and Tricks

### Tip 1: Creating Task Aliases

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias tmux-task='/path/to/skills/tmux-task-runner/run.sh'

# Now you can use:
tmux-task run build "npm run build"
tmux-task list
```

### Tip 2: Monitoring Multiple Sessions

```bash
# Create a monitoring dashboard using tmux itself
tmux new-session -s monitoring \; \
  send-keys "tail -f \"$LOG_DIR\"/task-build-*.log" C-m \; \
  split-window -v \; \
  send-keys "tail -f \"$LOG_DIR\"/task-test-*.log" C-m \; \
  split-window -h \; \
  send-keys "watch -n 5 './run.sh list'" C-m
```

### Tip 3: Saving Output

```bash
# Save complete session output to file
tmux capture-pane -t task-build-1729519263 -p -S - > build-output.txt

# Or just use the log file
cp "$LOG_DIR"/task-build-1729519263.log ./build-output.txt
```

### Tip 4: Setting Up Notifications

```bash
# Built-in flag handles macOS/Linux automatically
./run.sh run build --notify "npm run build"
```

## Troubleshooting

### Issue: Can't find session

```bash
# List all sessions to find the correct name
tmux list-sessions

# Or check available logs
ls -lt "$LOG_DIR"/task-*.log
```

### Issue: Session closed unexpectedly

```bash
# Check the log file for errors
cat "$LOG_DIR"/task-build-1729519263.log

# Look for error messages or exit codes
tail -50 "$LOG_DIR"/task-build-1729519263.log
```

### Issue: Want to keep session after task completes

Sessions exit automatically once the command completes, but the log and status files remain for review (`./run.sh status <session>`).

### Issue: Too many old sessions

```bash
# Kill all active task sessions
./run.sh kill all

# Clean up old log files (older than 7 days)
find "$LOG_DIR" -name "task-*.log" -mtime +7 -delete
```
