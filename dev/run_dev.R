# Set options here
options(golem.app.prod = FALSE) # TRUE = production mode, FALSE = development mode

# Set host/port for local or LAN access.
# Use PANNOTATOR_HOST=0.0.0.0 to make the app reachable from other devices.
host <- Sys.getenv("PANNOTATOR_HOST", unset = "127.0.0.1")
port <- as.integer(Sys.getenv("PANNOTATOR_PORT", unset = "8090"))
launch_browser <- tolower(Sys.getenv("PANNOTATOR_LAUNCH_BROWSER", unset = "true")) == "true"

options(
  shiny.host = host,
  shiny.port = port,
  shiny.launch.browser = launch_browser,
  shiny.maxRequestSize = (5000 * 1024^2)
)

# Detach all loaded packages and clean your environment
golem::detach_all_attached()
# rm(list=ls(all.names = TRUE))

# Reload the package source. Use roxygen when available, but don't require it
# just to run the app during local development.
if (requireNamespace("roxygen2", quietly = TRUE)) {
  golem::document_and_reload(pkg = ".")
} else if (requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all(path = ".", export_all = FALSE, helpers = FALSE)
} else {
  stop(
    'Install either "roxygen2" or "pkgload" to run the app from source.'
  )
}

# Run the application
pannotator::run_app()
#run_app(options=list(launch.browser = TRUE))

#pannotator::run_app(projectSettingsFile = "C:/E/test-project.yml")

