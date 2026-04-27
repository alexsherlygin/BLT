# Local setup notes

## Runtime
- App/package: `blt` `1.0.0.4`
- R: `4.5.3` locally detected (`README` minimum: `>= 4.4.0`)
- Shiny: `1.13.0` locally detected (`README` minimum: `>= 1.9.1`)
- golem: `0.5.1`
- roxygen2: `7.3.3`
- pkgload: `1.5.1`
- remotes: `2.5.0`
- exiftoolr: `0.2.8`
- ExifTool CLI: `13.55`
- sf: `1.1.0`
- RStudio: not required for CLI run; `README` mentions `>= 2024.04.2+764`
- OS: `macOS 15.7.4` (`Darwin 24.6.0`, `arm64`)

## Install
- Command to install dependencies for running from source:

```bash
Rscript -e 'install.packages(c("remotes","roxygen2")); remotes::install_deps("app", dependencies = TRUE)'
```

- Alternative if you want the package installed locally:

```bash
Rscript -e 'install.packages("remotes"); remotes::install_local("app", dependencies = TRUE)'
```

## Run
- Command to start app from this repo:

```bash
Rscript app/dev/run_dev.R
```

- Optional run with project-specific YAML:

```bash
Rscript -e 'options(shiny.host="127.0.0.1", shiny.port=8090, shiny.launch.browser=TRUE, shiny.maxRequestSize=5000 * 1024^2); library(blt); blt::run_app(projectSettingsFile = "/absolute/path/to/project.yml")'
```

## App URL
- Default dev URL: `http://127.0.0.1:8090`
- `app/dev/run_dev.R` uses port `8090` by default.
- Port can be changed with `BLT_PORT`.
- If app is started via `run_app()` directly, the port may be overridden by Shiny options instead.

## Required environment variables
- No required `.env` file or required env vars were found in the repo.
- Optional vars used by `app/dev/run_dev.R`:
- `BLT_HOST=127.0.0.1`
- `BLT_PORT=8090`
- `BLT_LAUNCH_BROWSER=true`
- Optional advanced golem config selection:
- `GOLEM_CONFIG_ACTIVE=default|production|dev`
- `R_CONFIG_ACTIVE=default|production|dev`

## External dependencies
- Database: none
- File storage: local filesystem only
- External map/tile services: Esri / OpenStreetMap / OpenTopoMap provider tiles over the network
- Optional Google Maps tiles: requires `mapPanelSource = "Google.Maps"` and a non-empty `mapAPIKey` in YAML config, not in env
- System dependency: `ExifTool` CLI must be available for EXIF read/write
- API keys: optional `mapAPIKey` in project/default YAML only for Google tiles
- Local folders created/used by default:
- Config dir: `/Users/a1/Library/Preferences/org.R-project.R/R/blt`
- Data dir: `/Users/a1/Library/Application Support/org.R-project.R/R/blt`
- Default config file: `default-project-config.yml` in the config dir above
- Runtime temp upload folder: `tempdir()/files`

## Files and folders the app expects
- Package assets under `app/inst/app/www/` are bundled with the package and required by the UI when working from the repo root.
- Default mode: the package auto-creates the user config/data dirs above on load.
- Default mode: the package auto-creates `lookup1.csv` ... `lookup8.csv` and `username_lookup.csv` in the data dir if they are missing.
- Default mode: `userAnnotations.rds` is created on first save in the data dir.
- Project-config mode: if you pass `projectSettingsFile=...`, that YAML file must exist and its `projectFolder` path must point to a real local folder.
- The app expects panoramic image files to be uploaded at runtime as `.jpg`, `.jpeg`, or `.png`.
- Optional overlay input is `.kml`.
- Optional help PDFs are `help1.pdf` ... `help8.pdf` in the data/project folder.
- If custom lookup CSVs are missing, the app still starts, but dropdowns may be empty.

