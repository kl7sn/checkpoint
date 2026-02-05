#!/usr/bin/env bash
set -euo pipefail
# Generates a timestamped checkpoint title in local time.
# Format: Checkpoint - YYYY-MM-DD HHmm

date "+Checkpoint - %Y-%m-%d %H%M"
