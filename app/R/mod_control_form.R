#' control_form UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_control_form_ui <- function(id){
  ns <- NS(id)

  #print("mod_control_form")
  #the environment setup in app_config.R file
  myEnv$var_choices <- load_lookup(
    fileToLoad = myEnv$config$usernameLookupFile,
    display_column = "user_name",
    value_column = "value")

  myEnv$var_dropdown1 <- load_lookup(
    fileToLoad = myEnv$config$lookup1CsvFile,
    display_column = "display",
    value_column = "value")

  myEnv$var_dropdown2 <- load_lookup(
    fileToLoad = myEnv$config$lookup2CsvFile,
    display_column = "display",
    value_column = "value")

  myEnv$var_dropdown3 <- load_lookup(
    fileToLoad = myEnv$config$lookup3CsvFile,
    display_column = "display",
    value_column = "value"
  )

  myEnv$var_dropdown4 <- load_lookup(
    fileToLoad = myEnv$config$lookup4CsvFile,
    display_column = "display",
    value_column = "value"
  )

  myEnv$var_dropdown5 <- load_lookup(
    fileToLoad = myEnv$config$lookup5CsvFile,
    display_column = "display",
    value_column = "value"
  )

  myEnv$var_dropdown6 <- load_lookup(
    fileToLoad = myEnv$config$lookup6CsvFile,
    display_column = "display",
    value_column = "value"
  )

  myEnv$var_dropdown7 <- load_lookup(
    fileToLoad = myEnv$config$lookup7CsvFile,
    display_column = "display",
    value_column = "value"
  )

  myEnv$var_dropdown8 <- load_lookup(
    fileToLoad = myEnv$config$lookup8CsvFile,
    display_column = "display",
    value_column = "value"
  )

  #call the functions to create the icons using the colours etc from the settings panel
  myEnv$mapIcons <- create_map_icons()
  myEnv$formIcons <- create_form_icons()

  tagList(
    tags$head( tags$style(HTML("
      hr {border-top: 1px solid #000000;}
      .text-content {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
      .text-content small {
        white-space: normal;
      }
    "))
    ),

    tags$div(style="margin:5px",

             ###################################
             # config form in drop down button #
             ###################################
             shinyWidgets::dropdownButton(

               navbarPage(
                 title = "Berta Labelling Tool",
                 id = "tabset-default-id",
                 selected = "Main Settings",
                 collapsible = TRUE,
                 theme = shinythemes::shinytheme(myEnv$config$appTheme),
                 tabPanel(
                   title = "Main Settings",
                   bslib::layout_column_wrap(
                     width = 1,
                     gap = "10px",
                     bslib::card(
                       bslib::card_body(
                         fillable = TRUE,
                         fill = TRUE,
                         max_height = "790px",
                         padding = 10,
                         fluidRow(
                           column(12,
                                  h2(strong("Layout Settings"))#|>shinyhelper::helper(type = "markdown", content = "user_name", icon = "question-circle", size = "m")
                           )),
                         fluidRow(
                           column(6,  checkboxInput(
                             inputId = ns("showPopupAlerts"),
                             label = "Show info popup alert windows",
                             width = "95%",
                             value = myEnv$config$showPopupAlerts
                           )
                           ),
                           column(3, actionButton(
                             inputId = ns("clearAllButton"),
                             label = "Clear All Annotations Data",
                             style = "float: right; margin-bottom: 20px; margin-right: 10px; overflow-x: hidden !important;"
                           )),
                           column(3, actionButton(
                             inputId = ns("applySettingsButton"),
                             label = "Apply Changes",
                             style = "float: right; margin-bottom: 20px; margin-right: 5px; overflow-x: hidden !important;"
                           ))
                         ),
                         selectInput(
                           inputId = ns("appTheme"),
                           label = "App Theme",
                           width = "95%",
                           selected = myEnv$config$appTheme,
                           choices = allThemes <- c("cerulean", "cosmo", "cyborg", "darkly",
                                                    "flatly", "journal", "lumen", "paper", "readable", "sandstone", "simplex", "slate", "spacelab", "superhero", "united", "yeti"),#shinythemes:::allThemes(),
                           selectize = FALSE
                         ),
                         tags$script(
                           "$('#control_form-appTheme')
        .on('change', function(el) {
        var allThemes = $(this).find('option').map(function() {
        if ($(this).val() === 'default')
        return 'bootstrap';
        else
        return $(this).val();
        });
        // Find the current theme
        var curTheme = el.target.value;
        if (curTheme === 'default') {
        curTheme = 'bootstrap';
        curThemePath = 'shared/bootstrap/css/bootstrap.min.css';
        } else {
        curThemePath = 'shinythemes/css/' + curTheme + '.min.css';
        }
        // Find the <link> element with that has the bootstrap.css
        var $link = $('link').filter(function() {
        var theme = $(this).attr('href');
        theme = theme.replace(/^.*\\//, '').replace(/(\\.min)?\\.css$/, '');
        return $.inArray(theme, allThemes) !== -1;
        });
        // Set it to the correct path
        $link.attr('href', curThemePath);
        });"
                         ),
                         fluidRow(
                           column(4,
                                  sliderInput(
                                    inputId = ns("mapPanelWidth"),
                                    label = "Mapping Panel Width",
                                    min = 3,
                                    max = 6,
                                    value = myEnv$config$mapPanelWidth,
                                    step = 1,
                                  )
                           ),
                           column(4,
                                  sliderInput(
                                    inputId = ns("panoPanelWidth"),
                                    label = "Image Panel Width",
                                    min = 3,
                                    max = 6,
                                    value = myEnv$config$panoPanelWidth,
                                    step = 1,
                                  )
                           ),
                           column(4,
                                  sliderInput(
                                    inputId = ns("formPanelWidth"),
                                    label = "Annotation Panel Width",
                                    min = 2,
                                    max = 4,
                                    value = myEnv$config$formPanelWidth,
                                    step = 1,
                                  )
                           )),
                         h2(strong("Mapping Panel Settings")), #|> shinyhelper::helper(type = "markdown", content = "user_name", icon = "question-circle", size = "m"),
                         selectInput(
                           inputId = ns("mapPanelSource"),
                           label = "Leaflet Map Source",
                           width = "95%",
                           selected = myEnv$config$mapPanelSource,
                           choices = list("Esri WorldImagery" = "Esri.WorldImagery", "Esri WorldTopoMap" = "Esri.WorldTopoMap",        "Esri WorldStreetMap" = "Esri.WorldStreetMap", "Open StreetMap" = "OpenStreetMap", "Open TopoMap" = "OpenTopoMap")
                         ),
                         fluidRow(
                           column(6,  colourpicker::colourInput(
                             inputId = ns("mapIconColour"),
                             label = "Map Icon Colour",
                             palette = "limited",
                             showColour = "background",
                             returnName = TRUE,
                             closeOnClick = TRUE,
                             allowedCols = c("black", "gray", "white", "navy", "blue", "purple", "green", "maroon", "red", "yellow"),
                             value = myEnv$config$mapIconColour
                           )
                           ),
                           column(6, colourpicker::colourInput(
                             inputId = ns("mapMarkerColour"),
                             label = "Map Marker Background Colour",
                             palette = "limited",
                             showColour = "background",
                             returnName = TRUE,
                             closeOnClick = TRUE,
                             allowedCols = c("red", "darkred", "orange", "beige", "green", "darkgreen", "lightgreen", "blue", "darkblue", "lightblue", "purple", "pink", "cadetblue", "white", "gray", "lightgray", "black"),
                             value =myEnv$config$mapMarkerColour,
                           ))
                         ),
                         checkboxInput(
                           inputId = ns("mapPolygonStroke"),
                           label = "Map Polygon Stroke",
                           width = "95%",
                           value = myEnv$config$mapPolygonStroke
                         ) ,
                         fluidRow(
                           column(12,
                                  conditionalPanel(
                                    condition = paste0("input['" ,ns("mapPolygonStroke"), "']"),
                                    div(
                                      style = "border: 1px solid #ccc; padding: 10px; box-shadow: 0px 2px 2px #eee; border-radius: 5px;",
                                      fluidRow(
                                        column(2,  colourpicker::colourInput(
                                          inputId = ns("mapPolygonStrokeColour"),
                                          label = "Stroke Colour",
                                          palette = "limited",
                                          showColour = "background",
                                          returnName = TRUE,
                                          closeOnClick = TRUE,
                                          allowedCols = c("black", "gray", "white", "navy", "blue", "purple", "green", "maroon", "red", "yellow"),
                                          value = myEnv$config$mapPolygonStrokeColour
                                        )),
                                        column(5,   sliderInput(
                                          inputId = ns("mapPolygonStrokeWeight"),
                                          label = "Stroke Weight",
                                          min = 1,
                                          max = 6,
                                          value = myEnv$config$mapPolygonStrokeWeight,
                                          step = 1,
                                        )),
                                        column(5,   sliderInput(
                                          inputId = ns("mapPolygonStrokeOpacity"),
                                          label = "Stroke Opacity",
                                          min = 0.1,
                                          max = 1,
                                          value = myEnv$config$mapPolygonStrokeOpacity,
                                          step = 0.1,
                                        ))
                                      )
                                    )
                                  )
                           )
                         ),
                         checkboxInput(
                           inputId = ns("mapPolygonFill"),
                           label = "Map Polygon Fill",
                           width = "95%",
                           value = myEnv$config$mapPolygonFill
                         ) ,
                         fluidRow(
                           column(12,
                                  conditionalPanel(
                                    condition = paste0("input['" ,ns("mapPolygonFill"), "']"),
                                    div(
                                      style = "border: 1px solid #ccc; padding: 10px; box-shadow: 0px 2px 2px #eee; border-radius: 5px;",
                                      fluidRow(
                                        column(4,  colourpicker::colourInput(
                                          inputId = ns("mapPolygonFillColour"),
                                          label = "Fill Colour",
                                          palette = "limited",
                                          showColour = "background",
                                          returnName = TRUE,
                                          closeOnClick = TRUE,
                                          allowedCols = c("black", "gray", "white", "navy", "blue", "purple", "green", "maroon", "red", "yellow"),
                                          value = myEnv$config$mapPolygonFillColour
                                        )),
                                        column(8,   sliderInput(
                                          inputId = ns("mapPolygonFillOpacity"),
                                          label = "Fill Opacity",
                                          min = 0.1,
                                          max = 1,
                                          value = myEnv$config$mapPolygonFillOpacity,
                                          step = 0.1,
                                        ))
                                      )
                                    )
                                  )
                           )
                         ),
                         h2(strong("Image Panel Settings")),# |> shinyhelper::helper(type = "markdown", content = "user_name", icon = "question-circle", size = "m"),
                         fluidRow(
                           column(6,  colourpicker::colourInput(
                             inputId = ns("pano360IconColour"),
                             label = "Image Icon Colour",
                             palette = "limited",
                             showColour = "background",
                             returnName = TRUE,
                             closeOnClick = TRUE,
                             allowedCols = c("black", "gray", "white", "navy", "blue", "purple", "green", "maroon", "red", "yellow"),
                             value = myEnv$config$pano360IconColour,
                           )
                           ),
                           column(6, colourpicker::colourInput(
                             inputId = ns("pano360MarkerColour"),,
                             label = "Image Marker Background Colour",
                             palette = "limited",
                             showColour = "background",
                             returnName = TRUE,
                             closeOnClick = TRUE,
                             allowedCols = c("red", "darkred", "orange", "beige", "green", "darkgreen", "lightgreen", "blue", "darkblue", "lightblue", "purple", "pink", "cadetblue", "white", "gray", "lightgray", "black"),
                             value = myEnv$config$pano360MarkerColour
                           )),
                         ),
                         checkboxInput(
                           inputId = ns("pano360PolygonStroke"),
                           label = "Image Polygon Stroke",
                           width = "95%",
                           value = myEnv$config$pano360PolygonStroke
                         ) ,

                         fluidRow(
                           column(12,
                                  conditionalPanel(
                                    condition = paste0("input['" ,ns("pano360PolygonStroke"), "']"),
                                    div(
                                      style = "border: 1px solid #ccc; padding: 10px; box-shadow: 0px 2px 2px #eee; border-radius: 5px;",
                                      fluidRow(
                                        column(2,  colourpicker::colourInput(
                                          inputId = ns("pano360PolygonStrokeColour"),
                                          label = "Stroke Colour",
                                          palette = "limited",
                                          showColour = "background",
                                          returnName = TRUE,
                                          closeOnClick = TRUE,
                                          allowedCols = c("black", "gray", "white", "navy", "blue", "purple", "green", "maroon", "red", "yellow"),
                                          value = myEnv$config$pano360PolygonStrokeColour
                                        )),
                                        column(5,   sliderInput(
                                          inputId = ns("pano360PolygonStrokeWeight"),
                                          label = "Stroke Weight",
                                          min = 1,
                                          max = 6,
                                          value = myEnv$config$pano360PolygonStrokeWeight,
                                          step = 1
                                        )),
                                        column(5,   sliderInput(
                                          inputId = ns("pano360PolygonStrokeOpacity"),
                                          label = "Stroke Opacity",
                                          min = 0.1,
                                          max = 1,
                                          value = myEnv$config$pano360PolygonStrokeOpacity,
                                          step = 0.1
                                        ))
                                      ),
                                      checkboxInput(
                                        inputId = ns("showPano360PolygonStrokeInCropExport"),
                                        label = "Show Polygon Stroke In Cropped Image Export",
                                        width = "95%",
                                        value = myEnv$config$showPano360PolygonStrokeInCropExport)
                                    )
                                  )
                           )
                         ),
                         checkboxInput(
                           inputId = ns("pano360PolygonFill"),
                           label = "Image Polygon Fill",
                           width = "95%",
                           value = myEnv$config$pano360PolygonFill
                         ) ,
                         fluidRow(
                           column(12,
                                  conditionalPanel(
                                    condition = paste0("input['" ,ns("pano360PolygonFill"), "']"),
                                    div(
                                      style = "border: 1px solid #ccc; padding: 10px; box-shadow: 0px 2px 2px #eee; border-radius: 5px;",
                                      fluidRow(
                                        column(4,  colourpicker::colourInput(
                                          inputId = ns("pano360PolygonFillColour"),
                                          label = "Fill Colour",
                                          palette = "limited",
                                          showColour = "background",
                                          returnName = TRUE,
                                          closeOnClick = TRUE,
                                          allowedCols = c("black", "gray", "white", "navy", "blue", "purple", "green", "maroon", "red", "yellow"),
                                          value = myEnv$config$pano360PolygonFillColour
                                        )),
                                        column(8,   sliderInput(
                                          inputId = ns("pano360PolygonFillOpacity"),
                                          label = "Fill Opacity",
                                          min = 0.1,
                                          max = 1,
                                          value = myEnv$config$pano360PolygonFillOpacity,
                                          step = 0.1,
                                        ))
                                      ),
                                      checkboxInput(
                                        inputId = ns("showPano360PolygonFillInCropExport"),
                                        label = "Show Polygon Fill In Cropped Image Export",
                                        width = "95%",
                                        value = myEnv$config$showPano360PolygonFillInCropExport)
                                    )
                                  )
                           )
                         ),
                         h2(strong("Annotation Panel Settings")),# |> shinyhelper::helper(type = "markdown", content = "user_name", icon = "question-circle", size = "m"),
                         fileInput(
                           inputId= ns("usernameLookupFile"),
                           label= "Username File",
                           multiple = FALSE,
                           accept = ".csv",
                           width = "95%",
                           buttonLabel = "Browse...",
                           placeholder = paste0(myEnv$config$usernameLookupFile),
                           capture = NULL
                         ) |> shinyhelper::helper(type = "markdown", content = "user_name_csv_help", icon = "question-circle", size = "m"),
                          selectInput(
                           inputId = ns("exportFileFormat"),
                           label = "Export File Format",
                           width = "95%",
                           selected = {
                             saved_export_format <- myEnv$config$exportFileFormat
                             if (
                               is.null(saved_export_format) ||
                               !is.character(saved_export_format) ||
                               length(saved_export_format) != 1 ||
                               is.na(saved_export_format) ||
                               !nzchar(saved_export_format) ||
                               identical(saved_export_format, "csv")
                             ) "xlsx" else saved_export_format
                           },
                           choices = list("xlsx" = "xlsx", "rds" = "rds")
                          ) #|> shinyhelper::helper(type = "markdown", content = "user_name", icon = "question-circle", size = "m")
                        )
                      )
                    )
                  ),
                 tabPanel(
                   title = "Lookups",
                   bslib::layout_column_wrap(
                     width = 1,
                     gap = "10px",
                     bslib::card(
                       bslib::card_body(
                         fillable = TRUE,
                         fill = TRUE,
                         padding = 10,
                         max_height = "790px",
                         textInput(
                           inputId = ns("lookup1Label"),
                           label = "Lookup 1 Label",
                           value = paste0(myEnv$config$lookup1Label),
                           width = "95%"
                         ) |> shinyhelper::helper(type = "markdown", content = "lookup_label_help", icon = "question-circle", size = "m"),
                         checkboxInput(
                           inputId = ns("lookup1TextInput"),
                           label = "Use Text Input (no CSV)",
                           width = "95%",
                           value = is_config_true(myEnv$config$lookup1TextInput)
                         ),
                         fileInput(
                           inputId= ns("lookup1CsvFile"),
                           label= "Lookup 1 csv File",
                           multiple = FALSE,
                           accept = ".csv",
                           width = "95%",
                           buttonLabel = "Lookup 1 csv File...",
                           placeholder = paste0(myEnv$config$lookup1CsvFile),
                           capture = NULL
                         ) |> shinyhelper::helper(type = "markdown", content = "lookup_csv_help", icon = "question-circle", size = "m"),
                         fileInput(
                           inputId= ns("lookup1HelpFile"),
                           label= "Lookup 1 Help File",
                           multiple = FALSE,
                           accept = ".pdf",
                           width = "95%",
                           buttonLabel = "Lookup 1 Help File...",
                           placeholder = paste0(myEnv$config$lookup1HelpFile),
                           capture = NULL
                         ) |> shinyhelper::helper(type = "markdown", content = "lookup_pdf_help", icon = "question-circle", size = "m"),
                         actionButton(inputId = ns("lookup1HelpFileDelete"), label = "Delete Help PDF", icon = icon("trash"), class = "btn btn-danger btn-sm", style = "margin-bottom: 10px;"),
                         checkboxInput(
                           inputId = ns("lookup2Enabled"),
                           label = "Enable Lookup 2",
                           width = "95%",
                           value = myEnv$config$lookup2Enabled
                         ),
                         checkboxInput(
                           inputId = ns("lookup2TextInput"),
                           label = "Use Text Input (no CSV)",
                           width = "95%",
                           value = is_config_true(myEnv$config$lookup2TextInput)
                         ),
                         textInput(
                           inputId = ns("lookup2Label"),
                           label = "Lookup 2 Label",
                           value = paste0(myEnv$config$lookup2Label),
                           width = "95%"
                         ),
                         fileInput(
                           inputId= ns("lookup2CsvFile"),
                           label= "Lookup 2 csv File",
                           multiple = FALSE,
                           accept = ".csv",
                           width = "95%",
                           buttonLabel = "Lookup 2 csv File...",
                           placeholder = paste0(myEnv$config$lookup2CsvFile),
                           capture = NULL
                         ),
                         fileInput(
                           inputId= ns("lookup2HelpFile"),
                           label= "Lookup 2 Help File",
                           multiple = FALSE,
                           accept = ".pdf",
                           width = "95%",
                           buttonLabel = "Lookup 2 Help File...",
                           placeholder = paste0(myEnv$config$lookup2HelpFile),
                           capture = NULL
                         ),
                         actionButton(inputId = ns("lookup2HelpFileDelete"), label = "Delete Help PDF", icon = icon("trash"), class = "btn btn-danger btn-sm", style = "margin-bottom: 10px;"),
                         checkboxInput(
                           inputId = ns("lookup3Enabled"),
                           label = "Enable Lookup 3",
                           width = "95%",
                           value = myEnv$config$lookup3Enabled
                         ),
                         checkboxInput(
                           inputId = ns("lookup3TextInput"),
                           label = "Use Text Input (no CSV)",
                           width = "95%",
                           value = is_config_true(myEnv$config$lookup3TextInput)
                         ),
                         textInput(
                           inputId = ns("lookup3Label"),
                           label = "Lookup 3 Label",
                           value = paste0(myEnv$config$lookup3Label),
                           width = "95%"
                         ),
                         fileInput(
                           inputId= ns("lookup3CsvFile"),
                           label= "Lookup 3 csv File",
                           multiple = FALSE,
                           accept = ".csv",
                           width = "95%",
                           buttonLabel = "Lookup 3 csv File...",
                           placeholder = paste0(myEnv$config$lookup3CsvFile),
                           capture = NULL
                         ),
                         fileInput(
                           inputId= ns("lookup3HelpFile"),
                           label= "Lookup 1 Help File",
                           multiple = FALSE,
                           accept = ".pdf",
                           width = "95%",
                           buttonLabel = "Lookup 3 Help File...",
                           placeholder = paste0(myEnv$config$lookup3HelpFile),
                           capture = NULL
                         ),
                         actionButton(inputId = ns("lookup3HelpFileDelete"), label = "Delete Help PDF", icon = icon("trash"), class = "btn btn-danger btn-sm", style = "margin-bottom: 10px;"),
                         checkboxInput(
                           inputId = ns("lookup4Enabled"),
                           label = "Enable Lookup 4",
                           value = myEnv$config$lookup4Enabled
                         ),
                         checkboxInput(
                           inputId = ns("lookup4TextInput"),
                           label = "Use Text Input (no CSV)",
                           width = "95%",
                           value = is_config_true(myEnv$config$lookup4TextInput)
                         ),
                         textInput(
                           inputId = ns("lookup4Label"),
                           label = "Lookup 4 Label",
                           value = paste0(myEnv$config$lookup4Label),
                           width = "95%"
                         ),
                         fileInput(
                           inputId= ns("lookup4CsvFile"),
                           label= "Lookup 4 csv File",
                           multiple = FALSE,
                           accept = ".csv",
                           width = "95%",
                           buttonLabel = "Lookup 4 csv File...",
                           placeholder = paste0(myEnv$config$lookup4CsvFile),
                           capture = NULL
                         ),
                         fileInput(
                           inputId= ns("lookup4HelpFile"),
                           label= "Lookup 4 Help File",
                           multiple = FALSE,
                           accept = ".pdf",
                           width = "95%",
                           buttonLabel = "Lookup 4 Help File...",
                           placeholder = paste0(myEnv$config$lookup4HelpFile),
                           capture = NULL
                         ),
                         actionButton(inputId = ns("lookup4HelpFileDelete"), label = "Delete Help PDF", icon = icon("trash"), class = "btn btn-danger btn-sm", style = "margin-bottom: 10px;"),
                         checkboxInput(
                           inputId = ns("lookup5Enabled"),
                           label = "Enable Lookup 5",
                           width = "95%",
                           value = myEnv$config$lookup5Enabled
                         ),
                         checkboxInput(
                           inputId = ns("lookup5TextInput"),
                           label = "Use Text Input (no CSV)",
                           width = "95%",
                           value = is_config_true(myEnv$config$lookup5TextInput)
                         ),
                         textInput(
                           inputId = ns("lookup5Label"),
                           label = "Lookup 5 Label",
                           value = paste0(myEnv$config$lookup5Label),
                           width = "95%"
                         ),
                         fileInput(
                           inputId= ns("lookup5CsvFile"),
                           label= "Lookup 5 csv File",
                           multiple = FALSE,
                           accept = ".csv",
                           width = "95%",
                           buttonLabel = "Lookup 5 csv File...",
                           placeholder = paste0(myEnv$config$lookup5CsvFile),
                           capture = NULL
                         ),
                         fileInput(
                           inputId= ns("lookup5HelpFile"),
                           label= "Lookup 5 Help File",
                           multiple = FALSE,
                           accept = ".pdf",
                           width = "95%",
                           buttonLabel = "Lookup 5 Help File...",
                           placeholder = paste0(myEnv$config$lookup5HelpFile),
                           capture = NULL
                         ),
                         actionButton(inputId = ns("lookup5HelpFileDelete"), label = "Delete Help PDF", icon = icon("trash"), class = "btn btn-danger btn-sm", style = "margin-bottom: 10px;"),
                         checkboxInput(
                           inputId = ns("lookup6Enabled"),
                           label = "Enable Lookup 6",
                           width = "95%",
                           value = myEnv$config$lookup6Enabled
                         ),
                         checkboxInput(
                           inputId = ns("lookup6TextInput"),
                           label = "Use Text Input (no CSV)",
                           width = "95%",
                           value = is_config_true(myEnv$config$lookup6TextInput)
                         ),
                         textInput(
                           inputId = ns("lookup6Label"),
                           label = "Lookup 6 Label",
                           value = paste0(myEnv$config$lookup6Label),
                           width = "95%"
                         ),
                         fileInput(
                           inputId= ns("lookup6CsvFile"),
                           label= "Lookup 6 csv File",
                           multiple = FALSE,
                           accept = ".csv",
                           width = "95%",
                           buttonLabel = "Lookup 6 csv File...",
                           placeholder = paste0(myEnv$config$lookup6CsvFile),
                           capture = NULL
                         ),
                         fileInput(
                           inputId= ns("lookup6HelpFile"),
                           label= "Lookup 6 Help File",
                           multiple = FALSE,
                           accept = ".pdf",
                           width = "95%",
                           buttonLabel = "Lookup 6 Help File...",
                           placeholder = paste0(myEnv$config$lookup6HelpFile),
                           capture = NULL
                         ),
                         actionButton(inputId = ns("lookup6HelpFileDelete"), label = "Delete Help PDF", icon = icon("trash"), class = "btn btn-danger btn-sm", style = "margin-bottom: 10px;"),
                         checkboxInput(
                           inputId = ns("lookup7Enabled"),
                           label = "Enable Lookup 7",
                           width = "95%",
                           value = myEnv$config$lookup7Enabled
                         ),
                         checkboxInput(
                           inputId = ns("lookup7TextInput"),
                           label = "Use Text Input (no CSV)",
                           width = "95%",
                           value = is_config_true(myEnv$config$lookup7TextInput)
                         ),
                         textInput(
                           inputId = ns("lookup7Label"),
                           label = "Lookup 7 Label",
                           value = paste0(myEnv$config$lookup7Label),
                           width = "95%"
                         ),
                         fileInput(
                           inputId= ns("lookup7CsvFile"),
                           label= "Lookup 7 csv File",
                           multiple = FALSE,
                           accept = ".csv",
                           width = "95%",
                           buttonLabel = "Lookup 7 csv File...",
                           placeholder = paste0(myEnv$config$lookup7CsvFile),
                           capture = NULL
                         ),
                         fileInput(
                           inputId= ns("lookup7HelpFile"),
                           label= "Lookup 7 Help File",
                           multiple = FALSE,
                           accept = ".pdf",
                           width = "95%",
                           buttonLabel = "Lookup 7 Help File...",
                           placeholder = paste0(myEnv$config$lookup7HelpFile),
                           capture = NULL
                         ),
                         actionButton(inputId = ns("lookup7HelpFileDelete"), label = "Delete Help PDF", icon = icon("trash"), class = "btn btn-danger btn-sm", style = "margin-bottom: 10px;"),
                         checkboxInput(
                           inputId = ns("lookup8Enabled"),
                           label = "Enable Lookup 8",
                           width = "95%",
                           value = myEnv$config$lookup8Enabled
                         ),
                         checkboxInput(
                           inputId = ns("lookup8TextInput"),
                           label = "Use Text Input (no CSV)",
                           width = "95%",
                           value = is_config_true(myEnv$config$lookup8TextInput)
                         ),
                         textInput(
                           inputId = ns("lookup8Label"),
                           label = "Lookup 8 Label",
                           value = paste0(myEnv$config$lookup8Label),
                           width = "95%"
                         ),
                         fileInput(
                           inputId= ns("lookup8CsvFile"),
                           label= "Lookup 8 csv File",
                           multiple = FALSE,
                           accept = ".csv",
                           width = "95%",
                           buttonLabel = "Lookup 8 csv File...",
                           placeholder = paste0(myEnv$config$lookup8CsvFile),
                           capture = NULL
                         ),
                         fileInput(
                           inputId= ns("lookup8HelpFile"),
                           label= "Lookup 8 Help File",
                           multiple = FALSE,
                           accept = ".pdf",
                           width = "95%",
                           buttonLabel = "Lookup 8 Help File...",
                           placeholder = paste0(myEnv$config$lookup8HelpFile),
                           capture = NULL
                         ),
                         actionButton(inputId = ns("lookup8HelpFileDelete"), label = "Delete Help PDF", icon = icon("trash"), class = "btn btn-danger btn-sm", style = "margin-bottom: 10px;")
                       )
                     )
                   )
                 )
                 # tabPanel(
                 #   title = "About This Software",
                 #   bslib::layout_column_wrap(
                 #     width = 1,
                 #     gap = "10px",
                 #     bslib::card(
                 #       bslib::card_header(""),
                 #       bslib::card_body(
                 #         fillable = TRUE,
                 #         fill = TRUE,
                 #         padding = 10,
                 #         max_height = "790px",
                 #         div(style = "display: flex; justify-content: space-between; align-items: center;",
                 #             tags$img(src = "www/pannotator_hex_icon.png", height = "90px"),
                 #             tags$img(src = "www/CSIRO_Wordmark+ANSA_RGB.png", height = "90px")
                 #         ),
                 #         tags$hr(),
                 #         span(HTML("This R 'shiny' app was developed by Nunzio Knerr & Robert Godfree for immersively visualising, mapping and annotating panospheric imagery. The flexible interface allows annotation of any geocoded images using up to 4 user specified dropdown menus. Key functions include the ability to draw on & export parts of 360 images for downstream applications. Users can also draw polygons and points on map imagery related to the panoramic images and export them for further analysis. Downstream applications include using annotations to train AI/ML models and geospatial modelling and analysis of camera based survey data."), style = "font-size: 18px;"),
                 #         tags$hr(),
                 #         span("To cite this software please use:"),
                 #         span(HTML("Godfree R, Knerr N (2024). Rapid ecological data collection from 360-degree imagery using visualisation and immersive sampling in the R pannotator package. <i>Methods in Ecology & Evolution, volume:</i>")),
                 #         span("This paper contains a detailed description of the package and associated worked examples."),
                 #         span("or:"),
                 #         span(HTML("Knerr N, Godfree R (2024). <i>pannotator: Visualisation & Annotation of 360 Degree Imagery.</i> R package version 1.9.1.9000, https://github.com/nunzioknerr/pannotator")),
                 #         span("to cite the software package itself"),
                 #         tags$hr(),
                 #         span("This software makes extensive use of:"),
                 #         tags$a(href="https://exiftool.org/", "ExifTool"),
                 #         span("By Phil Harvey"),
                 #         span("and:"),
                 #         tags$a(href="https://www.leafletjs.com", "Leaflet"),
                 #         span("By Volodymyr Agafonkin"),
                 #         span("and:"),
                 #         tags$a(href="https://pannellum.org/", "Pannellum"),
                 #         span("By Matthew Petroff"),
                 #         tags$a(href="https://github.com/mpetroff/pannellum/blob/master/COPYING", "Pannellum License")
                 #       )
                 #     )
                 #   )
                 # )
               ),
               circle = TRUE, status = "primary", size="xs",
               icon = icon("gear"), right=TRUE,
               margin="5px",
               width="600px",
               inputId="settingsBtn",
               tooltip = shinyWidgets::tooltipOptions(title = "Click to set app configurations!")
             )
    ),
    #########################
    # end of dropdownButton #
    #########################

    shinyWidgets::pickerInput(
      inputId =  ns("user_name"),
      label = "User Name",
      choices = myEnv$var_choices,
      #selected = myEnv$var_choices[1],
      multiple = FALSE,
      width = "100%",
      options = list(container = "body", title = "FIRST: Select Your Name")
    ), #%>% shinyhelper::helper(type = "markdown", content = "user_name", icon = "question-circle"),

    htmlOutput(ns("infoText")),

    # --- Quick-fill: Wind Turbine / Blade / Chamber ---
    tags$hr(),
    tags$div(
      style = "border: 1px solid #ccc; padding: 10px; border-radius: 8px; margin-bottom: 10px; background: #f9f9f9;",
      tags$strong("Quick Fill", style = "font-size: 13px;"),
      fluidRow(
        column(4, textInput(ns("quick_wt"), label = "Wind Turbine Number", value = "", placeholder = "e.g. 1")),
        column(4, textInput(ns("quick_blade"), label = "Blade Number", value = "", placeholder = "e.g. 2")),
        column(4, textInput(ns("quick_chamber"), label = "Chamber Number", value = "", placeholder = "e.g. 3"))
      ),
      actionButton(ns("quick_fill_apply"), label = "Apply to all annotations", icon = icon("check"), class = "btn btn-success btn-sm", style = "width: 100%;")
    ),
    tags$hr(),

    tags$h2("Help Files:"),

    # buttons for help files — only render for lookups that have data loaded AND help PDF exists
    tagList(lapply(1:8, function(i) {
      items <- myEnv[[paste0("var_dropdown", i)]]
      help_name <- myEnv$config[[paste0("lookup", i, "HelpFile")]]
      help_pdf <- if (!is.null(help_name) && nzchar(help_name)) {
        normalizePath(file.path(myEnv$data_dir, help_name), mustWork = FALSE)
      } else {
        ""
      }
      if (length(items) > 0 && nzchar(help_pdf) && file.exists(help_pdf)) {
        label <- myEnv$config[[paste0("lookup", i, "Label")]]
        actionButton(
          inputId = ns(paste0("lookup", i, "_help")),
          label = paste0(label, " Help"),
          icon = icon("question-circle"),
          onclick = paste0("window.open(' ./temp_dir/help", i, ".pdf', '_blank') ")
        )
      }
    })),

    tags$hr(),

    tags$div(style="align-content:end",
             #actionButton(inputId = ns("save_annotations"), label = "Save All Records", icon = icon("save"), style = "margin-bottom: 5px;"),
              tags$div(
                style = "display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 5px;",
                downloadButton(
                  outputId = ns("export_annotations"),
                  label = "Download All Records",
                  icon = icon("download"),
                  style = "margin-bottom: 0;"
                ),
                tags$div(
                  style = "margin-top: 6px;",
                  checkboxInput(
                    inputId = ns("export_include_annotation_images"),
                    label = "Include annotation images in ZIP download",
                    value = FALSE
                  )
                )
              ),

             actionButton(inputId = ns("add_whole_image_annotation"), label = "Add A Whole Image Annotation", icon = icon("plus"), style = "margin-bottom: 5px;"),
             #actionButton(inputId = ns("remove_all_annotations_for_image"), label = "Delete All Annotations For Image", icon = icon("trash")),
    ),
    #div(id = ns("card_container")),
  )
}

#' control_form Server Functions
#'
#' @noRd
mod_control_form_server <- function(id, r){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # Clean up when the app close
    onStop(function(){
      #print("Doing application cleanup\n")
      r$imgs_lst <- NULL
      r$current_image <- NULL
      })

    # hide the map and image panels
    golem::invoke_js("hideid", "map_panel")
    golem::invoke_js("hideid", "image_panel")
    #disable the save button at first
    ####shinyjs::disable("save_annotations")
    shinyjs::disable("export_annotations")
    shinyjs::disable("export_include_annotation_images")
    shinyjs::disable("add_whole_image_annotation")
    #shinyjs::disable("applySettingsButton")

    shinyjs::disable("lookup4HelpFilePath")

    # Help buttons for disabled lookups are no longer rendered (filtered in UI via lapply)

    # Hide CSV/Help file inputs on startup when TextInput mode is active
    for (i in 1:8) {
      if(is_config_true(myEnv$config[[paste0("lookup", i, "TextInput")]])){
        shinyjs::hide(paste0("lookup", i, "CsvFile"))
        shinyjs::hide(paste0("lookup", i, "HelpFile"))
      }
    }


    if(myEnv$config$showPopupAlerts == TRUE){
      shinyWidgets::show_alert(
        title = "Configure The App",
        text = "Use the cog icon (top right) to set your custom user files before you start annotating!",
        type = "info"
      )
    }

    #event triggered on selecting username
    observe({
      r$user_name <- stringr::str_squish(input$user_name)
      req(r$user_name, myEnv$data_dir, myEnv$config$annotationsFile)
      r$user_annotations_file_name <- normalizePath(paste0(myEnv$data_dir, "/", myEnv$config$annotationsFile), mustWork = FALSE)
      #print(r$user_annotations_file_name)
      r$user_annotations_data <- check_for_saved_data(r$user_annotations_file_name)
      golem::invoke_js("showid", "map_panel")
      if(myEnv$config$showPopupAlerts == TRUE){
        shinyWidgets::show_alert(
          title = "Next.. Upload your images",
          text = "Upload PNG or JPG panoramic images to annotate.",
          type = "info"
        )
      }
    }) %>% bindEvent(input$user_name)

    # output for text info
    output$infoText <- renderUI({
      req(r$user_name, r$current_image )
      if(nchar(r$user_name)>0){
        if(nchar(r$current_image)>0){
          shinyjs::enable("export_annotations")
          shinyjs::enable("export_include_annotation_images")
          shinyjs::enable("add_whole_image_annotation")
          #shinyjs::enable("applySettingsButton")
          str1 <- paste0("<b>Annotation File:</b> ", r$user_name, "s_annotations.rds")
          str2 <- paste0("<b>Image File:</b> <small>", r$current_image, "</small><hr>")
          HTML(paste(str1, str2, sep ='<br/>'))
        }
        else {
          shinyjs::disable("export_annotations")
          shinyjs::disable("export_include_annotation_images")
          shinyjs::disable("add_whole_image_annotation")
          #shinyjs::disable("applySettingsButton")
        }
      }
    })

    sanitize_download_name <- function(value) {
      normalized_value <- ""
      if (!is.null(value) && length(value) > 0) {
        normalized_value <- stringr::str_squish(as.character(value)[1])
      }
      if (!nzchar(normalized_value)) {
        normalized_value <- "annotations"
      }

      normalized_value <- gsub("[^A-Za-z0-9._-]+", "_", normalized_value)
      normalized_value <- gsub("_+", "_", normalized_value)
      normalized_value <- gsub("^_+|_+$", "", normalized_value)

      if (!nzchar(normalized_value)) {
        "annotations"
      } else {
        normalized_value
      }
    }

    get_effective_export_format <- function() {
      effective_export_format <- myEnv$config$exportFileFormat
      if (
        is.null(effective_export_format) ||
        !is.character(effective_export_format) ||
        length(effective_export_format) != 1 ||
        is.na(effective_export_format) ||
        !nzchar(effective_export_format) ||
        identical(effective_export_format, "csv")
      ) {
        effective_export_format <- "xlsx"
      }

      effective_export_format
    }

    build_annotations_export_data <- function() {
      temp_df <- r$user_annotations_data[, colnames(r$user_annotations_data) != "radius", drop = FALSE]
      colnames(temp_df) <- c(
        "user", "id", "imagefile", "feature_type", "geometry",
        paste0(myEnv$config$lookup1Label), paste0(myEnv$config$lookup2Label),
        paste0(myEnv$config$lookup3Label), paste0(myEnv$config$lookup4Label),
        paste0(myEnv$config$lookup5Label), paste0(myEnv$config$lookup6Label),
        paste0(myEnv$config$lookup7Label), paste0(myEnv$config$lookup8Label)
      )

      normalize_col_name <- function(x) gsub("\\s+", " ", trimws(tolower(x)))
      normalized_colnames <- normalize_col_name(colnames(temp_df))
      wt_idx <- which(normalized_colnames == normalize_col_name("Wind Turbine Number"))
      blade_idx <- which(normalized_colnames == normalize_col_name("Blade Number"))

      if (length(wt_idx) == 1 && length(blade_idx) == 1) {
        wt_col <- colnames(temp_df)[wt_idx]
        blade_col <- colnames(temp_df)[blade_idx]

        wt_vals <- trimws(as.character(temp_df[[wt_col]]))
        blade_vals <- trimws(as.character(temp_df[[blade_col]]))
        valid_key <- !is.na(wt_vals) & !is.na(blade_vals) & nzchar(wt_vals) & nzchar(blade_vals)

        group_key <- ifelse(valid_key, paste0(wt_vals, "||", blade_vals), NA_character_)
        group_count <- integer(nrow(temp_df))
        running_counts <- new.env(parent = emptyenv())

        for (i in seq_len(nrow(temp_df))) {
          key <- group_key[i]
          if (!is.na(key)) {
            next_n <- if (exists(key, envir = running_counts, inherits = FALSE)) {
              get(key, envir = running_counts, inherits = FALSE) + 1
            } else {
              1
            }
            assign(key, next_n, envir = running_counts)
            group_count[i] <- next_n
          } else {
            group_count[i] <- NA_integer_
          }
        }

        defect_id <- ifelse(
          !is.na(group_count),
          paste0(wt_vals, "_", blade_vals, "_", group_count),
          NA_character_
        )

        left_df <- if (wt_idx > 1) temp_df[, 1:(wt_idx - 1), drop = FALSE] else temp_df[, 0, drop = FALSE]
        right_df <- temp_df[, wt_idx:ncol(temp_df), drop = FALSE]
        temp_df <- data.frame(left_df, "Defect id" = defect_id, right_df, check.names = FALSE, stringsAsFactors = FALSE)
      }

      temp_df
    }

    match_annotation_image_paths <- function(annotation_ids, candidate_dir) {
      if (!dir.exists(candidate_dir)) {
        return(rep(NA_character_, length(annotation_ids)))
      }

      png_files <- list.files(
        path = candidate_dir,
        pattern = "\\.png$",
        full.names = TRUE,
        recursive = TRUE,
        ignore.case = TRUE
      )
      png_basenames <- tolower(basename(png_files))

      vapply(as.character(annotation_ids), function(current_id) {
        if (is.na(current_id) || !nzchar(current_id)) {
          return(NA_character_)
        }
        id_suffix <- tolower(paste0("_", current_id, ".png"))
        match_idx <- which(endsWith(png_basenames, id_suffix))
        if (length(match_idx) == 0) {
          return(NA_character_)
        }
        png_files[match_idx[1]]
      }, character(1))
    }

    write_annotations_workbook <- function(annotation_df, xlsx_path, annotation_img_paths = NULL) {
      wb <- openxlsx::createWorkbook()
      openxlsx::addWorksheet(wb, "Annotations")
      openxlsx::writeData(wb, "Annotations", annotation_df, keepNA = FALSE)

      if (!is.null(annotation_img_paths)) {
        image_col <- ncol(annotation_df)
        matched_rows <- which(!is.na(annotation_img_paths) & file.exists(annotation_img_paths))
        if (length(matched_rows) > 0) {
          openxlsx::setColWidths(wb, sheet = "Annotations", cols = image_col, widths = 35)
          for (current_row in matched_rows) {
            excel_row <- current_row + 1
            openxlsx::setRowHeights(wb, sheet = "Annotations", rows = excel_row, heights = 95)
            openxlsx::insertImage(
              wb,
              sheet = "Annotations",
              file = annotation_img_paths[current_row],
              startRow = excel_row,
              startCol = image_col,
              width = 2.3,
              height = 1.2,
              units = "in",
              dpi = 96
            )
          }
        }
      }

      openxlsx::saveWorkbook(wb, xlsx_path, overwrite = TRUE)
    }

    create_annotation_download <- function(target_file) {
      req(r$user_annotations_file_name, r$user_annotations_data, r$user_name)

      save_annotations(myAnnotations = r$user_annotations_data, myAnnotationFileName = r$user_annotations_file_name)

      temp_df <- build_annotations_export_data()
      include_images <- isTRUE(input$export_include_annotation_images)
      effective_export_format <- get_effective_export_format()
      user_stub <- sanitize_download_name(paste0(r$user_name, "s_annotations"))

      if (include_images) {
        if (!requireNamespace("openxlsx", quietly = TRUE)) {
          stop("Package 'openxlsx' is required for downloads with annotation images.")
        }
        if (!requireNamespace("zip", quietly = TRUE)) {
          stop("Package 'zip' is required for ZIP downloads with annotation images.")
        }

        export_dir <- file.path(
          tempdir(),
          paste0("annotations-download-", as.integer(Sys.time()), "-", sample.int(1e6, 1))
        )
        dir.create(export_dir, recursive = TRUE, showWarnings = FALSE)
        on.exit(unlink(export_dir, recursive = TRUE, force = TRUE), add = TRUE)

        xlsx_path <- file.path(export_dir, paste0(user_stub, ".xlsx"))
        annotation_images_dir <- file.path(export_dir, paste0(sanitize_download_name(r$user_name), "_annotation_images"))
        dir.create(annotation_images_dir, recursive = TRUE, showWarnings = FALSE)

        if (!is.null(r$user_annotations_data) && !is.null(r$imgs_lst) && !is.null(r$imgs_metadata)) {
          tryCatch(
            create_cropped_polygons_from_all_360_images(annotation_images_dir),
            error = function(e) 0L
          )
        }

        annotation_img_paths <- match_annotation_image_paths(temp_df$id, annotation_images_dir)
        temp_df[["Annotation image"]] <- ""
        write_annotations_workbook(temp_df, xlsx_path, annotation_img_paths)

        zip_entries <- basename(xlsx_path)
        image_entries <- list.files(annotation_images_dir, recursive = TRUE, full.names = FALSE, all.files = FALSE, no.. = TRUE)
        if (length(image_entries) > 0) {
          zip_entries <- c(zip_entries, file.path(basename(annotation_images_dir), image_entries))
        }

        zip::zipr(zipfile = target_file, files = zip_entries, root = export_dir)
        return(invisible(NULL))
      }

      if (effective_export_format == "rds") {
        saveRDS(temp_df, file = target_file)
        return(invisible(NULL))
      }

      if (!requireNamespace("openxlsx", quietly = TRUE)) {
        stop("Package 'openxlsx' is required for Excel downloads.")
      }

      write_annotations_workbook(temp_df, target_file)
      invisible(NULL)
    }

    output$export_annotations <- downloadHandler(
      filename = function() {
        req(r$user_name)
        user_stub <- sanitize_download_name(paste0(r$user_name, "s_annotations"))
        if (isTRUE(input$export_include_annotation_images)) {
          return(paste0(user_stub, ".zip"))
        }

        paste0(user_stub, ".", get_effective_export_format())
      },
      content = function(file) {
        tryCatch(
          create_annotation_download(file),
          error = function(e) {
            showNotification(conditionMessage(e), type = "error")
            stop(conditionMessage(e))
          }
        )
      }
    )

    # Quick Fill: Apply WT/Blade/Chamber to ALL annotations across all images
    observe({
      req(r$user_annotations_data, r$user_annotations_file_name)
      wt_val <- trimws(input$quick_wt)
      blade_val <- trimws(input$quick_blade)
      chamber_val <- trimws(input$quick_chamber)

      if (nchar(wt_val) == 0 && nchar(blade_val) == 0 && nchar(chamber_val) == 0) {
        shinyWidgets::show_alert(title = "Nothing to apply", text = "Please enter at least one value.", type = "warning")
        return()
      }

      df <- r$user_annotations_data
      if (nrow(df) == 0) {
        shinyWidgets::show_alert(title = "No annotations", text = "There are no annotations to update.", type = "warning")
        return()
      }

      # Find which dd columns correspond to WT/Blade/Chamber by matching lookup labels
      label_map <- list(
        "Wind Turbine Number" = wt_val,
        "Blade Number" = blade_val,
        "Chamber Number" = chamber_val
      )

      for (i in 1:8) {
        lbl <- myEnv$config[[paste0("lookup", i, "Label")]]
        dd_col <- paste0("dd", i)
        if (!is.null(lbl) && lbl %in% names(label_map)) {
          val <- label_map[[lbl]]
          if (nchar(val) > 0 && dd_col %in% colnames(df)) {
            df[[dd_col]] <- val
          }
        }
      }

      r$user_annotations_data <- df
      save_annotations(myAnnotations = df, myAnnotationFileName = r$user_annotations_file_name)

      # Update visible dropdown/text UI elements for all currently displayed annotation cards
      active_ids <- r$active_annotations()
      for (i in 1:8) {
        lbl <- myEnv$config[[paste0("lookup", i, "Label")]]
        if (!is.null(lbl) && lbl %in% names(label_map)) {
          val <- label_map[[lbl]]
          if (nchar(val) > 0) {
            is_text <- is_config_true(myEnv$config[[paste0("lookup", i, "TextInput")]])
            for (aid in active_ids) {
              input_id <- paste0("dropdown", i, "-", aid)
              if (is_text) {
                updateTextInput(session, inputId = input_id, value = val)
              } else {
                updateSelectInput(session, inputId = input_id, selected = val)
              }
            }
          }
        }
      }

      shinyWidgets::show_alert(
        title = "Applied!",
        text = paste0("Values applied to ", nrow(df), " annotations across all images."),
        type = "success"
      )
    }) %>% bindEvent(input$quick_fill_apply)

    #####################################
    #    Observers for form settings    #
    #####################################

    #event triggered on clear all annotations button
  observeEvent(input$clearAllButton, ignoreInit = TRUE, {
      #print("Clear All Annotations Button Clicked")

    # Trigger SweetAlert confirmation popup
    shinyWidgets::confirmSweetAlert(
      session = session,
      inputId = ns("confirm_clear"),
      title = "Clear All Annotations?",
      text = "Are you sure you want to clear all annotations? THIS CANNOT BE UNDONE!",
      type = "warning",
      btn_labels = c("Cancel", "Confirm"),
      btn_colors = c("#B00225", "#2A52BE"),
      closeOnClickOutside = TRUE,
      showCloseButton = FALSE,
      allowEscapeKey = TRUE,
      cancelOnDismiss = TRUE,
      html = FALSE
    )

    })

    # Respond to SweetAlert confirmation
    observeEvent(input$confirm_clear, {
      if (isTRUE(input$confirm_clear)) {
        # If user clicked 'Yes', reload the session
        #print("user clicked yes")
        r$user_annotations_data <- clear_all_annotation_data(myUserAnnotationsData = r$user_annotations_data)
        clear_annotations_form()
      } else {
        # If user clicked 'No', revert to the previous selection
        #print("user clicked no")
      }
    })

    #event triggered on apply settings button
    observeEvent(input$applySettingsButton, ignoreInit = TRUE, {
      #print("Apply Settings Button Clicked")
      myEnv$config <- configr::read.config(myEnv$project_config_file)
      #r$refresh_user_config <- TRUE
      refresh_user_config(session)
    })

    #event triggered on showPopupAlerts checkbox
    observeEvent(input$showPopupAlerts, ignoreInit = TRUE, {
      req(r$config)
      r$config["showPopupAlerts"] <- input$showPopupAlerts
      #print("showPopupAlerts changed")
      save_user_config("showPopupAlerts")
    })


    #changes to config form
    observeEvent(input$appTheme, ignoreInit = TRUE, {
      req(r$config)
      r$config["appTheme"] <- input$appTheme
      #print("appTheme changed")
      save_user_config("appTheme")
    })

    ########################################
    # dynamically change the sliders
    ########################################
    # observe for mapPanelWidth
    observeEvent(input$mapPanelWidth, ignoreInit = TRUE, {
      req(r$config)
      #r$config["mapPanelWidth"] <- input$mapPanelWidth

      # Calculate the total width of all panels
      totalWidth <- input$mapPanelWidth + input$panoPanelWidth + input$formPanelWidth
      #print(paste0("TotalWidth: ",totalWidth))

      # Adjust panoPanelWidth to ensure the sum is 12
      if (totalWidth > 12) {
        excessWidth <- totalWidth - 12
        #print(paste0("excessWidth: ", excessWidth))
        # Calculate new value for panoPanelWidth, ensuring it does not fall below its minimum
        newPanoWidth <- max(3, input$panoPanelWidth - excessWidth)
        updateSliderInput(session, "panoPanelWidth", value = newPanoWidth)
        r$config["panoPanelWidth"] <- newPanoWidth  # Update server-side configuration
      } else if (totalWidth < 12) {
        missingWidth <- 12 - totalWidth
        #print(paste0("missingWidth: ", missingWidth))
        # Calculate new value for panoPanelWidth, ensuring it does not exceed its maximum
        newPanoWidth <- min(6, input$panoPanelWidth + missingWidth)
        updateSliderInput(session, "panoPanelWidth", value = newPanoWidth)
        r$config["panoPanelWidth"] <- newPanoWidth  # Update server-side configuration
      }

      # Save configuration after adjustment
      #save_user_config("mapPanelWidth")
      #save_user_config("panoPanelWidth")  # Save the panoPanelWidth if it was adjusted

      # Trigger SweetAlert confirmation popup
      shinyWidgets::confirmSweetAlert(
        session = session,
        inputId = ns("confirm_change"),
        title = "Resize Panels?",
        text = "Are you sure you want to change the panels layout? The page will reload",
        type = "warning",
        btn_labels = c("Cancel", "Confirm"),
        btn_colors = c("#B00225", "#2A52BE"),
        closeOnClickOutside = TRUE,
        showCloseButton = FALSE,
        allowEscapeKey = TRUE,
        cancelOnDismiss = TRUE,
        html = FALSE
      )
    })

    # Respond to SweetAlert confirmation
    observeEvent(input$confirm_change, {
      if (isTRUE(input$confirm_change)) {
        # If user clicked 'Yes', reload the session
        r$config["mapPanelWidth"] <- input$mapPanelWidth
        r$config["panoPanelWidth"] <- input$panoPanelWidth
        r$config["formPanelWidth"] <- input$formPanelWidth
        save_user_config("mapPanelWidth")
        save_user_config("panoPanelWidth")
        save_user_config("formPanelWidth")

        myEnv$config$mapPanelWidth <- input$mapPanelWidth
        myEnv$config$panoPanelWidth <- input$panoPanelWidth
        myEnv$config$formPanelWidth <- input$formPanelWidth
        shinyjs::delay(1000, session$reload())
        shinyjs::delay(2000, shinyjs::runjs('window.location.reload();'))
      } else {
        # If user clicked 'No', revert to the previous selection
      }
    })

    # observe for panoPanelWidth
    observeEvent(input$panoPanelWidth, ignoreInit = TRUE, {
      req(r$config)
      #r$config["panoPanelWidth"] <- input$panoPanelWidth

      # Calculate the total width of all panels
      totalWidth <- input$mapPanelWidth + input$panoPanelWidth + input$formPanelWidth
      #print(paste0("TotalWidth: ", totalWidth))

      # Adjust mapPanelWidth to ensure the sum is 12
      if (totalWidth > 12) {
        excessWidth <- totalWidth - 12
        #print(paste0("excessWidth: ", excessWidth))
        # Calculate new value for mapPanelWidth, ensuring it does not fall below its minimum
        newMapWidth <- max(3, input$mapPanelWidth - excessWidth)
        updateSliderInput(session, "mapPanelWidth", value = newMapWidth)
        r$config["mapPanelWidth"] <- newMapWidth  # Update server-side configuration
      } else if (totalWidth < 12) {
        missingWidth <- 12 - totalWidth
        #print(paste0("missingWidth: ", missingWidth))
        # Calculate new value for mapPanelWidth, ensuring it does not exceed its maximum
        newMapWidth <- min(6, input$mapPanelWidth + missingWidth)
        updateSliderInput(session, "mapPanelWidth", value = newMapWidth)
        r$config["mapPanelWidth"] <- newMapWidth  # Update server-side configuration
      }

      # Save configuration after adjustment
      #save_user_config("panoPanelWidth")
      #save_user_config("mapPanelWidth")  # Save the mapPanelWidth if it was adjusted
    })

    # observe for formPanelWidth
    observeEvent(input$formPanelWidth, ignoreInit = TRUE, {
      req(r$config)
      #r$config["formPanelWidth"] <- input$formPanelWidth

      # Calculate the total width of all panels
      totalWidth <- input$mapPanelWidth + input$panoPanelWidth + input$formPanelWidth
      #print(paste0("TotalWidth: ", totalWidth))

      # Adjust panoPanelWidth to ensure the sum is 12
      if (totalWidth > 12) {
        excessWidth <- totalWidth - 12
        #print(paste0("excessWidth: ", excessWidth))
        # Calculate new value for panoPanelWidth, ensuring it does not fall below its minimum
        newPanoWidth <- max(3, input$panoPanelWidth - excessWidth)
        updateSliderInput(session, "panoPanelWidth", value = newPanoWidth)
        r$config["panoPanelWidth"] <- newPanoWidth  # Update server-side configuration
      } else if (totalWidth < 12) {
        missingWidth <- 12 - totalWidth
        #print(paste0("missingWidth: ", missingWidth))
        # Calculate new value for panoPanelWidth, ensuring it does not exceed its maximum
        newPanoWidth <- min(6, input$panoPanelWidth + missingWidth)
        updateSliderInput(session, "panoPanelWidth", value = newPanoWidth)
        r$config["panoPanelWidth"] <- newPanoWidth  # Update server-side configuration
      }

      # Save configuration after adjustment
      #save_user_config("formPanelWidth")
      #save_user_config("panoPanelWidth")  # Save the panoPanelWidth if it was adjusted

      # Trigger SweetAlert confirmation popup
      shinyWidgets::confirmSweetAlert(
        session = session,
        inputId = ns("confirm_change"),
        title = "Resize Panels?",
        text = "Are you sure you want to change the panels layout? The page will reload",
        type = "warning",
        btn_labels = c("Cancel", "Confirm"),
        btn_colors = c("#B00225", "#2A52BE"),
        closeOnClickOutside = TRUE,
        showCloseButton = FALSE,
        allowEscapeKey = TRUE,
        cancelOnDismiss = TRUE,
        html = FALSE
      )
    })


    # map settings observers
    ##########################
    observeEvent(input$mapPanelSource, ignoreInit = TRUE, {
      req(r$config)
      r$config["mapPanelSource"] <- input$mapPanelSource
      #print("mapPanelSource changed")
      save_user_config("mapPanelSource")
    })

    observeEvent(input$mapIconColour, ignoreInit = TRUE, {
      req(r$config)
      r$config["mapIconColour"] <- input$mapIconColour
      #print("mapIconColour changed")
      save_user_config("mapIconColour")
    })

    observeEvent(input$mapMarkerColour, ignoreInit = TRUE, {
      req(r$config)
      r$config["mapMarkerColour"] <- input$mapMarkerColour
      #print("mapMarkerColour changed")
      save_user_config("mapMarkerColour")
    })

    observeEvent(input$mapPolygonStroke, ignoreInit = TRUE, {
      req(r$config)
      r$config["mapPolygonStroke"] <- input$mapPolygonStroke
      #print("mapPolygonStroke changed")
      save_user_config("mapPolygonStroke")
    })

    observeEvent(input$mapPolygonStrokeColour, ignoreInit = TRUE, {
      req(r$config)
      r$config["mapPolygonStrokeColour"] <- input$mapPolygonStrokeColour
      #print("mapPolygonStrokeColour changed")
      save_user_config("mapPolygonStrokeColour")
    })

    observeEvent(input$mapPolygonStrokeWeight, ignoreInit = TRUE, {
      req(r$config)
      r$config["mapPolygonStrokeWeight"] <- input$mapPolygonStrokeWeight
      #print("mapPolygonStrokeWeight changed")
      save_user_config("mapPolygonStrokeWeight")
    })

    observeEvent(input$mapPolygonStrokeOpacity, ignoreInit = TRUE, {
      req(r$config)
      r$config["mapPolygonStrokeOpacity"] <- input$mapPolygonStrokeOpacity
      #print("mapPolygonStrokeOpacity changed")
      save_user_config("mapPolygonStrokeOpacity")
    })

    observeEvent(input$mapPolygonFill, ignoreInit = TRUE, {
      req(r$config)
      r$config["mapPolygonFill"] <- input$mapPolygonFill
      #print("mapPolygonFill changed")
      save_user_config("mapPolygonFill")
    })

    observeEvent(input$mapPolygonFillColour, ignoreInit = TRUE, {
      req(r$config)
      r$config["mapPolygonFillColour"] <- input$mapPolygonFillColour
      #print("mapPolygonFillColour changed")
      save_user_config("mapPolygonFillColour")
    })

    observeEvent(input$mapPolygonFillOpacity, ignoreInit = TRUE, {
      req(r$config)
      r$config["mapPolygonFillOpacity"] <- input$mapPolygonFillOpacity
      #print("mapPolygonFillOpacity changed")
      save_user_config("mapPolygonFillOpacity")
    })

    #Pano 360 Panel observes
    ########################
    observeEvent(input$pano360IconColour, ignoreInit = TRUE, {
      req(r$config)
      r$config["pano360IconColour"] <- input$pano360IconColour
      #print("pano360IconColour changed")
      save_user_config("pano360IconColour")
    })

    observeEvent(input$pano360MarkerColour, ignoreInit = TRUE, {
      req(r$config)
      r$config["pano360MarkerColour"] <- input$pano360MarkerColour
      #print("pano360MarkerColour changed")
      save_user_config("pano360MarkerColour")
    })

    observeEvent(input$pano360PolygonStroke, ignoreInit = TRUE, {
      req(r$config)
      r$config["pano360PolygonStroke"] <- input$pano360PolygonStroke
      #print("pano360PolygonStroke changed")
      save_user_config("pano360PolygonStroke")
    })

    observeEvent(input$pano360PolygonStrokeColour, ignoreInit = TRUE, {
      req(r$config)
      r$config["pano360PolygonStrokeColour"] <- input$pano360PolygonStrokeColour
      #print("pano360PolygonStrokeColour changed")
      save_user_config("pano360PolygonStrokeColour")
    })

    observeEvent(input$pano360PolygonStrokeWeight, ignoreInit = TRUE, {
      req(r$config)
      r$config["pano360PolygonStrokeWeight"] <- input$pano360PolygonStrokeWeight
      #print("pano360PolygonStrokeWeight changed")
      save_user_config("pano360PolygonStrokeWeight")
    })

    observeEvent(input$pano360PolygonStrokeOpacity, ignoreInit = TRUE, {
      req(r$config)
      r$config["pano360PolygonStrokeOpacity"] <- input$pano360PolygonStrokeOpacity
      #print("pano360PolygonStrokeOpacity changed")
      save_user_config("pano360PolygonStrokeOpacity")
    })

    observeEvent(input$showPano360PolygonStrokeInCropExport, ignoreInit = TRUE, {
      req(r$config)
      r$config["showPano360PolygonStrokeInCropExport"] <- input$showPano360PolygonStrokeInCropExport
      #print("showPano360PolygonStrokeInCropExport changed")
      save_user_config("showPano360PolygonStrokeInCropExport")
    })

    observeEvent(input$pano360PolygonFill, ignoreInit = TRUE, {
      req(r$config)
      r$config["pano360PolygonFill"] <- input$pano360PolygonFill
      #print("pano360PolygonFill changed")
      save_user_config("pano360PolygonFill")
    })

    observeEvent(input$pano360PolygonFillColour, ignoreInit = TRUE, {
      req(r$config)
      r$config["pano360PolygonFillColour"] <- input$pano360PolygonFillColour
      #print("pano360PolygonFillColour changed")
      save_user_config("pano360PolygonFillColour")
    })

    observeEvent(input$pano360PolygonFillOpacity, ignoreInit = TRUE, {
      req(r$config)
      r$config["pano360PolygonFillOpacity"] <- input$pano360PolygonFillOpacity
      #print("pano360PolygonFillOpacity changed")
      save_user_config("pano360PolygonFillOpacity")
    })

    observeEvent(input$showPano360PolygonFillInCropExport, ignoreInit = TRUE, {
      req(r$config)
      r$config["showPano360PolygonFillInCropExport"] <- input$showPano360PolygonFillInCropExport
      #print("showPano360PolygonFillInCropExport changed")
      save_user_config("showPano360PolygonFillInCropExport")
    })

    #username lookups observer
    observeEvent(input$usernameLookupFile, ignoreInit = TRUE, {
      req(r$config)
      #r$config["usernameLookupFile"] <- paste0(input$usernameLookupFile$name)
      r$config["usernameLookupFile"] <- "username_lookup.csv"
      #print("usernameLookupFile changed")
      #print(input$usernameLookupFile$name)
      #print(input$usernameLookupFile$datapath)
      #file.copy(input$usernameLookupFile$datapath,file.path(paste0(app_sys("./extdata"),"/",input$usernameLookupFile$name)), overwrite = TRUE)
      new_path <- normalizePath(file.path(myEnv$data_dir, "/username_lookup.csv"), mustWork = FALSE)
      #print(new_path)
      file.copy(input$usernameLookupFile$datapath, new_path, overwrite = TRUE)
      save_user_config("usernameLookupFile")
    })

    observeEvent(input$exportFileFormat, ignoreInit = TRUE, {
      req(r$config)
      r$config["exportFileFormat"] <- input$exportFileFormat
      #print("mapPanelSource changed")
      save_user_config("exportFileFormat")
    })

    # look ups settings observers
    #############################
    observeEvent(input$lookup1Label, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup1Label"] <- input$lookup1Label
      #print("lookup1Label changed")
      save_user_config("lookup1Label")
    })

    observeEvent(input$lookup1CsvFile, ignoreInit = TRUE, {
      req(r$config)
      #r$config["lookup1CsvFile"] <- paste0(input$lookup1CsvFile$name)
      r$config["lookup1CsvFile"] <- "lookup1.csv"
      #print("usernameLookupFile changed")
      #print(input$lookup1CsvFile$datapath) #print(input$lookup1CsvFile$name)
      file.copy(input$lookup1CsvFile$datapath, normalizePath(paste0(myEnv$data_dir, "/lookup1.csv")), overwrite = TRUE)
      save_user_config("lookup1CsvFile")
    })

    observeEvent(input$lookup1HelpFile, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup1HelpFile"] <- "help1.pdf"
      file.copy(input$lookup1HelpFile$datapath, normalizePath(paste0(myEnv$data_dir, "/help1.pdf")), overwrite = TRUE)
      file.copy(input$lookup1HelpFile$datapath, file.path(tempdir(), "help1.pdf"), overwrite = TRUE)
      save_user_config("lookup1HelpFile")
    })

    observeEvent(input$lookup2Enabled, {
      req(r$config)
      r$config["lookup2Enabled"] <- input$lookup2Enabled
      #print("lookup2Enabled changed")
      save_user_config("lookup2Enabled")
      if(r$config["lookup2Enabled"] == TRUE){
        shinyjs::enable("lookup2Label")
        shinyjs::enable("lookup2CsvFile")
        shinyjs::enable("lookup2HelpFile")
        shinyjs::show("lookup2Label")
        shinyjs::show("lookup2CsvFile")
        shinyjs::show("lookup2HelpFile")
      } else {
        shinyjs::disable("lookup2Label")
        shinyjs::disable("lookup2CsvFile")
        shinyjs::disable("lookup2HelpFile")
        shinyjs::hide("lookup2Label")
        shinyjs::hide("lookup2CsvFile")
        shinyjs::hide("lookup2HelpFile")
      }
    })

    observeEvent(input$lookup2Label, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup2Label"] <- input$lookup2Label
      #print("lookup2Label changed")
      save_user_config("lookup2Label")
    })

    observeEvent(input$lookup2CsvFile, ignoreInit = TRUE, {
      req(r$config)
      #r$config["lookup2CsvFile"] <- input$lookup2CsvFile$name
      r$config["lookup2CsvFile"] <- "lookup2.csv"
      #print("Lookup2CsvFile changed") #print(input$lookup2CsvFile$datapath)
      file.copy(input$lookup2CsvFile$datapath, normalizePath(paste0(myEnv$data_dir, "/lookup2.csv")), overwrite = TRUE)
      save_user_config("lookup2CsvFile")
    })

    observeEvent(input$lookup2HelpFile, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup2HelpFile"] <- "help2.pdf"
      file.copy(input$lookup2HelpFile$datapath, normalizePath(paste0(myEnv$data_dir, "/help2.pdf")), overwrite = TRUE)
      file.copy(input$lookup2HelpFile$datapath, file.path(tempdir(), "help2.pdf"), overwrite = TRUE)
      save_user_config("lookup2HelpFile")
    })

    observeEvent(input$lookup3Enabled, {
      req(r$config)
      r$config["lookup3Enabled"] <- input$lookup3Enabled
      #print("lookup3Enabled changed")
      save_user_config("lookup3Enabled")
      if(r$config["lookup3Enabled"] == TRUE){
        shinyjs::enable("lookup3Label")
        shinyjs::enable("lookup3CsvFile")
        shinyjs::enable("lookup3HelpFile")
        shinyjs::show("lookup3Label")
        shinyjs::show("lookup3CsvFile")
        shinyjs::show("lookup3HelpFile")
      } else {
        shinyjs::disable("lookup3Label")
        shinyjs::disable("lookup3CsvFile")
        shinyjs::disable("lookup3HelpFile")
        shinyjs::hide("lookup3Label")
        shinyjs::hide("lookup3CsvFile")
        shinyjs::hide("lookup3HelpFile")
      }
    })

    observeEvent(input$lookup3Label, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup3Label"] <- input$lookup3Label
      #print("lookup3Label changed")
      save_user_config("lookup3Label")
    })

    observeEvent(input$lookup3CsvFile, ignoreInit = TRUE, {
      req(r$config)
      #r$config["lookup3CsvFile"] <- input$lookup3CsvFile$name
      r$config["lookup3CsvFile"] <- "lookup3.csv"
      #print("Lookup3CsvFile changed") #print(input$lookup3CsvFile$datapath)
      file.copy(input$lookup3CsvFile$datapath, normalizePath(paste0(myEnv$data_dir, "/lookup3.csv")), overwrite = TRUE)
      save_user_config("lookup3CsvFile")
    })

    observeEvent(input$lookup3HelpFile, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup3HelpFile"] <- "help3.pdf"
      file.copy(input$lookup3HelpFile$datapath, normalizePath(paste0(myEnv$data_dir, "/help3.pdf")), overwrite = TRUE)
      file.copy(input$lookup3HelpFile$datapath, file.path(tempdir(), "help3.pdf"), overwrite = TRUE)
      save_user_config("lookup3HelpFile")
    })

    observeEvent(input$lookup4Enabled, {
      req(r$config)
      r$config["lookup4Enabled"] <- input$lookup4Enabled
      #print("lookup4Enabled changed")
      save_user_config("lookup4Enabled")
      if(r$config["lookup4Enabled"] == TRUE){
        shinyjs::enable("lookup4Label")
        shinyjs::enable("lookup4CsvFile")
        shinyjs::enable("lookup4HelpFile")
        shinyjs::show("lookup4Label")
        shinyjs::show("lookup4CsvFile")
        shinyjs::show("lookup4HelpFile")
        shinyjs::show("lookup4HelpFilePath")
      } else {
        shinyjs::disable("lookup4Label")
        shinyjs::disable("lookup4CsvFile")
        shinyjs::disable("lookup4HelpFile")
        shinyjs::hide("lookup4Label")
        shinyjs::hide("lookup4CsvFile")
        shinyjs::hide("lookup4HelpFile")
        shinyjs::hide("lookup4HelpFilePath")
      }
    })

    observeEvent(input$lookup4Label, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup4Label"] <- input$lookup4Label
      #print("lookup4Label changed")
      save_user_config("lookup4Label")
    })

    observeEvent(input$lookup4CsvFile, ignoreInit = TRUE, {
      req(r$config)
      #r$config["lookup4CsvFile"] <- input$lookup4CsvFile$name
      r$config["lookup4CsvFile"] <- "lookup4.csv"
      #print("Lookup4CsvFile changed") #print(input$lookup4CsvFile$datapath)
      file.copy(input$lookup4CsvFile$datapath, normalizePath(paste0(myEnv$data_dir, "/lookup4.csv")), overwrite = TRUE)
      save_user_config("lookup4CsvFile")
    })

    observeEvent(input$lookup4HelpFile, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup4HelpFile"] <- "help4.pdf"
      file.copy(input$lookup4HelpFile$datapath, normalizePath(paste0(myEnv$data_dir, "/help4.pdf")), overwrite = TRUE)
      file.copy(input$lookup4HelpFile$datapath, file.path(tempdir(), "help4.pdf"), overwrite = TRUE)
      save_user_config("lookup4HelpFile")
    })

    observeEvent(input$lookup5Enabled, {
      req(r$config)
      r$config["lookup5Enabled"] <- input$lookup5Enabled
      save_user_config("lookup5Enabled")
      if(r$config["lookup5Enabled"] == TRUE){
        shinyjs::enable("lookup5Label")
        shinyjs::enable("lookup5CsvFile")
        shinyjs::enable("lookup5HelpFile")
        shinyjs::show("lookup5Label")
        shinyjs::show("lookup5CsvFile")
        shinyjs::show("lookup5HelpFile")
        shinyjs::show("lookup5HelpFilePath")
      } else {
        shinyjs::disable("lookup5Label")
        shinyjs::disable("lookup5CsvFile")
        shinyjs::disable("lookup5HelpFile")
        shinyjs::hide("lookup5Label")
        shinyjs::hide("lookup5CsvFile")
        shinyjs::hide("lookup5HelpFile")
        shinyjs::hide("lookup5HelpFilePath")
      }
    })

    observeEvent(input$lookup5Label, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup5Label"] <- input$lookup5Label
      save_user_config("lookup5Label")
    })

    observeEvent(input$lookup5CsvFile, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup5CsvFile"] <- "lookup5.csv"
      file.copy(input$lookup5CsvFile$datapath, normalizePath(paste0(myEnv$data_dir, "/lookup5.csv")), overwrite = TRUE)
      save_user_config("lookup5CsvFile")
    })

    observeEvent(input$lookup5HelpFile, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup5HelpFile"] <- "help5.pdf"
      file.copy(input$lookup5HelpFile$datapath, normalizePath(paste0(myEnv$data_dir, "/help5.pdf")), overwrite = TRUE)
      file.copy(input$lookup5HelpFile$datapath, file.path(tempdir(), "help5.pdf"), overwrite = TRUE)
      save_user_config("lookup5HelpFile")
    })

    observeEvent(input$lookup6Enabled, {
      req(r$config)
      r$config["lookup6Enabled"] <- input$lookup6Enabled
      save_user_config("lookup6Enabled")
      if(r$config["lookup6Enabled"] == TRUE){
        shinyjs::enable("lookup6Label")
        shinyjs::enable("lookup6CsvFile")
        shinyjs::enable("lookup6HelpFile")
        shinyjs::show("lookup6Label")
        shinyjs::show("lookup6CsvFile")
        shinyjs::show("lookup6HelpFile")
        shinyjs::show("lookup6HelpFilePath")
      } else {
        shinyjs::disable("lookup6Label")
        shinyjs::disable("lookup6CsvFile")
        shinyjs::disable("lookup6HelpFile")
        shinyjs::hide("lookup6Label")
        shinyjs::hide("lookup6CsvFile")
        shinyjs::hide("lookup6HelpFile")
        shinyjs::hide("lookup6HelpFilePath")
      }
    })

    observeEvent(input$lookup6Label, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup6Label"] <- input$lookup6Label
      save_user_config("lookup6Label")
    })

    observeEvent(input$lookup6CsvFile, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup6CsvFile"] <- "lookup6.csv"
      file.copy(input$lookup6CsvFile$datapath, normalizePath(paste0(myEnv$data_dir, "/lookup6.csv")), overwrite = TRUE)
      save_user_config("lookup6CsvFile")
    })

    observeEvent(input$lookup6HelpFile, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup6HelpFile"] <- "help6.pdf"
      file.copy(input$lookup6HelpFile$datapath, normalizePath(paste0(myEnv$data_dir, "/help6.pdf")), overwrite = TRUE)
      file.copy(input$lookup6HelpFile$datapath, file.path(tempdir(), "help6.pdf"), overwrite = TRUE)
      save_user_config("lookup6HelpFile")
    })

    observeEvent(input$lookup7Enabled, {
      req(r$config)
      r$config["lookup7Enabled"] <- input$lookup7Enabled
      save_user_config("lookup7Enabled")
      if(r$config["lookup7Enabled"] == TRUE){
        shinyjs::enable("lookup7Label")
        shinyjs::enable("lookup7CsvFile")
        shinyjs::enable("lookup7HelpFile")
        shinyjs::show("lookup7Label")
        shinyjs::show("lookup7CsvFile")
        shinyjs::show("lookup7HelpFile")
        shinyjs::show("lookup7HelpFilePath")
      } else {
        shinyjs::disable("lookup7Label")
        shinyjs::disable("lookup7CsvFile")
        shinyjs::disable("lookup7HelpFile")
        shinyjs::hide("lookup7Label")
        shinyjs::hide("lookup7CsvFile")
        shinyjs::hide("lookup7HelpFile")
        shinyjs::hide("lookup7HelpFilePath")
      }
    })

    observeEvent(input$lookup7Label, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup7Label"] <- input$lookup7Label
      save_user_config("lookup7Label")
    })

    observeEvent(input$lookup7CsvFile, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup7CsvFile"] <- "lookup7.csv"
      file.copy(input$lookup7CsvFile$datapath, normalizePath(paste0(myEnv$data_dir, "/lookup7.csv")), overwrite = TRUE)
      save_user_config("lookup7CsvFile")
    })

    observeEvent(input$lookup7HelpFile, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup7HelpFile"] <- "help7.pdf"
      file.copy(input$lookup7HelpFile$datapath, normalizePath(paste0(myEnv$data_dir, "/help7.pdf")), overwrite = TRUE)
      file.copy(input$lookup7HelpFile$datapath, file.path(tempdir(), "help7.pdf"), overwrite = TRUE)
      save_user_config("lookup7HelpFile")
    })

    # TextInput toggle observers for lookups 1-7
    observeEvent(input$lookup1TextInput, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup1TextInput"] <- input$lookup1TextInput
      myEnv$config$lookup1TextInput <- input$lookup1TextInput
      save_user_config("lookup1TextInput")
      if(isTRUE(input$lookup1TextInput)){
        shinyjs::hide("lookup1CsvFile")
        shinyjs::hide("lookup1HelpFile")
      } else {
        shinyjs::show("lookup1CsvFile")
        shinyjs::show("lookup1HelpFile")
      }
    })

    observeEvent(input$lookup2TextInput, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup2TextInput"] <- input$lookup2TextInput
      myEnv$config$lookup2TextInput <- input$lookup2TextInput
      save_user_config("lookup2TextInput")
      if(isTRUE(input$lookup2TextInput)){
        shinyjs::hide("lookup2CsvFile")
        shinyjs::hide("lookup2HelpFile")
      } else {
        shinyjs::show("lookup2CsvFile")
        shinyjs::show("lookup2HelpFile")
      }
    })

    observeEvent(input$lookup3TextInput, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup3TextInput"] <- input$lookup3TextInput
      myEnv$config$lookup3TextInput <- input$lookup3TextInput
      save_user_config("lookup3TextInput")
      if(isTRUE(input$lookup3TextInput)){
        shinyjs::hide("lookup3CsvFile")
        shinyjs::hide("lookup3HelpFile")
      } else {
        shinyjs::show("lookup3CsvFile")
        shinyjs::show("lookup3HelpFile")
      }
    })

    observeEvent(input$lookup4TextInput, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup4TextInput"] <- input$lookup4TextInput
      myEnv$config$lookup4TextInput <- input$lookup4TextInput
      save_user_config("lookup4TextInput")
      if(isTRUE(input$lookup4TextInput)){
        shinyjs::hide("lookup4CsvFile")
        shinyjs::hide("lookup4HelpFile")
      } else {
        shinyjs::show("lookup4CsvFile")
        shinyjs::show("lookup4HelpFile")
      }
    })

    observeEvent(input$lookup5TextInput, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup5TextInput"] <- input$lookup5TextInput
      myEnv$config$lookup5TextInput <- input$lookup5TextInput
      save_user_config("lookup5TextInput")
      if(isTRUE(input$lookup5TextInput)){
        shinyjs::hide("lookup5CsvFile")
        shinyjs::hide("lookup5HelpFile")
      } else {
        shinyjs::show("lookup5CsvFile")
        shinyjs::show("lookup5HelpFile")
      }
    })

    observeEvent(input$lookup6TextInput, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup6TextInput"] <- input$lookup6TextInput
      myEnv$config$lookup6TextInput <- input$lookup6TextInput
      save_user_config("lookup6TextInput")
      if(isTRUE(input$lookup6TextInput)){
        shinyjs::hide("lookup6CsvFile")
        shinyjs::hide("lookup6HelpFile")
      } else {
        shinyjs::show("lookup6CsvFile")
        shinyjs::show("lookup6HelpFile")
      }
    })

    observeEvent(input$lookup7TextInput, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup7TextInput"] <- input$lookup7TextInput
      myEnv$config$lookup7TextInput <- input$lookup7TextInput
      save_user_config("lookup7TextInput")
      if(isTRUE(input$lookup7TextInput)){
        shinyjs::hide("lookup7CsvFile")
        shinyjs::hide("lookup7HelpFile")
      } else {
        shinyjs::show("lookup7CsvFile")
        shinyjs::show("lookup7HelpFile")
      }
    })

    observeEvent(input$lookup8Enabled, {
      req(r$config)
      r$config["lookup8Enabled"] <- input$lookup8Enabled
      save_user_config("lookup8Enabled")
      if(r$config["lookup8Enabled"] == TRUE){
        shinyjs::enable("lookup8Label")
        shinyjs::enable("lookup8CsvFile")
        shinyjs::enable("lookup8HelpFile")
        shinyjs::show("lookup8Label")
        shinyjs::show("lookup8CsvFile")
        shinyjs::show("lookup8HelpFile")
        shinyjs::show("lookup8HelpFilePath")
      } else {
        shinyjs::disable("lookup8Label")
        shinyjs::disable("lookup8CsvFile")
        shinyjs::disable("lookup8HelpFile")
        shinyjs::hide("lookup8Label")
        shinyjs::hide("lookup8CsvFile")
        shinyjs::hide("lookup8HelpFile")
        shinyjs::hide("lookup8HelpFilePath")
      }
    })

    observeEvent(input$lookup8Label, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup8Label"] <- input$lookup8Label
      save_user_config("lookup8Label")
    })

    observeEvent(input$lookup8CsvFile, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup8CsvFile"] <- "lookup8.csv"
      file.copy(input$lookup8CsvFile$datapath, normalizePath(paste0(myEnv$data_dir, "/lookup8.csv")), overwrite = TRUE)
      save_user_config("lookup8CsvFile")
    })

    observeEvent(input$lookup8HelpFile, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup8HelpFile"] <- "help8.pdf"
      file.copy(input$lookup8HelpFile$datapath, normalizePath(paste0(myEnv$data_dir, "/help8.pdf")), overwrite = TRUE)
      file.copy(input$lookup8HelpFile$datapath, file.path(tempdir(), "help8.pdf"), overwrite = TRUE)
      save_user_config("lookup8HelpFile")
    })

    observeEvent(input$lookup8TextInput, ignoreInit = TRUE, {
      req(r$config)
      r$config["lookup8TextInput"] <- input$lookup8TextInput
      myEnv$config$lookup8TextInput <- input$lookup8TextInput
      save_user_config("lookup8TextInput")
      if(isTRUE(input$lookup8TextInput)){
        shinyjs::hide("lookup8CsvFile")
        shinyjs::hide("lookup8HelpFile")
      } else {
        shinyjs::show("lookup8CsvFile")
        shinyjs::show("lookup8HelpFile")
      }
    })

    # end settings panels observers
    ####################################

    # Delete Help PDF handlers
    lapply(1:8, function(i) {
      observeEvent(input[[paste0("lookup", i, "HelpFileDelete")]], {
        help_pdf <- normalizePath(paste0(myEnv$data_dir, "/help", i, ".pdf"), mustWork = FALSE)
        help_pdf_temp <- file.path(tempdir(), paste0("help", i, ".pdf"))
        if (file.exists(help_pdf)) {
          file.remove(help_pdf)
          if (file.exists(help_pdf_temp)) file.remove(help_pdf_temp)
          r$config[[paste0("lookup", i, "HelpFile")]] <- ""
          save_user_config(paste0("lookup", i, "HelpFile"))
          shinyWidgets::show_alert(
            title = "Deleted",
            text = paste0("Help PDF for Lookup ", i, " has been removed."),
            type = "success"
          )
        } else {
          shinyWidgets::show_alert(
            title = "Not Found",
            text = paste0("No Help PDF exists for Lookup ", i, "."),
            type = "info"
          )
        }
      })
    })

    #add new whole image annotation record button clicked
    observe({
      #print("add a whole image annotation clicked")
      req(r$current_image, r$current_image_metadata, r$user_name)

      myId <- gsub("\\.", "",format(Sys.time(), "%Y%m%d-%H%M%OS3"))
      geomType <- "Point-whole-image-annotation"
      lat <- if (!is.null(r$current_image_metadata$GPSLatitude)) r$current_image_metadata$GPSLatitude else 0
      long <- if (!is.null(r$current_image_metadata$GPSLongitude)) r$current_image_metadata$GPSLongitude else 0
      geom <- paste0("POINT(", long, " ", lat, ")")
      #
      feature <- list(
        type = "Feature",
        geometry = list(
          type = "Point",
          coordinates = c(long, lat)
        ),
        properties = list(
          id = myId,
          layerId = myId,
          edit_id = myId,
          feature_type = geomType
        )
      )

      r$new_leafletMap_item <- feature

    }) %>% bindEvent(input$add_whole_image_annotation)

    # when new map item added, listening for both button clicked in form OR item drawn in map panel
    observe({
      #print("new map item added: mod_control_form")

      #str <- sprintf("new feature with layerId: %s", r$new_leafletMap_item)
      #print(str)

      # Convert the feature with the new ID to a sf object
      myMarker <- geojsonsf::geojson_sf(jsonify::to_json(r$new_leafletMap_item, unbox = TRUE, digits=9))
      geom <- sf::st_as_text(myMarker$geometry, digits=9)
      geomType <- r$new_leafletMap_item$properties$feature_type

      # Pre-fill dd values from Quick Fill fields based on lookup label matching
      quick_dd <- replicate(8, NA, simplify = FALSE)
      quick_vals <- list(
        "Wind Turbine Number" = trimws(input$quick_wt %||% ""),
        "Blade Number" = trimws(input$quick_blade %||% ""),
        "Chamber Number" = trimws(input$quick_chamber %||% "")
      )
      for (i in 1:8) {
        lbl <- myEnv$config[[paste0("lookup", i, "Label")]]
        if (!is.null(lbl) && lbl %in% names(quick_vals) && nchar(quick_vals[[lbl]]) > 0) {
          quick_dd[[i]] <- quick_vals[[lbl]]
        }
      }

      # add annotations form and update the active annotations list
      add_annotations_form(
        input = input,
        myActiveAnnotations = r$active_annotations,
        myId = r$new_leafletMap_item$properties$id,
        #myLeafletId = r$new_leafletMap_item$properties$id,
        myFeatureType = geomType,
        myGeometry = geom,
        myRadius = NA,
        myDD1 = quick_dd[[1]],
        myDD2 = quick_dd[[2]],
        myDD3 = quick_dd[[3]],
        myDD4 = quick_dd[[4]],
        myDD5 = quick_dd[[5]],
        myDD6 = quick_dd[[6]],
        myDD7 = quick_dd[[7]],
        myDD8 = quick_dd[[8]]
      )

    }) %>% bindEvent(r$new_leafletMap_item)

    # when new 360 item added, listening for drawing in 360 panel
    observe({
      #print("new 360 item added: mod_control_form")

      #str <- sprintf("new feature with layerId: %s", r$new_leaflet360_item)
      #print(str)

      # Convert the feature with the new ID to a sf object
      myMarker <- geojsonsf::geojson_sf(jsonify::to_json(r$new_leaflet360_item, unbox = TRUE, digits=9))
      geom <- sf::st_as_text(myMarker$geometry, digits=9)
      geomType <- r$new_leaflet360_item$properties$feature_type

      # Pre-fill dd values from Quick Fill fields based on lookup label matching
      quick_dd <- replicate(8, NA, simplify = FALSE)
      quick_vals <- list(
        "Wind Turbine Number" = trimws(input$quick_wt %||% ""),
        "Blade Number" = trimws(input$quick_blade %||% ""),
        "Chamber Number" = trimws(input$quick_chamber %||% "")
      )
      for (i in 1:8) {
        lbl <- myEnv$config[[paste0("lookup", i, "Label")]]
        if (!is.null(lbl) && lbl %in% names(quick_vals) && nchar(quick_vals[[lbl]]) > 0) {
          quick_dd[[i]] <- quick_vals[[lbl]]
        }
      }

      # add annotations form and update the active annotations list
      add_annotations_form(
        input = input,
        myActiveAnnotations = r$active_annotations,
        myId = r$new_leaflet360_item$properties$id,
        #myLeafletId = r$new_leaflet360_item$properties$id,
        myFeatureType = geomType,
        myGeometry = geom,
        myRadius = NA,
        myDD1 = quick_dd[[1]],
        myDD2 = quick_dd[[2]],
        myDD3 = quick_dd[[3]],
        myDD4 = quick_dd[[4]],
        myDD5 = quick_dd[[5]],
        myDD6 = quick_dd[[6]],
        myDD7 = quick_dd[[7]],
        myDD8 = quick_dd[[8]]
      )

    }) %>% bindEvent(r$new_leaflet360_item)

    # when save annotations button is clicked
    # observe({
    #     print("save annotations clicked")
    #     req(r$user_annotations_data, r$user_annotations_file_name)
    #     save_annotations(myAnnotations=r$user_annotations_data, myAnnotationFileName = r$user_annotations_file_name)
    #  if(myEnv$config$showPopupAlerts == TRUE){
    #if(myEnv$config$showPopupAlerts == TRUE){
    #     shinyWidgets::show_alert(
    #       title = "Annotation Saved!",
    #       text = "Awesome, saved the annotation, select another image and annotate it.",
    #       type = "success"
    #     )
    #}
    #  }
    #
    # }) %>% bindEvent(input$save_annotations)


    #######################################

    #check if there are any annotations for a selected image already
    observe({
      #print("current image changed: mod_control_form")
      req(r$user_annotations_data, r$current_image)

      save_annotations(myAnnotations=r$user_annotations_data, myAnnotationFileName = r$user_annotations_file_name)
      clear_annotations_form()

      previous_annotations <- check_for_annotations(r$user_annotations_data, r$current_image)

      if(nrow(previous_annotations > 1)){
        #print("annotations already exist")
        for(i in 1:nrow(previous_annotations)){
          #View(previous_annotations)
          add_annotations_form(input=input, myActiveAnnotations=r$active_annotations, myId=previous_annotations[i, "id"], myFeatureType=previous_annotations[i, "feature_type"], myRadius=previous_annotations[i, "radius"], myGeometry= previous_annotations[i, "geometry"], myDD1= previous_annotations[i, "dd1"],myDD2= previous_annotations[i, "dd2"], myDD3=previous_annotations[i, "dd3"], myDD4=previous_annotations[i, "dd4"], myDD5=previous_annotations[i, "dd5"], myDD6=previous_annotations[i, "dd6"], myDD7=previous_annotations[i, "dd7"], myDD8=previous_annotations[i, "dd8"])
        }

        if(myEnv$config$showPopupAlerts == TRUE){
          #tell the user annotations already exist
          shinyWidgets::show_alert(
            title = "Annotations Already Exist!",
            text = "It looks like you've already done this one :) I've loaded that data....",
            type = "info"
          )
        }

      }
    }) %>% bindEvent(r$current_image)

    # refresh_the form triggered when the apply settings button is clicked and user changes settings
    observe({
      #print("refresh_for_item: control_form")
      req(r$refresh_user_config, r$user_annotations_data, r$current_image)

      #req(r$user_annotations_data, r$current_image)

      #call the functions to create the icons using the colours etc from the settings panel
      myEnv$mapIcons <- create_map_icons()
      myEnv$formIcons <- create_form_icons()

      save_annotations(myAnnotations=r$user_annotations_data, myAnnotationFileName = r$user_annotations_file_name)
      clear_annotations_form()

      previous_annotations <- check_for_annotations(r$user_annotations_data, r$current_image)

      if(nrow(previous_annotations > 1)){
        #print("annotations already exist")
        for(i in 1:nrow(previous_annotations)){
          #View(previous_annotations)
          add_annotations_form(input=input, myActiveAnnotations=r$active_annotations, myId=previous_annotations[i, "id"], myFeatureType=previous_annotations[i, "feature_type"], myRadius=previous_annotations[i, "radius"], myGeometry= previous_annotations[i, "geometry"], myDD1= previous_annotations[i, "dd1"],myDD2= previous_annotations[i, "dd2"], myDD3=previous_annotations[i, "dd3"], myDD4=previous_annotations[i, "dd4"], myDD5=previous_annotations[i, "dd5"], myDD6=previous_annotations[i, "dd6"], myDD7=previous_annotations[i, "dd7"], myDD8=previous_annotations[i, "dd8"])
        }

      }


    }) %>% bindEvent(r$refresh_user_config)


  })
}

## To be copied in the UI
# mod_control_form_ui("control_form")

## To be copied in the server
# mod_control_form_server("control_form")
