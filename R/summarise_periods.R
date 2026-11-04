#' Compare the average annual count before and after a year
#'
#' Takes the output of [annual_exceedances()] and averages the annual count of
#' days above the threshold in two periods: years up to and including
#' `split_year`, and years after it. Only years marked `reliable` are used, so
#' the averages are not pulled down by years with many missing observations.
#'
#' This is a descriptive comparison of two averages. Use [describe_periods()]
#' to put the gap next to the usual year-to-year variation.
#'
#' @param exceedances A data frame returned by [annual_exceedances()].
#' @param split_year A single year. Years `<= split_year` form the first
#'   period and years `> split_year` the second.
#'
#' @return A data frame with two rows (earlier period first) and columns
#' \describe{
#'   \item{period}{Label of the period.}
#'   \item{first_year, last_year}{First and last reliable year in the period,
#'     `NA` if there is none.}
#'   \item{n_years}{Number of reliable years in the period.}
#'   \item{mean_exceed}{Mean annual number of days above the threshold, `NA`
#'     if `n_years` is 0.}
#'   \item{sd_exceed}{Standard deviation of the annual counts, a measure of
#'     year-to-year variation; `NA` if `n_years` is below 2.}
#'   \item{min_exceed, max_exceed}{Smallest and largest annual count in the
#'     period, `NA` if `n_years` is 0.}
#' }
#' The settings of `exceedances` plus `split_year` are kept in
#' `attr(, "settings")`.
#'
#' @seealso [describe_periods()] for a plain-language reading of the result.
#'
#' @export
#'
#' @examples
#' ex <- annual_exceedances(threshold = 35)
#' summarise_periods(ex, split_year = 2000)
summarise_periods <- function(exceedances, split_year) {
  needed <- c("year", "n_exceed", "reliable")
  if (!is.data.frame(exceedances) || !all(needed %in% names(exceedances))) {
    cli::cli_abort(c(
      "{.arg exceedances} must be the output of {.fn annual_exceedances}.",
      "i" = "Try {.code annual_exceedances(threshold = 35) |> summarise_periods(2000)}."
    ))
  }
  if (missing(split_year) || !is.numeric(split_year) || length(split_year) != 1L ||
      !is.finite(split_year)) {
    cli::cli_abort(c(
      "{.arg split_year} must be a single year, such as {.code 2000}.",
      "i" = "Years up to and including it form the first period."
    ))
  }
  split_year <- as.integer(split_year)

  used <- exceedances[exceedances$reliable %in% TRUE, , drop = FALSE]

  one_period <- function(keep, label) {
    d <- used[keep, , drop = FALSE]
    has_rows <- nrow(d) > 0L
    data.frame(
      period = label,
      first_year = if (has_rows) min(d$year) else NA_integer_,
      last_year = if (has_rows) max(d$year) else NA_integer_,
      n_years = nrow(d),
      mean_exceed = if (has_rows) mean(d$n_exceed) else NA_real_,
      sd_exceed = if (nrow(d) >= 2L) stats::sd(d$n_exceed) else NA_real_,
      min_exceed = if (has_rows) min(d$n_exceed) else NA_real_,
      max_exceed = if (has_rows) max(d$n_exceed) else NA_real_,
      stringsAsFactors = FALSE
    )
  }

  out <- rbind(
    one_period(used$year <= split_year, paste(split_year, "or earlier")),
    one_period(used$year > split_year, paste("after", split_year))
  )
  attr(out, "settings") <- c(attr(exceedances, "settings"),
                             list(split_year = split_year))
  out
}
