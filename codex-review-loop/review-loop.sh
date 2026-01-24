#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./review-loop.sh [options]

Options:
  --review-cmd <cmd>   Codex command/prompt for review (default: /review)
  --fix-prompt <text>  Codex prompt used to fix issues
  -n, --iterations <n> Max iterations (default: 3)
  --codex-bin <path>   Codex executable (default: codex)
  --dry-run            Print commands without executing codex
  -h, --help           Show this help

Example:
  ./review-loop.sh --review-cmd "/review diff of this PR" --iterations 3
USAGE
}

review_cmd="/review"
fix_prompt="Fix all issues from the latest review. Update tests as needed."
iterations=3
codex_bin="codex"
dry_run=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --review-cmd)
      review_cmd="$2"
      shift 2
      ;;
    --fix-prompt)
      fix_prompt="$2"
      shift 2
      ;;
    -n|--iterations)
      iterations="$2"
      shift 2
      ;;
    --codex-bin)
      codex_bin="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ "$dry_run" -eq 0 ]; then
  if ! command -v "$codex_bin" >/dev/null 2>&1; then
    echo "codex executable not found: $codex_bin" >&2
    exit 127
  fi
fi

has_no_issues() {
  echo "$1" | grep -Eqi 'no (issues|findings|problems)|0 issues|clean review'
}

run_codex() {
  local prompt="$1"
  if [ "$dry_run" -eq 1 ]; then
    echo "DRY RUN: $codex_bin exec $prompt"
    return 0
  fi
  "$codex_bin" exec "$prompt"
}

for ((i = 1; i <= iterations; i++)); do
  echo "Review iteration $i/$iterations"
  if [ "$dry_run" -eq 1 ]; then
    run_codex "$review_cmd"
  else
    review_output="$(run_codex "$review_cmd")"
    printf "%s\n" "$review_output"
    if has_no_issues "$review_output"; then
      echo "No issues reported. Stopping."
      exit 0
    fi
  fi

  if [ "$i" -lt "$iterations" ]; then
    run_codex "$fix_prompt"
  fi

done

echo "Reached max iterations ($iterations)."
exit 0
