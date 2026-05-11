#!/usr/bin/env sh
REMOTE_ADDRESS="$1"
CHANNEL="$2"
MESSAGE="$3"
if [ "${SIGMARK_ENABLED:-0}" != "1" ]; then
  echo "[sigmark disabled] $CHANNEL -> $MESSAGE"
  exit 0
fi
# For real use, replace this with your original sigmark.sh implementation.
# Example placeholder: send UDP packet
printf '%s\n' "$MESSAGE" | nc -u -w1 "${REMOTE_ADDRESS%:*}" "${REMOTE_ADDRESS##*:}"
