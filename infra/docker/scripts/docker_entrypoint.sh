#!/usr/bin/env bash
set -euo pipefail

seed_dir="${BLT_SEED_PROJECT_DIR:-/workspace/resources/seed-project}"
project_dir="${BLT_PROJECT_DIR:-/data/project}"
template_path="${BLT_PROJECT_SETTINGS_TEMPLATE:-/workspace/infra/docker/config/container-project-settings.yml}"
generated_settings_path="${BLT_GENERATED_PROJECT_SETTINGS:-/tmp/blt-project-settings.yml}"
auth_users_template_path="${BLT_AUTH_USERS_TEMPLATE:-/workspace/infra/docker/config/auth_users.csv}"

if [[ -z "${BLT_PROJECT_SETTINGS:-}" ]]; then
  mkdir -p "${project_dir}"

  if [[ -d "${seed_dir}" ]]; then
    cp -an "${seed_dir}/." "${project_dir}/" 2>/dev/null || true
  fi

  escaped_project_dir="${project_dir//|/\\|}"
  sed "s|__PROJECT_FOLDER__|${escaped_project_dir}|g" "${template_path}" > "${generated_settings_path}"
  export BLT_PROJECT_SETTINGS="${generated_settings_path}"
fi

if [[ -n "${BLT_PROJECT_SETTINGS:-}" && -f "${auth_users_template_path}" ]]; then
  settings_dir="$(dirname "${BLT_PROJECT_SETTINGS}")"
  mkdir -p "${settings_dir}"
  cp -an "${auth_users_template_path}" "${settings_dir}/auth_users.csv" 2>/dev/null || true
fi

exec Rscript /workspace/infra/docker/scripts/run_app.R
