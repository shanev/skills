# TODO

- [ ] Add support for `run --workdir <path>` by wiring tmux's `-c` flag (fall back to `cd` wrapper if tmux is too old) so tasks can run from alternate directories safely.
- [ ] Support per-task environment overrides (`run --env KEY=VALUE`) without forcing users to inline exports.
- [ ] Allow overriding log/status directories via environment variables (e.g. `LOG_DIR`, `STATUS_DIR`) and automatically prune old artifacts.
- [ ] Record start/end timestamps and duration in the status file for easier post-run analysis.
- [ ] Provide a `status` subcommand that summarizes recent sessions (exit code, duration, log path) instead of manually inspecting `.status` files.
- [ ] Add a lightweight `tail` helper command that periodically captures pane output for users who want polling without attaching.
- [ ] Offer optional completion notifications (desktop notify, sound, etc.) so long-running tasks can signal finish/failure automatically.
