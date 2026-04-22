host <- Sys.getenv("BLT_HOST", unset = "0.0.0.0")
port <- as.integer(Sys.getenv("BLT_PORT", unset = "8090"))
launch_browser <- tolower(Sys.getenv("BLT_LAUNCH_BROWSER", unset = "false")) == "true"
project_settings <- Sys.getenv("BLT_PROJECT_SETTINGS", unset = "")

options(
  shiny.host = host,
  shiny.port = port,
  shiny.launch.browser = launch_browser,
  shiny.maxRequestSize = 5000 * 1024^2
)

library(blt)

if (nzchar(project_settings)) {
  blt::run_app(projectSettingsFile = project_settings)
} else {
  blt::run_app()
}