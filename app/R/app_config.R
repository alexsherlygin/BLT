#'
#' NOTE: If you manually change your package name in the DESCRIPTION,
#' don't forget to change it here too, and in the config file.
#' For a safer name change mechanism, use the `golem::set_golem_name()` function.
#' Access files in the current app
#'
#' @param ... character vectors, specifying subdirectory and file(s)
#' within your package. The default, none, returns the root of the app.
#'
#' @noRd
app_sys <- function(...) {
  system.file(..., package = "blt")
}


#' Read App Config
#'
#' @param value Value to retrieve from the config file.
#' @param config GOLEM_CONFIG_ACTIVE value. If unset, R_CONFIG_ACTIVE.
#' If unset, "default".
#' @param use_parent Logical, scan the parent directory for config file.
#' @param file Location of the config file
#'
#' @noRd
get_golem_config <- function(
  value,
  config = Sys.getenv(
    "GOLEM_CONFIG_ACTIVE",
    Sys.getenv(
      "R_CONFIG_ACTIVE",
      "default"
    )
  ),
  use_parent = TRUE,
  # Modify this if your config file is somewhere else
  file = app_sys("golem-config.yml")
) {
  config::get(
    value = value,
    config = config,
    file = file,
    use_parent = use_parent
  )
}

# r for all the reactive values
r <- shiny::reactiveValues()
# track active annotations so we can remove them
r$active_annotations <- reactiveVal(value = NULL)
r$remove_leafletMap_item <- reactiveVal(value = NULL)
r$remove_leaflet360_item <- reactiveVal(value = NULL)
r$active_annotations_collapse <- NULL
r$refresh_user_config <- NULL
r$current_map_zoom <-  12
#r$current_image <- reactiveVal(value = NULL)


