#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  shinyhelper::observe_helpers(help_dir = app_sys("/app/www/helpfiles"))
  session_temp_dir <- normalizePath(
    file.path(tempdir(), "blt_sessions", session$token),
    mustWork = FALSE
  )
  r <- create_session_state(session$token, config = myEnv$config)

  auth <- reactiveValues(
    authenticated = FALSE,
    error = NULL,
    display_name = NULL,
    login = NULL,
    role = NULL,
    annotation_value = NULL,
    lock_claimed = FALSE,
    restore_token = NULL
  )
  auth_session_timeout_secs <- 10 * 60
  modules_initialized <- reactiveVal(FALSE)
  session$userData$auth <- auth
  session$userData$r <- r

  normalize_input_value <- function(value) {
    if (is.null(value) || length(value) == 0 || is.na(value[[1]])) {
      return("")
    }

    trimws(as.character(value[[1]]))
  }

  set_client_role_class <- function(role = NULL) {
    normalized_role <- gsub(
      "[^a-z0-9_-]",
      "",
      tolower(normalize_input_value(role))
    )

    role_classes <- c("blt-role-admin", "blt-role-user")
    remove_js <- paste0(
      "document.documentElement.classList.remove(",
      paste(sprintf("'%s'", role_classes), collapse = ", "),
      ");"
    )
    add_js <- ""
    if (nzchar(normalized_role)) {
      add_js <- paste0(
        "document.documentElement.classList.add('blt-role-",
        normalized_role,
        "');"
      )
    }

    shinyjs::runjs(paste0(remove_js, add_js))
  }

  load_shared_config <- function() {
    latest_config <- apply_config_defaults(configr::read.config(myEnv$project_config_file))
    myEnv$config <- latest_config
    r$config <- latest_config
    invisible(latest_config)
  }

  apply_shared_config_signal <- function(signal_payload) {
    load_shared_config()

    if (!isTRUE(auth$authenticated)) {
      return(invisible(FALSE))
    }

    signal_mode <- normalize_input_value(signal_payload$mode)
    if (identical(signal_mode, "reload")) {
      shinyjs::runjs("window.location.reload();")
      return(invisible(TRUE))
    }

    if (isTRUE(modules_initialized())) {
      refresh_user_config(session, r)
    }

    invisible(TRUE)
  }

  load_shared_config()

  last_config_refresh_token <- reactiveVal(
    normalize_input_value(
      read_config_refresh_signal(project_config_file = myEnv$project_config_file)$token
    )
  )
  config_refresh_signal <- reactiveFileReader(
    intervalMillis = 1000,
    session = session,
    filePath = function() {
      ensure_config_refresh_signal(project_config_file = myEnv$project_config_file)
    },
    readFunc = function(path) {
      read_config_refresh_signal(project_config_file = myEnv$project_config_file)
    }
  )

  observe({
    role_value <- NULL
    if (isTRUE(auth$authenticated)) {
      role_value <- auth$role
    }

    set_client_role_class(role_value)
  })

  observeEvent(config_refresh_signal(), ignoreInit = TRUE, {
    signal_payload <- config_refresh_signal()
    signal_token <- normalize_input_value(signal_payload$token)
    signal_origin_session_token <- normalize_input_value(signal_payload$origin_session_token)
    signal_include_origin <- isTRUE(signal_payload$include_origin)

    if (!nzchar(signal_token) || identical(signal_token, last_config_refresh_token())) {
      return(invisible(NULL))
    }

    last_config_refresh_token(signal_token)

    if (identical(signal_origin_session_token, session$token) && !isTRUE(signal_include_origin)) {
      return(invisible(NULL))
    }

    apply_shared_config_signal(signal_payload)
  })

  get_auth_tab_id <- function() {
    auth_tab_id <- normalize_input_value(input$auth_tab_id)
    if (!nzchar(auth_tab_id)) {
      auth_tab_id <- paste0("session-", session$token)
    }

    auth_tab_id
  }

  set_workspace_for_tab <- function(tab_id = get_auth_tab_id()) {
    normalized_tab_id <- normalize_input_value(tab_id)
    if (!nzchar(normalized_tab_id)) {
      return(invisible(FALSE))
    }

    set_session_workspace(r, normalized_tab_id)
    invisible(TRUE)
  }

  persist_workspace_context <- function() {
    workspace_id <- normalize_input_value(r$session_workspace_id)
    if (!nzchar(workspace_id)) {
      return(invisible(FALSE))
    }

    update_session_workspace_state(
      workspace_id,
      current_image = normalize_input_value(r$current_image)
    )

    invisible(TRUE)
  }

  restore_workspace_context <- function() {
    workspace_id <- normalize_input_value(r$session_workspace_id)
    session_files_dir <- normalize_input_value(r$session_files_dir)

    if (!nzchar(workspace_id) || !nzchar(session_files_dir) || !dir.exists(session_files_dir)) {
      return(invisible(FALSE))
    }

    restored_images <- get_image_files(session_files_dir)
    if (length(restored_images) == 0) {
      return(invisible(FALSE))
    }

    r$imgs_lst <- restored_images
    r$imgs_metadata <- load_image_metadata(session_files_dir)

    workspace_state <- read_session_workspace_state(workspace_id)
    restored_image <- normalize_input_value(workspace_state$current_image)
    if (!restored_image %in% restored_images) {
      restored_image <- restored_images[[1]]
    }

    r$current_image <- restored_image
    r$current_image_metadata <- get_image_metadata(r$imgs_metadata, restored_image)
    golem::invoke_js("showid", "image_panel")
    persist_workspace_context()

    invisible(TRUE)
  }

  clear_workspace_context <- function() {
    workspace_id <- normalize_input_value(r$session_workspace_id)
    if (nzchar(workspace_id)) {
      clear_session_workspace(workspace_id)
    }

    r$imgs_lst <- NULL
    r$imgs_metadata <- NULL
    r$current_image <- NULL
    r$current_image_metadata <- NULL

    invisible(TRUE)
  }

  release_authenticated_lock <- function() {
    if (!isTRUE(auth$lock_claimed) || !nzchar(normalize_input_value(auth$login))) {
      return(invisible(FALSE))
    }

    release_result <- release_auth_session_lock(
      auth$login,
      session$token,
      tab_id = get_auth_tab_id()
    )
    if (isTRUE(release_result)) {
      auth$lock_claimed <- FALSE
    }

    invisible(release_result)
  }

  session$onSessionEnded(function() {
    release_authenticated_lock()
    if (!is.null(session_temp_dir) && dir.exists(session_temp_dir)) {
      unlink(session_temp_dir, recursive = TRUE, force = TRUE)
    }
  })

  show_auth_error <- function(message, reset_password = FALSE) {
    auth$error <- normalize_input_value(message)

    if (isTRUE(reset_password)) {
      updateTextInput(session, "auth_password", value = "")
    }
  }

  sync_client_auth_session <- function(action = c("save", "clear")) {
    action <- match.arg(action)

    if (identical(action, "clear")) {
      session$sendCustomMessage("blt-auth-session", list(action = "clear"))
      return(invisible(NULL))
    }

    if (!isTRUE(auth$authenticated) || !nzchar(normalize_input_value(auth$restore_token))) {
      return(invisible(NULL))
    }

    session$sendCustomMessage(
      "blt-auth-session",
      list(
        action = "save",
        state = list(
          login = auth$login,
          display_name = auth$display_name,
          role = auth$role,
          annotation_value = auth$annotation_value,
          restore_token = auth$restore_token,
          tab_id = get_auth_tab_id(),
          inactivity_timeout_ms = auth_session_timeout_secs * 1000
        )
      )
    )

    invisible(NULL)
  }

  initialize_modules <- function() {
    if (isTRUE(modules_initialized())) {
      return(invisible(NULL))
    }

    mod_control_form_server("control_form", r)
    mod_leaflet_map_server("leaflet_map", r, map_enabled = FALSE)
    mod_360_image_server("pano360_image", r)
    modules_initialized(TRUE)

    invisible(NULL)
  }

  activate_authenticated_session <- function(validated_user, restore_token, clear_password = TRUE) {
    auth$display_name <- validated_user$display_name
    auth$login <- validated_user$login
    auth$role <- validated_user$role
    auth$annotation_value <- validated_user$annotation_value
    auth$restore_token <- normalize_input_value(restore_token)
    auth$authenticated <- TRUE
    auth$error <- NULL

    initialize_modules()
    shinyjs::hide("auth_root")
    shinyjs::show("app_root")
    restore_workspace_context()

    if (isTRUE(clear_password)) {
      updateTextInput(session, "auth_password", value = "")
    }

    sync_client_auth_session("save")

    invisible(NULL)
  }

  clear_authenticated_session <- function(clear_client_state = TRUE) {
    auth$authenticated <- FALSE
    auth$error <- NULL
    auth$display_name <- NULL
    auth$login <- NULL
    auth$role <- NULL
    auth$annotation_value <- NULL
    auth$lock_claimed <- FALSE
    auth$restore_token <- NULL

    if (isTRUE(clear_client_state)) {
      sync_client_auth_session("clear")
    }

    invisible(NULL)
  }

  try_restore_authenticated_session <- function(
      restore_login,
      restore_token,
      restore_tab_id,
      clear_client_on_failure = TRUE
  ) {
    restore_login <- normalize_input_value(restore_login)
    restore_token <- normalize_input_value(restore_token)
    restore_tab_id <- normalize_input_value(restore_tab_id)

    if (!nzchar(restore_login) || !nzchar(restore_token) || !nzchar(restore_tab_id)) {
      if (isTRUE(clear_client_on_failure)) {
        sync_client_auth_session("clear")
      }
      return(invisible(FALSE))
    }

    set_workspace_for_tab(restore_tab_id)

    if (!isTRUE(validate_auth_restore_session(
      login = restore_login,
      restore_token = restore_token,
      tab_id = restore_tab_id,
      timeout_secs = auth_session_timeout_secs
    ))) {
      if (isTRUE(clear_client_on_failure)) {
        sync_client_auth_session("clear")
      }
      return(invisible(FALSE))
    }

    restored_user <- get_auth_user_by_login(restore_login)
    if (is.null(restored_user)) {
      release_auth_restore_session(restore_login, restore_token = restore_token)
      if (isTRUE(clear_client_on_failure)) {
        sync_client_auth_session("clear")
      }
      return(invisible(FALSE))
    }

    session_lock <- claim_auth_session_lock(
      restored_user$login,
      session$token,
      tab_id = restore_tab_id
    )
    if (!isTRUE(session_lock$acquired)) {
      if (isTRUE(clear_client_on_failure)) {
        sync_client_auth_session("clear")
      }
      return(invisible(FALSE))
    }

    restore_completed <- FALSE
    auth$lock_claimed <- TRUE
    on.exit({
      if (!isTRUE(restore_completed)) {
        release_authenticated_lock()
      }
    }, add = TRUE)

    touch_auth_restore_session(
      login = restored_user$login,
      restore_token = restore_token,
      tab_id = restore_tab_id,
      timeout_secs = auth_session_timeout_secs
    )

    activate_authenticated_session(
      validated_user = restored_user,
      restore_token = restore_token
    )
    restore_completed <- TRUE

    invisible(TRUE)
  }

  output$auth_feedback <- renderUI({
    auth_error <- normalize_input_value(auth$error)
    if (!nzchar(auth_error)) {
      return(NULL)
    }

    div(class = "blt-auth-error", auth_error)
  })

  output$session_identity <- renderUI({
    if (!isTRUE(auth$authenticated)) {
      return(NULL)
    }

    tagList(
      tags$span(auth$display_name, class = "blt-session-name"),
      tags$span(
        toupper(auth$role),
        class = paste("blt-role-badge", paste0("is-", auth$role))
      )
    )
  })

  observeEvent(input$auth_submit, ignoreInit = TRUE, {
    selected_login <- normalize_input_value(input$auth_login)
    entered_password <- normalize_input_value(input$auth_password)

    if (!nzchar(selected_login) || !nzchar(entered_password)) {
      show_auth_error("Select an account and enter the password.")
      return()
    }

    validated_user <- validate_auth_credentials(selected_login, entered_password)
    if (is.null(validated_user)) {
      show_auth_error("Invalid login or password.", reset_password = TRUE)
      return()
    }

    auth_tab_id <- get_auth_tab_id()
    set_workspace_for_tab(auth_tab_id)
    session_lock <- claim_auth_session_lock(
      validated_user$login,
      session$token,
      tab_id = auth_tab_id
    )
    if (!isTRUE(session_lock$acquired)) {
      show_auth_error(session_lock$message, reset_password = TRUE)
      return()
    }

    login_completed <- FALSE
    auth$lock_claimed <- TRUE
    on.exit({
      if (!isTRUE(login_completed)) {
        release_authenticated_lock()
      }
    }, add = TRUE)

    restore_session <- create_auth_restore_session(
      login = validated_user$login,
      tab_id = auth_tab_id,
      timeout_secs = auth_session_timeout_secs
    )
    if (is.null(restore_session) || !nzchar(normalize_input_value(restore_session$restore_token))) {
      show_auth_error("Unable to restore this session. Please try signing in again.")
      return()
    }

    activate_authenticated_session(
      validated_user = validated_user,
      restore_token = restore_session$restore_token
    )
    login_completed <- TRUE
  })

  observeEvent(input$auth_restore, {
    if (isTRUE(auth$authenticated)) {
      return(invisible(NULL))
    }

    restore_payload <- input$auth_restore
    try_restore_authenticated_session(
      restore_login = restore_payload$login,
      restore_token = restore_payload$restore_token,
      restore_tab_id = restore_payload$tab_id,
      clear_client_on_failure = TRUE
    )
  })

  observeEvent(input$auth_tab_id, {
    set_workspace_for_tab(input$auth_tab_id)

    if (isTRUE(auth$authenticated)) {
      return(invisible(NULL))
    }

    restore_tab_id <- normalize_input_value(input$auth_tab_id)
    if (!nzchar(restore_tab_id)) {
      return(invisible(NULL))
    }

    session_info <- find_auth_restore_session_by_tab_id(
      restore_tab_id,
      timeout_secs = auth_session_timeout_secs
    )
    if (is.null(session_info)) {
      return(invisible(NULL))
    }

    try_restore_authenticated_session(
      restore_login = session_info$login,
      restore_token = session_info$restore_token,
      restore_tab_id = session_info$tab_id,
      clear_client_on_failure = FALSE
    )
  })

  observeEvent(input$auth_logout, ignoreInit = TRUE, {
    release_auth_restore_session(auth$login, restore_token = auth$restore_token)
    release_authenticated_lock()
    clear_workspace_context()
    clear_authenticated_session(clear_client_state = TRUE)
    session$reload()
  })

  observeEvent(input$auth_session_expired, ignoreInit = TRUE, {
    release_auth_restore_session(auth$login, restore_token = auth$restore_token)
    release_authenticated_lock()
    clear_workspace_context()
    clear_authenticated_session(clear_client_state = FALSE)
    session$reload()
  })

  observeEvent(input$auth_login, ignoreInit = TRUE, {
    auth$error <- NULL
  })

  observeEvent(input$auth_password, ignoreInit = TRUE, {
    if (nzchar(normalize_input_value(input$auth_password))) {
      auth$error <- NULL
    }
  })

  observeEvent(input$auth_activity, ignoreInit = TRUE, {
    req(
      isTRUE(auth$authenticated),
      nzchar(normalize_input_value(auth$login)),
      nzchar(normalize_input_value(auth$restore_token))
    )

    touch_auth_restore_session(
      login = auth$login,
      restore_token = auth$restore_token,
      tab_id = get_auth_tab_id(),
      timeout_secs = auth_session_timeout_secs
    )
  })

  observeEvent(r$current_image, ignoreInit = TRUE, {
    if (!isTRUE(auth$authenticated)) {
      return(invisible(NULL))
    }

    persist_workspace_context()
  })

  observe({
    req(
      isTRUE(auth$authenticated),
      isTRUE(auth$lock_claimed),
      nzchar(normalize_input_value(auth$login))
    )

    invalidateLater(5000, session)
    refresh_auth_session_lock(
      auth$login,
      session$token,
      tab_id = get_auth_tab_id()
    )
  })
}
