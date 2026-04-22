#' Authentication helpers
#'
#' @noRd

default_auth_users <- function() {
  data.frame(
    display_name = c("Admin", "User 1", "User 2", "User 3", "User 4"),
    login = c("admin", "user1", "user2", "user3", "user4"),
    password = c(
      "change_me_admin",
      "change_me_user1",
      "change_me_user2",
      "change_me_user3",
      "change_me_user4"
    ),
    role = c("admin", "user", "user", "user", "user"),
    annotation_value = c("Admin", "User_1", "User_2", "User_3", "User_4"),
    stringsAsFactors = FALSE
  )
}

get_auth_users_path <- function() {
  config_dir <- myEnv$config_dir
  if (is.null(config_dir) || !nzchar(config_dir)) {
    config_dir <- normalizePath(
      file.path(tools::R_user_dir("blt", which = "config")),
      mustWork = FALSE
    )
  }

  dir.create(config_dir, recursive = TRUE, showWarnings = FALSE)
  normalizePath(file.path(config_dir, "auth_users.csv"), mustWork = FALSE)
}

initialize_auth_users <- function(force = FALSE) {
  auth_users_path <- get_auth_users_path()

  if (isTRUE(force) || !file.exists(auth_users_path)) {
    utils::write.csv(default_auth_users(), auth_users_path, row.names = FALSE)
  }

  invisible(auth_users_path)
}

load_auth_users <- function() {
  auth_users_path <- initialize_auth_users()

  auth_users <- tryCatch(
    utils::read.csv(auth_users_path, stringsAsFactors = FALSE),
    error = function(e) NULL
  )

  if (is.null(auth_users) || nrow(auth_users) == 0) {
    auth_users <- default_auth_users()
    utils::write.csv(auth_users, auth_users_path, row.names = FALSE)
  }

  required_columns <- c("display_name", "login", "password", "role", "annotation_value")
  for (column_name in required_columns) {
    if (!column_name %in% names(auth_users)) {
      auth_users[[column_name]] <- ""
    }
  }

  auth_users <- auth_users[, required_columns, drop = FALSE]
  auth_users$display_name <- trimws(as.character(auth_users$display_name))
  auth_users$login <- trimws(as.character(auth_users$login))
  auth_users$password <- as.character(auth_users$password)
  auth_users$role <- tolower(trimws(as.character(auth_users$role)))
  auth_users$annotation_value <- trimws(as.character(auth_users$annotation_value))

  auth_users$display_name[!nzchar(auth_users$display_name)] <- auth_users$login[!nzchar(auth_users$display_name)]
  auth_users$role[!auth_users$role %in% c("admin", "user")] <- "user"
  auth_users$annotation_value[!nzchar(auth_users$annotation_value)] <- auth_users$login[!nzchar(auth_users$annotation_value)]

  auth_users <- auth_users[nzchar(auth_users$login) & nzchar(auth_users$password), , drop = FALSE]
  auth_users <- auth_users[!duplicated(auth_users$login), , drop = FALSE]

  if (nrow(auth_users) == 0) {
    auth_users <- default_auth_users()
    utils::write.csv(auth_users, auth_users_path, row.names = FALSE)
  }

  auth_users
}

validate_auth_credentials <- function(login, password, auth_users = load_auth_users()) {
  normalized_login <- stringr::str_squish(as.character(login)[1])
  normalized_password <- as.character(password)[1]

  if (!nzchar(normalized_login) || !nzchar(normalized_password)) {
    return(NULL)
  }

  matched_rows <- auth_users[auth_users$login == normalized_login, , drop = FALSE]
  if (nrow(matched_rows) != 1) {
    return(NULL)
  }

  matched_user <- matched_rows[1, , drop = FALSE]
  if (!identical(as.character(matched_user$password[[1]]), normalized_password)) {
    return(NULL)
  }

  as.list(matched_user[1, c("display_name", "login", "role", "annotation_value"), drop = FALSE])
}

get_auth_user_by_login <- function(login, auth_users = load_auth_users()) {
  normalized_login <- normalize_auth_lock_value(login)
  if (!nzchar(normalized_login)) {
    return(NULL)
  }

  matched_rows <- auth_users[auth_users$login == normalized_login, , drop = FALSE]
  if (nrow(matched_rows) != 1) {
    return(NULL)
  }

  as.list(matched_rows[1, c("display_name", "login", "role", "annotation_value"), drop = FALSE])
}

normalize_auth_lock_value <- function(value) {
  if (is.null(value) || length(value) == 0 || is.na(value[[1]])) {
    return("")
  }

  stringr::str_squish(as.character(value[[1]]))
}

