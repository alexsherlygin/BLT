#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {

  #call function in app_config.R to see if a project file was passed in on run_app()
  was_projectSettingsFile_passed_in()
  auth_users <- load_auth_users()

  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    shinyjs::useShinyjs(),
    div(
      id = "auth_root",
      auth_page_ui(auth_users)
    ),
    shinyjs::hidden(
      div(
        id = "app_root",
        main_app_ui()
      )
    )
  )

}

auth_page_ui <- function(auth_users) {
  account_choices <- c(
    "Select account" = "",
    stats::setNames(auth_users$login, auth_users$display_name)
  )

  fluidPage(
    class = "blt-auth-page",
    div(
      class = "blt-auth-shell",
      div(class = "blt-auth-ghost", "BLT"),
        div(
          class = "blt-auth-card",
          div(class = "blt-auth-kicker", "Berta Labelling Tool"),
          tags$h1("Sign in", class = "blt-auth-title"),
          selectInput(
            inputId = "auth_login",
            label = "Account",
            choices = account_choices,
          selected = "",
          width = "100%",
          selectize = FALSE
        ),
        div(
          class = "blt-auth-password-wrap",
          passwordInput(
            inputId = "auth_password",
            label = "Password",
            width = "100%"
          ),
          tags$button(
            type = "button",
            id = "auth_password_toggle",
            class = "blt-password-toggle",
            `aria-label` = "Show password",
            title = "Show password",
            icon("eye")
          )
        ),
        actionButton(
          inputId = "auth_submit",
          label = NULL,
          icon = icon("arrow-right"),
          class = "blt-auth-submit",
          title = "Enter"
        ),
        uiOutput("auth_feedback")
      )
    )
  )
}

