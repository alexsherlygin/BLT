# Local setup notes

## Runtime
- App/package: `pannotator` `1.0.0.4`
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
Rscript -e 'options(shiny.host="127.0.0.1", shiny.port=8090, shiny.launch.browser=TRUE, shiny.maxRequestSize=5000 * 1024^2); library(pannotator); pannotator::run_app(projectSettingsFile = "/absolute/path/to/project.yml")'
```

## App URL
- Default dev URL: `http://127.0.0.1:8090`
- `app/dev/run_dev.R` uses port `8090` by default.
- Port can be changed with `PANNOTATOR_PORT`.
- If app is started via `run_app()` directly, the port may be overridden by Shiny options instead.

## Required environment variables
- No required `.env` file or required env vars were found in the repo.
- Optional vars used by `app/dev/run_dev.R`:
- `PANNOTATOR_HOST=127.0.0.1`
- `PANNOTATOR_PORT=8090`
- `PANNOTATOR_LAUNCH_BROWSER=true`
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
- Config dir: `/Users/a1/Library/Preferences/org.R-project.R/R/pannotator`
- Data dir: `/Users/a1/Library/Application Support/org.R-project.R/R/pannotator`
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
- The Docker image now seeds project data from `resources/seed-project/` into `/data/project` on container start.
- The container generates a runtime YAML from `infra/docker/config/container-project-settings.yml` and sets `PANNOTATOR_PROJECT_SETTINGS` automatically.
- To persist lookup edits and `userAnnotations.rds` across container recreations, mount a volume to `/data/project`.
- If you do not mount a volume, every new container still starts with the baked-in lookup defaults from `resources/seed-project/`.
- Export dialogs can be restricted to a single safe folder by setting `PANNOTATOR_EXPORT_DIR` (Docker image default: `/exports`).
- To let users export to the host Desktop without exposing container internals, bind-mount a host folder such as `$HOME/Desktop/BLT-Exports` to `/exports`.

## Persistence
Current persistent app data is file-based and stored in user-specific R directories.
Important files include:
- lookup1.csv ... lookup8.csv
- username_lookup.csv
- userAnnotations.rds
