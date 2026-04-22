#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/../.." && pwd)"
image_tag="${1:-blt:latest}"

docker build \
  -f "${script_dir}/Dockerfile" \
  -t "${image_tag}" \
  "${repo_root}"