main_app_ui <- function() {
  fluidPage(
    div(
      class = "blt-shell-header",
      div(
        class = "blt-shell-brand",
        div(class = "blt-shell-brand-mark", "BLT"),
        div(
          class = "blt-shell-brand-copy",
          tags$span("Berta Labelling Tool", class = "blt-shell-brand-title"),
          tags$span("Authenticated workspace", class = "blt-shell-brand-subtitle")
        )
      ),
      div(
        class = "blt-shell-session",
        uiOutput("session_identity"),
        actionButton(
          inputId = "auth_logout",
          label = "Logout",
          icon = icon("sign-out-alt"),
          class = "btn blt-logout-btn"
        )
      )
    ),
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
    tempdir() #tools::R_user_dir("blt")
  )

  tags$head(
    tags$style(
      HTML(
        ".image-panel-title .shinyhelper-wrapper {display: inline-flex; align-items: center; gap: 4px;}
         .image-panel-title .shinyhelper-container {position: static; width: auto; height: auto; line-height: 1;}
         html.blt-auth-restoring #auth_root,
         html.blt-auth-restoring #app_root {visibility: hidden !important;}
         html.blt-auth-restoring body::before {content: ''; position: fixed; inset: 0; background: linear-gradient(135deg, #f6f1e8 0%, #e8eef4 100%); z-index: 9998;}
         html.blt-auth-restoring body::after {content: 'BLT'; position: fixed; inset: 0; display: flex; align-items: center; justify-content: center; font-size: min(78vw, 120vh); font-weight: 900; line-height: 0.78; letter-spacing: 0.04em; color: rgba(39, 62, 84, 0.09); text-shadow: 0 34px 80px rgba(39, 62, 84, 0.14); pointer-events: none; user-select: none; z-index: 9999; transform: scale(1.05);}
         #auth_root {min-height: 100vh; background: linear-gradient(135deg, #f6f1e8 0%, #e8eef4 100%); overflow: hidden;}
         #auth_root .container-fluid {min-height: 100vh; padding: 32px;}
         .blt-auth-shell {position: relative; display: flex; min-height: calc(100vh - 64px); align-items: center; justify-content: center; isolation: isolate;}
         .blt-auth-ghost {position: fixed; inset: 0; display: flex; align-items: center; justify-content: center; font-size: min(78vw, 120vh); font-weight: 900; line-height: 0.78; letter-spacing: 0.04em; color: rgba(39, 62, 84, 0.09); text-shadow: 0 34px 80px rgba(39, 62, 84, 0.14); user-select: none; pointer-events: none; z-index: -1; transform: scale(1.05);}
         .blt-auth-card {position: relative; width: 100%; max-width: 420px; padding: 32px 32px 28px; border-radius: 24px; background: rgba(255, 255, 255, 0.92); box-shadow: 0 24px 80px rgba(33, 43, 54, 0.18); border: 1px solid rgba(255, 255, 255, 0.72); backdrop-filter: blur(12px);}
         .blt-auth-kicker {margin-bottom: 14px; font-size: 11px; font-weight: 700; letter-spacing: 0.24em; text-transform: uppercase; color: #7a8794;}
         .blt-auth-title {margin: 0 0 8px; font-size: 32px; font-weight: 700; color: #18222d;}
         .blt-auth-subtitle {margin-bottom: 22px; font-size: 14px; line-height: 1.6; color: #566575;}
         .blt-auth-card .form-group label {font-size: 12px; letter-spacing: 0.08em; text-transform: uppercase; color: #60707f;}
         .blt-auth-card .form-control {height: 48px; border-radius: 14px; border: 1px solid #d6dee5; box-shadow: none;}
         .blt-auth-card .form-control:focus {border-color: #355c7d; box-shadow: 0 0 0 3px rgba(53, 92, 125, 0.15);}
         .blt-auth-password-wrap {position: relative;}
         .blt-auth-password-wrap .form-group {margin-bottom: 0;}
         .blt-auth-password-wrap .form-control {padding-right: 52px;}
         .blt-password-toggle {position: absolute; right: 10px; bottom: 8px; width: 32px; height: 32px; border: 0; background: transparent; color: #60707f; display: flex; align-items: center; justify-content: center; border-radius: 10px; transition: background-color 0.2s ease, color 0.2s ease;}
         .blt-password-toggle:hover, .blt-password-toggle:focus {background: rgba(53, 92, 125, 0.08); color: #355c7d; outline: none;}
         .blt-auth-card button.blt-auth-submit.btn {display: flex !important; align-items: center; justify-content: center; width: 56px !important; min-width: 56px; max-width: 56px; height: 56px !important; min-height: 56px; max-height: 56px; margin: 18px auto 0 auto; padding: 0 !important; line-height: 1; border-radius: 50% !important; border: 0 !important; appearance: none; -webkit-appearance: none; background: linear-gradient(135deg, #264653 0%, #355c7d 100%) !important; color: #fff !important; font-size: 18px; box-shadow: 0 16px 32px rgba(38, 70, 83, 0.24);}
         .blt-auth-card button.blt-auth-submit.btn:hover, .blt-auth-card button.blt-auth-submit.btn:focus, .blt-auth-card button.blt-auth-submit.btn:active {color: #fff !important; background: linear-gradient(135deg, #264653 0%, #355c7d 100%) !important;}
         .blt-auth-submit .fa-arrow-right {font-size: 16px;}
         .blt-auth-submit[disabled] {cursor: wait; opacity: 0.75; box-shadow: none;}
         .blt-auth-error {margin-top: 14px; padding: 12px 14px; border-radius: 14px; background: #fff1f1; color: #a53d46; font-size: 13px;}
         #app_root {min-height: 100vh; background: #f4f7fa;}
         #app_root .container-fluid {padding-top: 18px; padding-bottom: 24px;}
         .blt-shell-header {display: flex; align-items: center; justify-content: space-between; gap: 16px; margin: 4px 0 18px; padding: 14px 18px; border-radius: 18px; background: linear-gradient(135deg, rgba(255, 255, 255, 0.98) 0%, rgba(245, 248, 251, 0.95) 100%); box-shadow: 0 10px 30px rgba(46, 61, 73, 0.08);}
         .blt-shell-brand {display: flex; align-items: center; gap: 12px;}
         .blt-shell-brand-mark {display: flex; align-items: center; justify-content: center; width: 42px; height: 42px; border-radius: 14px; background: #264653; color: #fff; font-weight: 700; letter-spacing: 0.08em;}
         .blt-shell-brand-copy {display: flex; flex-direction: column;}
         .blt-shell-brand-title {font-size: 17px; font-weight: 700; color: #18222d; line-height: 1.1;}
         .blt-shell-brand-subtitle {font-size: 12px; color: #748190;}
         .blt-shell-session {display: flex; align-items: center; justify-content: flex-end; gap: 10px; flex-wrap: wrap;}
         .blt-session-name {font-weight: 600; color: #1f2b37;}
         .blt-role-badge {display: inline-flex; align-items: center; padding: 6px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase;}
         .blt-role-badge.is-admin {background: #e6f0ff; color: #214e8a;}
         .blt-role-badge.is-user {background: #edf4ed; color: #2f6b43;}
         html:not(.blt-role-admin) [id$='-image_selection_help_wrapper'] .shinyhelper-container {display: none !important;}
         html:not(.blt-role-admin) [id$='-settings_button_wrapper'] {display: none !important;}
         .blt-logout-btn {border-radius: 999px; border: 1px solid #d6dee5; background: #fff; color: #31424f; font-weight: 600;}
         @media (max-width: 767px) {
           #auth_root .container-fluid {padding: 18px;}
           .blt-auth-card {padding: 24px 20px;}
           .blt-auth-title {font-size: 28px;}
           .blt-shell-header {flex-direction: column; align-items: flex-start;}
           .blt-shell-session {justify-content: flex-start;}
         }"
      )
    ),
    tags$script(
      HTML(
        "(function() {
           var AUTH_STATE_STORAGE_KEY = 'blt-auth-state';
           var AUTH_ACTIVITY_THROTTLE_MS = 15000;
           var DEFAULT_AUTH_TIMEOUT_MS = 10 * 60 * 1000;
           var lastAuthActivitySentAt = 0;
           var authActivityListenersBound = false;
           var authMessageHandlerBound = false;
           var restoreMaskTimer = null;

           function setAuthRestoring(isRestoring) {
             var root = document.documentElement;
             if (!root) {
               return;
             }

             if (!isRestoring) {
               root.classList.remove('blt-auth-restoring');
               if (restoreMaskTimer) {
                 window.clearTimeout(restoreMaskTimer);
                 restoreMaskTimer = null;
               }
               return;
             }

             root.classList.add('blt-auth-restoring');
             if (restoreMaskTimer) {
               window.clearTimeout(restoreMaskTimer);
             }
             restoreMaskTimer = window.setTimeout(function() {
               root.classList.remove('blt-auth-restoring');
               restoreMaskTimer = null;
             }, 8000);
           }

           function generateAuthTabId() {
             if (window.crypto && typeof window.crypto.randomUUID === 'function') {
               return window.crypto.randomUUID();
             }
             return 'blt-tab-' + Math.random().toString(36).slice(2) + Date.now().toString(36);
           }

           function ensureAuthTabId() {
             var storageKey = 'blt-auth-tab-id';
             var tabId = window.sessionStorage.getItem(storageKey);
             if (!tabId) {
               tabId = generateAuthTabId();
               window.sessionStorage.setItem(storageKey, tabId);
             }

             if (window.Shiny && typeof window.Shiny.setInputValue === 'function') {
               window.Shiny.setInputValue('auth_tab_id', tabId, {priority: 'event'});
             }

             return tabId;
           }

           function getStoredAuthState() {
             var rawValue = window.sessionStorage.getItem(AUTH_STATE_STORAGE_KEY);
             if (!rawValue) {
               return null;
             }

             try {
               return JSON.parse(rawValue);
             } catch (error) {
               window.sessionStorage.removeItem(AUTH_STATE_STORAGE_KEY);
               return null;
             }
           }

           function storeAuthState(state) {
             if (!state || !state.login || !state.restore_token) {
               clearStoredAuthState();
               return null;
             }

             var nextState = Object.assign({}, state, {
               tab_id: ensureAuthTabId(),
               last_activity_at: Date.now()
             });

             window.sessionStorage.setItem(AUTH_STATE_STORAGE_KEY, JSON.stringify(nextState));
             return nextState;
           }

           function clearStoredAuthState() {
             window.sessionStorage.removeItem(AUTH_STATE_STORAGE_KEY);
           }

           function getAuthTimeoutMs(state) {
             var timeoutMs = Number(state && state.inactivity_timeout_ms);
             if (!Number.isFinite(timeoutMs) || timeoutMs <= 0) {
               return DEFAULT_AUTH_TIMEOUT_MS;
             }

             return timeoutMs;
           }

           function isStoredAuthExpired(state) {
             if (!state || !state.login || !state.restore_token) {
               return false;
             }

             var lastActivityAt = Number(state.last_activity_at);
             if (!Number.isFinite(lastActivityAt)) {
               return true;
             }

             return (Date.now() - lastActivityAt) > getAuthTimeoutMs(state);
           }

           function shouldMaskForStoredAuth() {
             var existingState = getStoredAuthState();
             if (!existingState) {
               return false;
             }

             return !isStoredAuthExpired(existingState);
           }

           function syncAuthTabIdWithShiny() {
             var tabId = ensureAuthTabId();

             if (window.Shiny && typeof window.Shiny.setInputValue === 'function') {
               window.Shiny.setInputValue('auth_tab_id', tabId, {priority: 'event'});
               return true;
             }

             return false;
           }

           function handleStoredAuthExpiry() {
             var existingState = getStoredAuthState();
             if (!existingState) {
               setAuthRestoring(false);
               return false;
             }

             clearStoredAuthState();
             setAuthRestoring(false);
             if (window.Shiny && typeof window.Shiny.setInputValue === 'function') {
               window.Shiny.setInputValue('auth_session_expired', Date.now(), {priority: 'event'});
             } else {
               window.location.reload();
             }

             return true;
           }

           function maybeExpireStoredAuth() {
             var existingState = getStoredAuthState();
             if (!existingState) {
               return false;
             }

             if (!isStoredAuthExpired(existingState)) {
               return false;
             }

             return handleStoredAuthExpiry();
           }

           function reportAuthActivity(forceServerSync) {
             var existingState = getStoredAuthState();
             if (!existingState) {
               return;
             }

             if (maybeExpireStoredAuth()) {
               return;
             }

             var nextState = storeAuthState(existingState);
             if (!nextState) {
               return;
             }

             if (!(window.Shiny && typeof window.Shiny.setInputValue === 'function')) {
               return;
             }

             var now = Date.now();
             if (!forceServerSync && (now - lastAuthActivitySentAt) < AUTH_ACTIVITY_THROTTLE_MS) {
               return;
             }

             lastAuthActivitySentAt = now;
             window.Shiny.setInputValue('auth_activity', now, {priority: 'event'});
           }

           function requestStoredAuthRestore(maskDuringRestore) {
             if (typeof maskDuringRestore === 'undefined') {
               maskDuringRestore = false;
             }

             var existingState = getStoredAuthState();
             if (!existingState) {
               setAuthRestoring(false);
               return;
             }

             if (maybeExpireStoredAuth()) {
                return;
             }

             var nextState = storeAuthState(existingState);
             if (!nextState) {
               setAuthRestoring(false);
               return;
             }

             if (window.Shiny && typeof window.Shiny.setInputValue === 'function') {
               if (maskDuringRestore) {
                 setAuthRestoring(true);
               }
               window.Shiny.setInputValue('auth_restore', {
                 login: nextState.login,
                 restore_token: nextState.restore_token,
                 tab_id: nextState.tab_id,
                 nonce: Date.now()
               }, {priority: 'event'});
             }
           }

           function scheduleAuthInit() {
             var attempts = 0;

             var timer = window.setInterval(function() {
               attempts += 1;
               if (syncAuthTabIdWithShiny() || attempts >= 40) {
                 window.clearInterval(timer);
               }
             }, 150);
           }

           function registerAuthActivityListeners() {
             if (authActivityListenersBound) {
               return;
             }

             authActivityListenersBound = true;

             ['mousedown', 'keydown', 'touchstart', 'scroll'].forEach(function(eventName) {
               window.addEventListener(eventName, function() {
                 reportAuthActivity(false);
               }, {passive: true});
             });

             document.addEventListener('visibilitychange', function() {
               if (document.visibilityState === 'visible') {
                 if (!maybeExpireStoredAuth()) {
                   reportAuthActivity(true);
                   requestStoredAuthRestore(false);
                 }
               }
             });

             window.setInterval(function() {
               maybeExpireStoredAuth();
             }, 15000);
           }

           function triggerAuthSubmit() {
             var authRoot = document.getElementById('auth_root');
             var authButton = document.getElementById('auth_submit');
             if (!authRoot || !authButton) return;
             if (window.getComputedStyle(authRoot).display === 'none') return;
             authButton.click();
           }

           function initializePasswordToggle() {
             var passwordInput = document.getElementById('auth_password');
             var toggleButton = document.getElementById('auth_password_toggle');
             if (!passwordInput || !toggleButton || toggleButton.dataset.bound === 'true') {
               return;
             }

             toggleButton.dataset.bound = 'true';
             toggleButton.addEventListener('click', function() {
               var showingPassword = passwordInput.type === 'text';
               var nextType = showingPassword ? 'password' : 'text';
               var nextLabel = showingPassword ? 'Show password' : 'Hide password';
               var toggleIcon = toggleButton.querySelector('i');

               passwordInput.type = nextType;
               toggleButton.setAttribute('aria-label', nextLabel);
               toggleButton.setAttribute('title', nextLabel);

               if (toggleIcon) {
                 toggleIcon.className = showingPassword ? 'fas fa-eye' : 'fas fa-eye-slash';
               }

               passwordInput.focus({preventScroll: true});
             });
           }

           function registerAuthMessageHandler() {
             if (
               authMessageHandlerBound ||
               !(window.Shiny && typeof window.Shiny.addCustomMessageHandler === 'function')
             ) {
               return;
             }

             authMessageHandlerBound = true;
             window.Shiny.addCustomMessageHandler('blt-auth-session', function(message) {
               if (!message || !message.action) {
                 return;
               }

               if (message.action === 'clear') {
                 clearStoredAuthState();
                 setAuthRestoring(false);
                 return;
               }

               if (message.action === 'save') {
                 storeAuthState(message.state || {});
                 setAuthRestoring(false);
               }
             });
           }

           if (shouldMaskForStoredAuth()) {
             setAuthRestoring(true);
           }

           document.addEventListener('DOMContentLoaded', function() {
             initializePasswordToggle();
             registerAuthActivityListeners();
             registerAuthMessageHandler();
             scheduleAuthInit();
             if (!maybeExpireStoredAuth() && !shouldMaskForStoredAuth()) {
               setAuthRestoring(false);
             }

             document.addEventListener('keyup', function(event) {
               if (event.key !== 'Enter') return;
               if (event.target && event.target.id === 'auth_submit') return;
               window.requestAnimationFrame(triggerAuthSubmit);
             });
           });

           document.addEventListener('shiny:connected', function() {
             registerAuthMessageHandler();
             syncAuthTabIdWithShiny();
             requestStoredAuthRestore(true);
           });
           window.addEventListener('pageshow', function() {
             initializePasswordToggle();
             registerAuthActivityListeners();
             registerAuthMessageHandler();
             scheduleAuthInit();
             if (!maybeExpireStoredAuth()) {
               requestStoredAuthRestore(true);
             } else {
               setAuthRestoring(false);
             }
           });
         })();"
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
    initialize_auth_users()
    #print(myEnv$project_config_file)
    #config_file <- file.path(config_dir, "config.yml")
    #print(config_dir)
    myEnv$config <- apply_config_defaults(configr::read.config(myEnv$project_config_file))

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
      # Destination file may not exist yet, so don't normalize it first.
      toPath <- file.path(tempdir(), destFile)
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
  myEnv$config_dir <- normalizePath(tools::R_user_dir("blt", which = "config"))
  myEnv$data_dir <- normalizePath(tools::R_user_dir("blt", which = "data"))
  myEnv$project_config_file <- normalizePath(file.path(myEnv$config_dir, "default-project-config.yml"))
  initialize_auth_users()

  myEnv$config <- apply_config_defaults(configr::read.config(myEnv$project_config_file))

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
