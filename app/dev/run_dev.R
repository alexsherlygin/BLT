# Set options here
options(golem.app.prod = FALSE) # TRUE = production mode, FALSE = development mode

find_package_root <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  candidates <- character()

  if (length(file_arg) >= 1) {
    script_path <- normalizePath(
      sub("^--file=", "", file_arg[[1]]),
      winslash = "/",
      mustWork = TRUE
    )
    candidates <- c(candidates, file.path(dirname(script_path), ".."))
  }

  candidates <- c(candidates, getwd(), file.path(getwd(), "app"))

  for (candidate in unique(candidates)) {
    if (
      file.exists(file.path(candidate, "DESCRIPTION")) &&
      file.exists(file.path(candidate, "NAMESPACE"))
    ) {
      return(normalizePath(candidate, winslash = "/", mustWork = TRUE))
    }
  }

  stop(
    paste(
      "Could not determine the blt package root.",
      "Run this script from the repo root or as app/dev/run_dev.R."
    )
  )
}

app_dir <- find_package_root()

# Set host/port for local or LAN access.
# Use BLT_HOST=0.0.0.0 to make the app reachable from other devices.
host <- Sys.getenv("BLT_HOST", unset = "127.0.0.1")
port <- as.integer(Sys.getenv("BLT_PORT", unset = "8090"))
launch_browser <- tolower(Sys.getenv("BLT_LAUNCH_BROWSER", unset = "true")) == "true"
skip_run <- tolower(Sys.getenv("BLT_SKIP_RUN", unset = "false")) == "true"

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
  golem::document_and_reload(pkg = app_dir)
} else if (requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all(path = app_dir, export_all = FALSE, helpers = FALSE)
} else {
  stop(
    'Install either "roxygen2" or "pkgload" to run the app from source.'
  )
}

# Run the application unless the script is being validated in CI or automation.
if (!skip_run) {
  blt::run_app()
}
# run_app(options=list(launch.browser = TRUE))

#blt::run_app(projectSettingsFile = "C:/E/test-project.yml")

