#!/usr/bin/env bash
set -euo pipefail

CHROME_BIN=""
if command -v google-chrome-stable >/dev/null 2>&1; then
  CHROME_BIN="google-chrome-stable"
elif command -v google-chrome >/dev/null 2>&1; then
  CHROME_BIN="google-chrome"
elif command -v chromium-browser >/dev/null 2>&1; then
  CHROME_BIN="chromium-browser"
elif command -v chromium >/dev/null 2>&1; then
  CHROME_BIN="chromium"
else
  echo "No Chrome/Chromium binary found." >&2
  exit 1
fi

EXTRA_FLAGS=(
  "--no-first-run"
  "--no-default-browser-check"
  "--password-store=basic"
  "--disable-background-timer-throttling"
  "--disable-renderer-backgrounding"
  "--enable-smooth-scrolling"
)

# Fall back to /tmp if container /dev/shm is small (< 512 MB)
SHM_KB=$(df -k /dev/shm 2>/dev/null | awk 'NR==2 {print $2}' || echo "0")
if [ "${SHM_KB:-0}" -lt 524288 ]; then
  EXTRA_FLAGS+=("--disable-dev-shm-usage")
fi

exec "$CHROME_BIN" "${EXTRA_FLAGS[@]}" "$@"