get_auth_session_locks_dir <- function() {
  base_dir <- myEnv$data_dir

  if (is.null(base_dir) || !nzchar(base_dir)) {
    base_dir <- myEnv$config_dir
  }

  if (is.null(base_dir) || !nzchar(base_dir)) {
    base_dir <- normalizePath(
      file.path(tools::R_user_dir("blt", which = "data")),
      mustWork = FALSE
    )
  }

  locks_dir <- normalizePath(
    file.path(base_dir, ".auth_session_locks"),
    mustWork = FALSE
  )
  dir.create(locks_dir, recursive = TRUE, showWarnings = FALSE)

  locks_dir
}

get_auth_session_lock_path <- function(login) {
  normalized_login <- sanitize_storage_name(stringr::str_squish(as.character(login)[1]))
  normalizePath(
    file.path(get_auth_session_locks_dir(), paste0(normalized_login, ".lock")),
    mustWork = FALSE
  )
}

get_auth_session_lock_info_path <- function(login) {
  normalizePath(
    file.path(get_auth_session_lock_path(login), "session.rds"),
    mustWork = FALSE
  )
}

read_auth_session_lock_info <- function(login) {
  info_path <- get_auth_session_lock_info_path(login)
  if (!file.exists(info_path)) {
    return(NULL)
  }

  tryCatch(
    readRDS(info_path),
    error = function(e) NULL
  )
}

write_auth_session_lock_info <- function(login, session_token, tab_id = NULL) {
  normalized_login <- normalize_auth_lock_value(login)
  normalized_session_token <- normalize_auth_lock_value(session_token)
  normalized_tab_id <- normalize_auth_lock_value(tab_id)
  lock_path <- get_auth_session_lock_path(normalized_login)
  info_path <- get_auth_session_lock_info_path(normalized_login)
  existing_info <- read_auth_session_lock_info(normalized_login)
  current_time <- as.numeric(Sys.time())

  dir.create(lock_path, recursive = TRUE, showWarnings = FALSE)

  lock_info <- list(
    login = normalized_login,
    session_token = normalized_session_token,
    tab_id = normalized_tab_id,
    pid = Sys.getpid(),
    acquired_at = if (!is.null(existing_info$acquired_at)) {
      as.numeric(existing_info$acquired_at)
    } else {
      current_time
    },
    last_seen_at = current_time
  )

  saveRDS(lock_info, info_path)
  invisible(lock_info)
}

get_auth_session_lock_last_seen <- function(login, lock_info = NULL) {
  if (!is.null(lock_info$last_seen_at) && is.finite(as.numeric(lock_info$last_seen_at))) {
    return(as.numeric(lock_info$last_seen_at))
  }

  lock_path <- get_auth_session_lock_path(login)
  lock_file_info <- file.info(lock_path)
  if (nrow(lock_file_info) == 0 || is.na(lock_file_info$mtime[[1]])) {
    return(NA_real_)
  }

  as.numeric(lock_file_info$mtime[[1]])
}

is_auth_session_lock_stale <- function(login, lock_info = NULL, stale_after_secs = 20) {
  last_seen_at <- get_auth_session_lock_last_seen(login, lock_info = lock_info)
  if (!is.finite(last_seen_at)) {
    return(TRUE)
  }

  (as.numeric(Sys.time()) - last_seen_at) > stale_after_secs
}

claim_auth_session_lock <- function(login, session_token, tab_id = NULL, stale_after_secs = 20) {
  normalized_login <- normalize_auth_lock_value(login)
  normalized_session_token <- normalize_auth_lock_value(session_token)
  normalized_tab_id <- normalize_auth_lock_value(tab_id)

  if (!nzchar(normalized_login) || !nzchar(normalized_session_token)) {
    return(list(
      acquired = FALSE,
      message = "Unable to start a protected session for this account."
    ))
  }

  lock_path <- get_auth_session_lock_path(normalized_login)
  current_lock_info <- NULL

  for (attempt in seq_len(3)) {
    if (dir.create(lock_path, recursive = FALSE, showWarnings = FALSE)) {
      lock_info <- write_auth_session_lock_info(
        normalized_login,
        normalized_session_token,
        tab_id = normalized_tab_id
      )
      return(list(acquired = TRUE, lock_info = lock_info))
    }

    current_lock_info <- read_auth_session_lock_info(normalized_login)
    current_lock_session_token <- normalize_auth_lock_value(current_lock_info$session_token)
    current_lock_tab_id <- normalize_auth_lock_value(current_lock_info$tab_id)

    if (
      !is.null(current_lock_info) &&
      identical(current_lock_session_token, normalized_session_token)
    ) {
      lock_info <- write_auth_session_lock_info(
        normalized_login,
        normalized_session_token,
        tab_id = normalized_tab_id
      )
      return(list(acquired = TRUE, lock_info = lock_info))
    }

    if (
      !is.null(current_lock_info) &&
      nzchar(normalized_tab_id) &&
      nzchar(current_lock_tab_id) &&
      identical(current_lock_tab_id, normalized_tab_id)
    ) {
      lock_info <- write_auth_session_lock_info(
        normalized_login,
        normalized_session_token,
        tab_id = normalized_tab_id
      )
      return(list(acquired = TRUE, lock_info = lock_info))
    }

    if (is_auth_session_lock_stale(
      normalized_login,
      lock_info = current_lock_info,
      stale_after_secs = stale_after_secs
    )) {
      unlink(lock_path, recursive = TRUE, force = TRUE)
      next
    }

    return(list(
      acquired = FALSE,
      lock_info = current_lock_info,
      message = "This account is already active in another session."
    ))
  }

  list(
    acquired = FALSE,
    lock_info = current_lock_info,
    message = "This account is already active in another session."
  )
}