## Notes
- `app/dev/run_dev.R` reloads the package from source and requires either `roxygen2` or `pkgload`; the install command above includes `roxygen2`.
- The dev launcher sets `shiny.maxRequestSize` to about `5000 MB`.
- There is no database, queue, cache, Redis, or cloud storage integration in the repo.
- Before useful work in the UI, the user still needs to choose a username and upload panoramic images.
- Images without GPS EXIF can still load, but map placement falls back to zeroed coordinates.

## Runtime launch
- Recommended non-dev launch:
```bash
    Rscript infra/docker/scripts/run_app.R
```

## Docker preset lookups
- Build the Docker image from the repo root with `docker build -f infra/docker/Dockerfile .`.
- Or start the app with Docker Compose from the repo root using `docker compose up --build`.
- The Docker image now seeds project data from `resources/seed-project/` into `/data/project` on container start.
- The container generates a runtime YAML from `infra/docker/config/container-project-settings.yml` and sets `BLT_PROJECT_SETTINGS` automatically.
- To persist lookup edits and `userAnnotations.rds` across container recreations, mount a volume to `/data/project`.
- If you do not mount a volume, every new container still starts with the baked-in lookup defaults from `resources/seed-project/`.
- Export dialogs can be restricted to a single safe folder by setting `BLT_EXPORT_DIR` (Docker image default: `/exports`).
- To let users export to the host Desktop without exposing container internals, bind-mount a host folder such as `$HOME/Desktop/BLT-Exports` to `/exports`.
- The repo `compose.yml` uses a named volume for `/data/project` and bind-mounts `./docker-exports` to `/exports` for easy access from the host.
- The Compose setup also defines a `healthcheck` for BLT and an `autoheal` sidecar that restarts the BLT container if it becomes `unhealthy`.
- The current health check verifies that the BLT HTTP endpoint answers on the configured internal port and that the app heartbeat file is still being refreshed by the R process.
- Default timing is intentionally conservative to reduce false restarts on a healthy but busy app: heartbeat every `15s`, heartbeat freshness window `90s`, HTTP timeout `5s`, health check interval `30s`, and `3` failed checks before the container becomes `unhealthy`.
- The Compose setup now also includes a basic monitoring layer:
- `prometheus` for metrics collection on port `9090`
- `alertmanager` for alert routing on port `9093`
- `cadvisor` for Docker container lifecycle and resource metrics on port `8081`
- `blackbox_exporter` for external-style HTTP probing of `http://blt:8090/`
- `node_exporter` for host-level CPU, memory, disk, and filesystem metrics
- Prometheus configuration lives under `infra/monitoring/prometheus/`, and blackbox exporter configuration lives under `infra/monitoring/blackbox/`.
- Alertmanager configuration lives under `infra/monitoring/alertmanager/`.
- Prometheus alert rules live under `infra/monitoring/prometheus/alerts/`.
- The default Alertmanager receiver is intentionally local-only for now, so alerts are visible in Alertmanager even before Slack, Telegram, or email delivery is configured.
- Telegram delivery can be enabled without committing secrets to git by creating a local `.env` file with `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID`, then recreating the `alertmanager` service.
- Alertmanager includes the bundled Zscaler CA certificates in its default `ALERTMANAGER_SSL_CERT_DIR` trust path for corporate TLS-inspected outbound Telegram traffic.
- Email delivery can be enabled the same way by setting `ALERT_EMAIL_TO`, `ALERT_EMAIL_FROM`, and `SMTP_SMARTHOST` in the local `.env`, plus `SMTP_AUTH_USERNAME` and `SMTP_AUTH_PASSWORD` when SMTP authentication is required.
- BLT container lifecycle alerts are defined from `cAdvisor` using `container_start_time_seconds{name="blt-blt-1"}` to detect recent starts and restarts.

## Persistence
Current persistent app data is file-based and stored in user-specific R directories.
Important files include:
- lookup1.csv ... lookup8.csv
- username_lookup.csv
- userAnnotations.rds
