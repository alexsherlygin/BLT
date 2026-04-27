heartbeat_state <- new.env(parent = emptyenv())
heartbeat_state$token <- NULL

get_heartbeat_file <- function() {
  Sys.getenv(
    "BLT_HEARTBEAT_FILE",
    unset = file.path(tempdir(), "blt-heartbeat")
  )
}

write_heartbeat <- function(path = get_heartbeat_file()) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)

  temp_path <- tempfile(
    pattern = "blt-heartbeat-",
    tmpdir = dirname(path)
  )

  on.exit(unlink(temp_path, force = TRUE), add = TRUE)

  writeLines(as.character(as.integer(Sys.time())), temp_path, useBytes = TRUE)
  file.rename(temp_path, path)

  invisible(path)
}

start_app_heartbeat <- function() {
  interval_secs <- suppressWarnings(as.numeric(
    Sys.getenv("BLT_HEARTBEAT_INTERVAL_SECS", unset = "15")
  ))

  if (!is.finite(interval_secs) || interval_secs <= 0) {
    interval_secs <- 15
  }

  path <- get_heartbeat_file()
  token <- paste(Sys.getpid(), format(Sys.time(), "%Y%m%d%H%M%OS6"), sep = "-")
  heartbeat_state$token <- token

  tick <- NULL
  tick <- function() {
    if (!identical(heartbeat_state$token, token)) {
      return(invisible(FALSE))
    }

    write_heartbeat(path)
    later::later(tick, delay = interval_secs)
    invisible(TRUE)
  }

  tick()

  invisible(path)
}