refresh_auth_session_lock <- function(login, session_token, tab_id = NULL) {
  normalized_login <- normalize_auth_lock_value(login)
  normalized_session_token <- normalize_auth_lock_value(session_token)
  normalized_tab_id <- normalize_auth_lock_value(tab_id)
  lock_path <- get_auth_session_lock_path(normalized_login)

  if (!dir.exists(lock_path)) {
    return(FALSE)
  }

  current_lock_info <- read_auth_session_lock_info(normalized_login)
  if (is.null(current_lock_info)) {
    return(FALSE)
  }

  if (!identical(
    normalize_auth_lock_value(current_lock_info$session_token),
    normalized_session_token
  )) {
    return(FALSE)
  }

  write_auth_session_lock_info(
    normalized_login,
    normalized_session_token,
    tab_id = normalized_tab_id
  )
  TRUE
}

release_auth_session_lock <- function(login, session_token, tab_id = NULL) {
  normalized_login <- normalize_auth_lock_value(login)
  normalized_session_token <- normalize_auth_lock_value(session_token)
  lock_path <- get_auth_session_lock_path(normalized_login)

  if (!dir.exists(lock_path)) {
    return(TRUE)
  }

  current_lock_info <- read_auth_session_lock_info(normalized_login)
  if (
    is.null(current_lock_info) ||
    !identical(
      normalize_auth_lock_value(current_lock_info$session_token),
      normalized_session_token
    )
  ) {
    return(FALSE)
  }

  unlink(lock_path, recursive = TRUE, force = TRUE)
  !dir.exists(lock_path)
}

get_auth_restore_sessions_dir <- function() {
  base_dir <- myEnv$data_dir

  if (is.null(base_dir) || !nzchar(base_dir)) {
    base_dir <- myEnv$config_dir
  }

  if (is.null(base_dir) || !nzchar(base_dir)) {
    base_dir <- normalizePath(
      file.path(tools::R_user_dir("blt", which = "data")),
      mustWork = FALSE
    )
  }

  restore_dir <- normalizePath(
    file.path(base_dir, ".auth_restore_sessions"),
    mustWork = FALSE
  )
  dir.create(restore_dir, recursive = TRUE, showWarnings = FALSE)

  restore_dir
}

get_auth_restore_session_path <- function(login) {
  normalized_login <- normalize_auth_lock_value(login)
  if (!nzchar(normalized_login)) {
    return(normalizePath(
      file.path(get_auth_restore_sessions_dir(), ".invalid-restore-session.rds"),
      mustWork = FALSE
    ))
  }

  normalizePath(
    file.path(get_auth_restore_sessions_dir(), paste0(sanitize_storage_name(normalized_login), ".rds")),
    mustWork = FALSE
  )
}

generate_auth_restore_token <- function(length = 48) {
  token_chars <- c(letters, LETTERS, 0:9)
  paste(sample(token_chars, size = length, replace = TRUE), collapse = "")
}

read_auth_restore_session <- function(login) {
  if (!nzchar(normalize_auth_lock_value(login))) {
    return(NULL)
  }

  session_path <- get_auth_restore_session_path(login)
  if (!file.exists(session_path)) {
    return(NULL)
  }

  tryCatch(
    readRDS(session_path),
    error = function(e) NULL
  )
}

write_auth_restore_session <- function(
    login,
    tab_id,
    restore_token,
    last_activity_at = as.numeric(Sys.time()),
    timeout_secs = 600
) {
  normalized_login <- normalize_auth_lock_value(login)
  normalized_tab_id <- normalize_auth_lock_value(tab_id)
  normalized_restore_token <- normalize_auth_lock_value(restore_token)

  session_info <- list(
    login = normalized_login,
    tab_id = normalized_tab_id,
    restore_token = normalized_restore_token,
    last_activity_at = as.numeric(last_activity_at),
    timeout_secs = as.numeric(timeout_secs)
  )

  saveRDS(session_info, get_auth_restore_session_path(normalized_login))
  invisible(session_info)
}

