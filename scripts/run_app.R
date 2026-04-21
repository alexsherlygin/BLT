host <- Sys.getenv("PANNOTATOR_HOST", unset = "0.0.0.0")
port <- as.integer(Sys.getenv("PANNOTATOR_PORT", unset = "8090"))
launch_browser <- tolower(Sys.getenv("PANNOTATOR_LAUNCH_BROWSER", unset = "false")) == "true"
project_settings <- Sys.getenv("PANNOTATOR_PROJECT_SETTINGS", unset = "")

options(
  shiny.host = host,
  shiny.port = port,
  shiny.launch.browser = launch_browser,
  shiny.maxRequestSize = 5000 * 1024^2
)

library(pannotator)

if (nzchar(project_settings)) {
  pannotator::run_app(projectSettingsFile = project_settings)
} else {
  pannotator::run_app()
}