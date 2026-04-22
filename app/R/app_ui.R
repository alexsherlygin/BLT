#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {

  #call function in app_config.R to see if a project file was passed in on run_app()
  was_projectSettingsFile_passed_in()

  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    shinyjs::useShinyjs(),
    # Your application UI logic
    fluidPage(
      br(),
      fluidRow(
        column(
          8,
          wellPanel(
            div(
              class = "image-panel-title",
              style = "text-align: center; margin: 0;",
              tags$span("Image Panel", style = "font-size: 13px; font-weight: 600; line-height: 1;") |>
                shinyhelper::helper(
                  type = "markdown",
                  content = "image_panel_hotkeys_help",
                  icon = "question-circle",
                  size = "m"
                )
            ),
            id = "image_panel",
            mod_360_image_ui("pano360_image")
          )
        ),
        column(
          4,
          wellPanel(
            tags$h4("Image Selection", style = "font-size: 13px; text-align: center; margin: 0;"),
            id = "map_panel",
            mod_leaflet_map_kmz_ui("leaflet_map")
          ),
          wellPanel(
            tags$h4("Annotation Panel", style = "font-size: 13px; text-align: center; margin: 0;"),
            id = "form_panel",
            style = "padding: 20px;",
            mod_control_form_ui("control_form"),
            div(id = "add_here")
          )
        )
      )
    )
  )

}


#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  add_resource_path(
    "temp_dir",
    tempdir() #tools::R_user_dir("pannotator")
  )

  tags$head(
    tags$style(
      HTML(
        ".image-panel-title .shinyhelper-wrapper {display: inline-flex; align-items: center; gap: 4px;}
         .image-panel-title .shinyhelper-container {position: static; width: auto; height: auto; line-height: 1;}"
      )
    ),
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "Berta Labelling Tool"
    )
  )
}

apply_config_defaults <- function(config_values) {
  defaults <- list(
    lookup1TextInput = FALSE,
    lookup2TextInput = FALSE,
    lookup3TextInput = FALSE,
    lookup4TextInput = FALSE,
    lookup5Label = "Lookup_5",
    lookup5CsvFile = "lookup5.csv",
    lookup5HelpFile = "help5.pdf",
    lookup5Enabled = FALSE,
    lookup5TextInput = FALSE,
    lookup6Label = "Lookup_6",
    lookup6CsvFile = "lookup6.csv",
    lookup6HelpFile = "help6.pdf",
    lookup6Enabled = FALSE,
    lookup6TextInput = FALSE,
    lookup7Label = "Lookup_7",
    lookup7CsvFile = "lookup7.csv",
    lookup7HelpFile = "help7.pdf",
    lookup7Enabled = FALSE,
    lookup7TextInput = FALSE,
    lookup8Label = "Lookup_8",
    lookup8CsvFile = "lookup8.csv",
    lookup8HelpFile = "help8.pdf",
    lookup8Enabled = FALSE,
    lookup8TextInput = FALSE
  )

  for (cfg_name in names(defaults)) {
    cfg_val <- config_values[[cfg_name]]
    if (
      is.null(cfg_val) ||
      length(cfg_val) == 0
    ) {
      config_values[[cfg_name]] <- defaults[[cfg_name]]
    }
  }

  config_values
}



was_projectSettingsFile_passed_in <- function() {

  # check if a projectSettingsFile is passed in with run_app() ie. run_app(projectSettingsFile = "C:/E/test-project.yml")
  projectOptions <- golem::get_golem_options()
  #View(projectOptions)
  #if(length(projectOptions) > 0){
  if (!is.null(projectOptions$projectSettingsFile)) {
    #print("project SettingsFile passed in:")
    #print(projectOptions$projectSettingsFile)

    rm(list = ls(envir = myEnv), envir = myEnv)
    myEnv$config_dir <- normalizePath(dirname(projectOptions$projectSettingsFile))
    myEnv$project_config_file <- normalizePath(file.path(projectOptions$projectSettingsFile))
    #print(myEnv$project_config_file)
    #config_file <- file.path(config_dir, "config.yml")
    #print(config_dir)
    myEnv$config <- apply_config_defaults(configr::read.config(myEnv$project_config_file))
    r$config <- myEnv$config

    #print(normalizePath(myEnv$config$projectFolder))
    myEnv$data_dir <- normalizePath(myEnv$config$projectFolder)

    # List all PDF files in the directory
    #pdf_files <- list.files(app_sys("app/www"), pattern = "\\.pdf$", full.names = TRUE)
    # Delete each PDF file
    #sapply(pdf_files, file.remove)
    # copy help files to www location for linking in the browser
    for (i in 1:8) {
      lookupFile <- paste0("lookup", i, "HelpFile")
      destFile <- paste0("help",i,".pdf")
      help_name <- myEnv$config[[lookupFile]]
      if (is.null(help_name) || !nzchar(help_name)) {
        next
      }
      fromPath <- normalizePath(file.path(myEnv$data_dir, help_name), mustWork = FALSE)
      if (!file.exists(fromPath)) {
        next
      }
      #toPath <- normalizePath(file.path(app_sys("app/www"), myEnv$config[[lookupFile]]))
      toPath <- normalizePath(file.path(tempdir(), destFile))
      #print(toPath)
      file.copy(fromPath, toPath, overwrite = TRUE)
    }
  }

}

#TODO need to come back tot his and sort out checking whether projectSettingsFile was passed in order

#' @noRd
.onLoad <- function(libname, pkgname) {
  #print("on load called")
  # Call this function during the app's initialization
  initialize_config()

  rm(list = ls(envir = myEnv), envir = myEnv)
  myEnv$config_dir <- normalizePath(tools::R_user_dir("pannotator", which = "config"))
  myEnv$data_dir <- normalizePath(tools::R_user_dir("pannotator", which = "data"))
  myEnv$project_config_file <- normalizePath(file.path(myEnv$config_dir, "default-project-config.yml"))

  myEnv$config <- apply_config_defaults(configr::read.config(myEnv$project_config_file))
  r$config <- myEnv$config

  # List all PDF files in the directory
  pdf_files <- list.files(tempdir(), pattern = "\\.pdf$", full.names = TRUE)
  # Delete each PDF file
  sapply(pdf_files, file.remove)

  # copy help files to temp location for linking in the browser
  for (i in 1:8) {
    lookupFile <- paste0("lookup", i, "HelpFile")
    help_name <- myEnv$config[[lookupFile]]
    if (is.null(help_name) || !nzchar(help_name)) next
    fromPath <- normalizePath(file.path(myEnv$data_dir, "/", help_name), mustWork = FALSE)
    if (!file.exists(fromPath)) next
    toPath <- file.path(tempdir(), help_name)
    file.copy(fromPath, toPath, overwrite = TRUE)
  }
  #print(tempdir())
}
