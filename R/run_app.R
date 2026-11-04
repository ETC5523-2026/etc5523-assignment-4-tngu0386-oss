#' Launch the Melbourne Airport heat explorer
#'
#' Starts the Shiny app that is installed with the package in `inst/app`. The
#' app is built for a council or emergency-planning officer who wants to know
#' whether days above a chosen temperature have become more frequent at
#' Melbourne Airport, and whether the answer depends on what counts as "hot".
#' It needs the suggested package \pkg{bslib}.
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

  # bslib is only used by the app, so it is a suggested package.
  for (pkg in "bslib") {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      cli::cli_abort(c(
        "Package {.pkg {pkg}} must be installed to run the app.",
        "i" = "You can install it with {.code install.packages('{pkg}')}."
      ))
    }
  }

  shiny::runApp(app_dir, ...)
}
