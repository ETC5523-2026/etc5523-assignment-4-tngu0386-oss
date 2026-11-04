#' Count the days each year above a temperature threshold
#'
#' For every year, counts the days on which the daily maximum (hot days) or
#' daily minimum (hot nights) temperature was **above** `threshold`, restricted
#' to the chosen months. Days without an observation cannot be counted, so the
#' function also reports how much of each year was observed and flags years
#' whose coverage falls below `min_coverage`. An incomplete year is then not
#' mistaken for a cool one.
#'
#' Use this function when you need one number per year to compare across
#' time. Do not use the counts of a year marked `reliable = FALSE` as if they
#' were complete: they are lower bounds.
#'
#' @param data A data frame with the columns `year`, `month` and the column
#'   named in `variable`. Defaults to [melb_temp].
#' @param variable Which temperature to use: `"tmax"` (daily maximum, hot days)
#'   or `"tmin"` (daily minimum, hot nights).
#' @param threshold A single number: the temperature in degrees Celsius. A day
#'   counts when its temperature is strictly greater than this value.
#' @param months Integer vector of months to include, 1 (January) to 12
#'   (December). Defaults to the whole year. Years are calendar years, so a
#'   summer spanning December to February is split across two years.
#' @param min_coverage A number between 0 and 1. A year is marked `reliable`
#'   when the share of days in the chosen months with an observation is at
#'   least this value.
#'
#' @return A data frame with one row per year and columns:
#' \describe{
#'   \item{year}{Calendar year.}
#'   \item{n_days}{Number of calendar days in the chosen months.}
#'   \item{n_observed}{Days with a recorded temperature.}
#'   \item{n_exceed}{Observed days above `threshold`.}
#'   \item{coverage}{`n_observed / n_days`.}
#'   \item{prop_exceed}{`n_exceed / n_observed`, or `NA` if nothing was
#'     observed.}
#'   \item{reliable}{`TRUE` if `coverage >= min_coverage`.}
#' }
#' The settings used are stored in `attr(, "settings")` so that
#' [summarise_periods()], [describe_periods()] and [plot_exceedances()] can
#' label their results without being told again.
#'
#' @seealso [summarise_periods()] to compare two periods and
#'   [plot_exceedances()] to draw the result.
#'
#' @export
#'
#' @examples
#' # Days above 35 degrees, whole year
#' ex <- annual_exceedances(threshold = 35)
#' tail(ex)
#'
#' # Warm nights (minimum above 20 degrees) in December to February
#' annual_exceedances(variable = "tmin", threshold = 20, months = c(12, 1, 2))
annual_exceedances <- function(data = melbheat::melb_temp,
                               variable = c("tmax", "tmin"),
                               threshold,
                               months = 1:12,
                               min_coverage = 0.8) {
  variable <- match.arg(variable)

  needed <- c("year", "month", variable)
  if (!is.data.frame(data) || !all(needed %in% names(data))) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame with columns {.field {needed}}.",
      "x" = "Missing: {.field {setdiff(needed, names(data))}}.",
      "i" = "Leave {.arg data} out to use the bundled {.code melb_temp}."
    ))
  }
  if (missing(threshold)) {
    cli::cli_abort(c(
      "{.arg threshold} is required.",
      "i" = "Give a temperature in degrees Celsius, for example {.code annual_exceedances(threshold = 35)}."
    ))
  }
  if (!is.numeric(threshold) || length(threshold) != 1L || !is.finite(threshold)) {
    cli::cli_abort(c(
      "{.arg threshold} must be a single finite number.",
      "x" = "You supplied a {.cls {class(threshold)[1]}} of length {length(threshold)}."
    ))
  }
  if (!is.numeric(months) || length(months) == 0L || !all(months %in% 1:12)) {
    cli::cli_abort(c(
      "{.arg months} must contain at least one whole number from 1 (January) to 12 (December).",
      "x" = "You supplied {.val {months}}."
    ))
  }
  if (!is.numeric(min_coverage) || length(min_coverage) != 1L ||
      is.na(min_coverage) || min_coverage < 0 || min_coverage > 1) {
    cli::cli_abort(c(
      "{.arg min_coverage} must be a single number between 0 and 1.",
      "i" = "Use {.code 0.8} to require 80% of days to be recorded."
    ))
  }

  in_window <- data$month %in% months
  values_by_year <- split(data[[variable]][in_window], data$year[in_window])
  years <- as.integer(names(values_by_year))

  out <- data.frame(
    year = years,
    n_days = days_in_months(years, unique(months)),
    n_observed = unname(vapply(values_by_year, function(v) sum(!is.na(v)), integer(1))),
    n_exceed = unname(vapply(values_by_year,
                             function(v) sum(v > threshold, na.rm = TRUE),
                             integer(1))),
    row.names = NULL
  )
  out$coverage <- out$n_observed / out$n_days
  out$prop_exceed <- ifelse(out$n_observed > 0,
                            out$n_exceed / out$n_observed, NA_real_)
  out$reliable <- out$coverage >= min_coverage

  attr(out, "settings") <- list(
    variable = variable, threshold = threshold,
    months = sort(unique(as.integer(months))), min_coverage = min_coverage
  )
  out
}

# Calendar days in the given months of each year. Counting the rows present in
# the data would treat a year that ends part-way (such as 2022) as complete.
days_in_months <- function(years, months) {
  vapply(years, function(y) {
    first <- as.Date(sprintf("%04d-%02d-01", y, months))
    next_first <- as.Date(sprintf("%04d-%02d-01", y + (months == 12), months %% 12 + 1))
    as.integer(sum(as.integer(next_first - first)))
  }, integer(1))
}