create_auth_restore_session <- function(login, tab_id, timeout_secs = 600) {
  normalized_login <- normalize_auth_lock_value(login)
  normalized_tab_id <- normalize_auth_lock_value(tab_id)
  if (!nzchar(normalized_login) || !nzchar(normalized_tab_id)) {
    return(NULL)
  }

  restore_token <- generate_auth_restore_token()

  write_auth_restore_session(
    login = normalized_login,
    tab_id = normalized_tab_id,
    restore_token = restore_token,
    timeout_secs = timeout_secs
  )
}

is_auth_restore_session_stale <- function(session_info, timeout_secs = NULL) {
  if (is.null(session_info)) {
    return(TRUE)
  }

  effective_timeout <- timeout_secs
  if (is.null(effective_timeout) || !is.finite(as.numeric(effective_timeout))) {
    effective_timeout <- session_info$timeout_secs
  }
  if (is.null(effective_timeout) || !is.finite(as.numeric(effective_timeout))) {
    effective_timeout <- 600
  }

  last_activity_at <- suppressWarnings(as.numeric(session_info$last_activity_at))
  if (!is.finite(last_activity_at)) {
    return(TRUE)
  }

  (as.numeric(Sys.time()) - last_activity_at) > as.numeric(effective_timeout)
}

touch_auth_restore_session <- function(login, restore_token, tab_id, timeout_secs = 600) {
  if (
    !nzchar(normalize_auth_lock_value(login)) ||
    !nzchar(normalize_auth_lock_value(restore_token)) ||
    !nzchar(normalize_auth_lock_value(tab_id))
  ) {
    return(FALSE)
  }

  session_info <- read_auth_restore_session(login)
  if (is.null(session_info)) {
    return(FALSE)
  }

  if (
    !identical(normalize_auth_lock_value(session_info$restore_token), normalize_auth_lock_value(restore_token)) ||
    !identical(normalize_auth_lock_value(session_info$tab_id), normalize_auth_lock_value(tab_id))
  ) {
    return(FALSE)
  }

  write_auth_restore_session(
    login = login,
    tab_id = tab_id,
    restore_token = restore_token,
    timeout_secs = timeout_secs
  )

  TRUE
}

validate_auth_restore_session <- function(login, restore_token, tab_id, timeout_secs = 600) {
  if (
    !nzchar(normalize_auth_lock_value(login)) ||
    !nzchar(normalize_auth_lock_value(restore_token)) ||
    !nzchar(normalize_auth_lock_value(tab_id))
  ) {
    return(FALSE)
  }

  session_info <- read_auth_restore_session(login)
  if (is.null(session_info)) {
    return(FALSE)
  }

  if (is_auth_restore_session_stale(session_info, timeout_secs = timeout_secs)) {
    release_auth_restore_session(login)
    return(FALSE)
  }

  identical(normalize_auth_lock_value(session_info$restore_token), normalize_auth_lock_value(restore_token)) &&
    identical(normalize_auth_lock_value(session_info$tab_id), normalize_auth_lock_value(tab_id))
}

find_auth_restore_session_by_tab_id <- function(tab_id, timeout_secs = 600) {
  normalized_tab_id <- normalize_auth_lock_value(tab_id)
  if (!nzchar(normalized_tab_id)) {
    return(NULL)
  }

  restore_dir <- get_auth_restore_sessions_dir()
  restore_files <- list.files(
    restore_dir,
    pattern = "\\.rds$",
    full.names = TRUE
  )
  if (length(restore_files) == 0) {
    return(NULL)
  }

  for (restore_file in restore_files) {
    session_info <- tryCatch(
      readRDS(restore_file),
      error = function(e) NULL
    )
    if (is.null(session_info)) {
      next
    }

    if (is_auth_restore_session_stale(session_info, timeout_secs = timeout_secs)) {
      unlink(restore_file, force = TRUE)
      next
    }

    if (identical(
      normalize_auth_lock_value(session_info$tab_id),
      normalized_tab_id
    )) {
      return(session_info)
    }
  }

  NULL
}

release_auth_restore_session <- function(login, restore_token = NULL) {
  normalized_login <- normalize_auth_lock_value(login)
  if (!nzchar(normalized_login)) {
    return(FALSE)
  }

  session_path <- get_auth_restore_session_path(normalized_login)

  if (!file.exists(session_path)) {
    return(TRUE)
  }

  if (!is.null(restore_token) && nzchar(normalize_auth_lock_value(restore_token))) {
    session_info <- read_auth_restore_session(normalized_login)
    if (
      is.null(session_info) ||
      !identical(
        normalize_auth_lock_value(session_info$restore_token),
        normalize_auth_lock_value(restore_token)
      )
    ) {
      return(FALSE)
    }
  }

  unlink(session_path, force = TRUE)
  !file.exists(session_path)
}
