#!/usr/bin/env bash
set -euo pipefail

port="${BLT_PORT:-8090}"
heartbeat_file="${BLT_HEARTBEAT_FILE:-/tmp/blt-heartbeat}"
max_age_secs="${BLT_HEARTBEAT_MAX_AGE_SECS:-90}"
http_timeout_secs="${BLT_HEALTHCHECK_HTTP_TIMEOUT_SECS:-5}"
healthcheck_url="${BLT_HEALTHCHECK_URL:-http://127.0.0.1:${port}/}"

curl -fsS --max-time "${http_timeout_secs}" "${healthcheck_url}" >/dev/null

if [[ ! -f "${heartbeat_file}" ]]; then
  echo "heartbeat file is missing: ${heartbeat_file}" >&2
  exit 1
fi

heartbeat_epoch="$(tr -d '[:space:]' < "${heartbeat_file}")"

if [[ ! "${heartbeat_epoch}" =~ ^[0-9]+$ ]]; then
  echo "heartbeat file does not contain a unix timestamp: ${heartbeat_file}" >&2
  exit 1
fi

now_epoch="$(date +%s)"
age_secs="$((now_epoch - heartbeat_epoch))"

if (( age_secs > max_age_secs )); then
  echo "heartbeat is stale: age=${age_secs}s max=${max_age_secs}s" >&2
  exit 1
fi