# Function to initialize the user config if it doesn't exist
#' @noRd
initialize_config <- function() {
  #config_path <- get_config_path()
  config_path <- normalizePath(file.path(tools::R_user_dir("blt", which = "config"), "default-project-config.yml"), , mustWork = FALSE)
  #print(config_path)
  data_path <- normalizePath(file.path(tools::R_user_dir("blt", which = "data")), mustWork = FALSE)

  if (!file.exists(config_path)) {
    # Create the directory if it doesn't exist
    dir.create(dirname(config_path), recursive = TRUE, showWarnings = TRUE)

    # Define the configuration settings as a list
    config <- list(
      showPopupAlerts = TRUE,
      appTheme = "cerulean",
      mapPanelWidth = 5,
      panoPanelWidth = 5,
      formPanelWidth = 2,
      mapPanelSource = "Esri.WorldImagery",
      mapAPIKey = "",
      mapIconColour = "green",
      mapMarkerColour = "white",
      mapPolygonStroke = TRUE,
      mapPolygonStrokeColour = "blue",
      mapPolygonStrokeWeight = 2,
      mapPolygonStrokeOpacity = 0.7,
      mapPolygonFill = TRUE,
      mapPolygonFillColour = "navy",
      mapPolygonFillOpacity = 0.3,
      pano360IconColour = "maroon",
      pano360MarkerColour = "white",
      pano360PolygonStroke = TRUE,
      pano360PolygonStrokeColour = "blue",
      pano360PolygonStrokeWeight = 1,
      pano360PolygonStrokeOpacity = 0.9,
      showPano360PolygonStrokeInCropExport = FALSE,
      pano360PolygonFill = TRUE,
      pano360PolygonFillColour = "purple",
      pano360PolygonFillOpacity = 0.1,
      showPano360PolygonFillInCropExport = TRUE,
      projectFolder = data_path,
      annotationsFile = "userAnnotations.rds",
      usernameLookupFile = "username_lookup.csv",
      exportFileFormat = "xlsx",
      lookup1Label = "Lookup_1",
      lookup1CsvFile = "lookup1.csv",
      lookup1HelpFile = "help1.pdf",
      lookup1TextInput = FALSE,
      lookup2Label = "Lookup_2",
      lookup2CsvFile = "lookup2.csv",
      lookup2HelpFile = "help2.pdf",
      lookup2Enabled = FALSE,
      lookup2TextInput = FALSE,
      lookup3Label = "Lookup_3",
      lookup3CsvFile = "lookup3.csv",
      lookup3HelpFile = "help3.pdf",
      lookup3Enabled = FALSE,
      lookup3TextInput = FALSE,
      lookup4Label = "Lookup_4",
      lookup4CsvFile = "lookup4.csv",
      lookup4HelpFile = "help4.pdf",
      lookup4Enabled = FALSE,
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
    # Write the list to a YAML file
    configr::write.config(config, config_path, write.type = "yaml")

  }

  # Backward-compatible config migration:
  # old configs may miss lookup5-lookup7 fields used by the UI.
  config <- configr::read.config(config_path)
  migration_defaults <- list(
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
  for (cfg_name in names(migration_defaults)) {
    cfg_val <- config[[cfg_name]]
    if (
      is.null(cfg_val) ||
      length(cfg_val) == 0 ||
      (is.character(cfg_val) && length(cfg_val) == 1 && !nzchar(cfg_val))
    ) {
      config[[cfg_name]] <- migration_defaults[[cfg_name]]
    }
  }
  configr::write.config(config, config_path, write.type = "yaml")

  if (!dir.exists(data_path)) {
    print("No data directory found, creating data directory.")
    dir.create(data_path, recursive = TRUE, showWarnings = TRUE)  # Create the data directory itself
  }

  create_lookup_files <- function(n = 8) {
    # Loop through 1 to n to create lookup files
    for (i in 1:n) {
      # Define the lookup file path
      lookup_file <- normalizePath(file.path(tools::R_user_dir("blt", which = "data"), paste0("lookup", i, ".csv")), mustWork = FALSE)

      # Check if the file exists, if not create it
      if (!file.exists(lookup_file)) {
        # Create the dataframe
        df <- data.frame(
          display = paste0("lookup ", i),
          value = paste0("lookup_", i),
          stringsAsFactors = FALSE
        )

        # Write the dataframe to a CSV file
        utils::write.csv(df, file = lookup_file, row.names = FALSE)
        cat("Created:", lookup_file, "\n")
      }
    }
  }

  # Call the function to create 7 lookup files
  create_lookup_files(8)

  lookup_file <- normalizePath(file.path(tools::R_user_dir("blt", which = "data"), paste0("username_lookup.csv")), mustWork = FALSE)

  default_username_lookup <- data.frame(
    user_name = c("User 1", "User 2", "User 3", "User 4"),
    value = c("User_1", "User_2", "User_3", "User_4"),
    stringsAsFactors = FALSE
  )

  # Create file if missing, or migrate the historical default 3-user list.
  write_default_lookup <- FALSE
  if (!file.exists(lookup_file)) {
    write_default_lookup <- TRUE
  } else {
    existing_lookup <- tryCatch(
      utils::read.csv(lookup_file, stringsAsFactors = FALSE),
      error = function(e) NULL
    )
    if (!is.null(existing_lookup) &&
        all(c("user_name", "value") %in% names(existing_lookup))) {
      old_default_names <- c("Guest Person", "Jane Doh", "Jack Smith")
      old_default_values <- c("Guest_Person", "Jane_Doh", "Jack_Smith")
      if (identical(existing_lookup$user_name, old_default_names) &&
          identical(existing_lookup$value, old_default_values)) {
        write_default_lookup <- TRUE
      }
    }
  }

  if (write_default_lookup) {
    utils::write.csv(default_username_lookup, file = lookup_file, row.names = FALSE)
    cat("Created/updated:", lookup_file, "\n")
  }

  create_help_pdfs <- function(n = 7) {
    # Loop through 1 to n to create PDF files
    for (i in 1:n) {
      # Define the help file path
      help_file <- normalizePath(file.path(tools::R_user_dir("blt", which = "data"), paste0("help", i, ".pdf")), mustWork = FALSE)

      # Check if the file exists, if not create it
      if (!file.exists(help_file)) {
        # Create a new PDF file
        grDevices::pdf(file = help_file, width = 8, height = 11)  # Standard letter size

        # Plot the "HELP" text in the center of the page
        graphics::plot.new()
        graphics::text(0.5, 0.5, paste0("HELP ", i), cex = 3, font = 2)  # Centered and large

        # Close the PDF device to save the file
        grDevices::dev.off()

        cat("Created:", help_file, "\n")
      }
    }
  }

  # Removed: create_help_pdfs(7) — help PDFs are now only shown if uploaded by user via Settings

}


myEnv <- new.env(parent = emptyenv())

#' @noRd
globalVariables(c("imagefile", "feature_type", "."))

