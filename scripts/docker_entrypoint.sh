#!/usr/bin/env bash
set -euo pipefail

seed_dir="${PANNOTATOR_SEED_PROJECT_DIR:-/app/Extra}"
project_dir="${PANNOTATOR_PROJECT_DIR:-/data/project}"
template_path="${PANNOTATOR_PROJECT_SETTINGS_TEMPLATE:-/app/container-project-settings.yml}"
generated_settings_path="${PANNOTATOR_GENERATED_PROJECT_SETTINGS:-/tmp/pannotator-project-settings.yml}"

if [[ -z "${PANNOTATOR_PROJECT_SETTINGS:-}" ]]; then
  mkdir -p "${project_dir}"

  if [[ -d "${seed_dir}" ]]; then
    cp -an "${seed_dir}/." "${project_dir}/" 2>/dev/null || true
  fi

  escaped_project_dir="${project_dir//|/\\|}"
  sed "s|__PROJECT_FOLDER__|${escaped_project_dir}|g" "${template_path}" > "${generated_settings_path}"
  export PANNOTATOR_PROJECT_SETTINGS="${generated_settings_path}"
fi

exec Rscript /app/scripts/run_app.R
