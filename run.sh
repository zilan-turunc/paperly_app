#!/bin/bash
# Reads .env and runs flutter with all keys as --dart-define flags.
# Usage: ./run.sh [extra flutter args, e.g. -d "iPhone 16"]

set -e

ENV_FILE="$(dirname "$0")/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "No .env file found. Running without env vars."
  flutter run "$@"
  exit 0
fi

DEFINES=""
while IFS= read -r line || [ -n "$line" ]; do
  # skip blank lines and comments
  [[ -z "$line" || "$line" == \#* ]] && continue
  DEFINES="$DEFINES --dart-define=$line"
done < "$ENV_FILE"

echo "Running with env from .env..."
# shellcheck disable=SC2086
flutter run $DEFINES "$@"
