#' melbheat: Explore Hot Days and Hot Nights at Melbourne Airport
#'
#' The package bundles daily temperature observations from the Melbourne
#' Airport weather station, two helpers for counting and comparing hot days
#' and hot nights, and a Shiny app that puts them in front of a user.
#'
#' * [melb_temp] is the data set.
#' * [annual_exceedances()] counts days per year above a threshold and flags
#'   years with too many missing observations.
#' * [summarise_periods()] and [describe_periods()] compare the average annual
#'   count before and after a chosen year and say how sure we can be.
#' * [threshold_sensitivity()] checks whether that conclusion depends on the
#'   threshold.
#' * [plot_exceedances()] and [plot_sensitivity()] draw the results.
#' * [run_app()] launches the Shiny app.
#'
#' @keywords internal
"_PACKAGE"
