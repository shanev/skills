#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp "$SCRIPT_DIR/review-loop.sh" ./review-loop.sh
chmod +x ./review-loop.sh

echo "Installed review-loop.sh"
