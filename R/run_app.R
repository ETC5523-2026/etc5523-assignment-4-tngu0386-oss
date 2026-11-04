#' Launch the Melbourne Airport heat explorer
#'
#' Starts the Shiny app that is installed with the package in `inst/app`. The
#' app is built for a council or emergency-planning officer who wants to know
#' whether days above a chosen temperature have become more frequent at
#' Melbourne Airport, and whether the answer depends on what counts as "hot".
#'
#' @param ... Further arguments passed to [shiny::runApp()], for example
#'   `launch.browser = FALSE` or `port = 4321`.
#'
#' @return Called for its side effect of starting the app; it does not return
#'   a value.
#' @export
#'
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
run_app <- function(...) {
  app_dir <- system.file("app", package = "melbheat")
  if (identical(app_dir, "")) {
    cli::cli_abort(c(
      "Could not find the app directory.",
      "i" = "Try re-installing {.pkg melbheat}."
    ))
  }

  shiny::runApp(app_dir, ...)
}
