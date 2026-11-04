#' Say what a period comparison shows, and how sure we can be
#'
#' Turns the output of [summarise_periods()] into plain-language text with two
#' parts: **what happened** (the headline) and **how sure we are** (how the gap
#' between the two averages compares with the usual year-to-year variation).
#'
#' The "how sure" part uses a rough 95% range for the difference in means,
#' `gap +/- 2 * standard error`, where the standard error combines the
#' year-to-year spread and the number of years in each period. It treats years
#' as independent and ignores any trend inside a period, so it is a guide to
#' whether the gap stands out from noise, not a formal significance test.
#'
#' @param periods A data frame returned by [summarise_periods()].
#' @param variable,threshold Optional overrides for the temperature measure
#'   (`"tmax"` or `"tmin"`) and threshold used in the wording. By default they
#'   are read from the settings stored in `periods`.
#'
#' @return A list with elements
#' \describe{
#'   \item{enough_data}{`TRUE` if each period has at least 3 reliable years and
#'     at least one of them had a hot day (or night).}
#'   \item{title}{A one-line claim suitable for a chart title.}
#'   \item{headline}{A sentence giving the two averages and the gap.}
#'   \item{how_sure}{A sentence comparing the gap with year-to-year noise.}
#'   \item{gap}{Later average minus earlier average, in days per year.}
#'   \item{low, high}{Ends of the rough 95% range for `gap`.}
#' }
#' If `enough_data` is `FALSE`, `title`, `headline` and `how_sure` explain what
#' to change and the numeric elements are `NA`.
#'
#' @export
#'
#' @examples
#' ex <- annual_exceedances(threshold = 35)
#' periods <- summarise_periods(ex, split_year = 2000)
#' describe_periods(periods)$headline
#' describe_periods(periods)$how_sure
describe_periods <- function(periods, variable = NULL, threshold = NULL) {
  needed <- c("period", "first_year", "last_year", "n_years", "mean_exceed", "sd_exceed")
  if (!is.data.frame(periods) || nrow(periods) != 2L || !all(needed %in% names(periods))) {
    cli::cli_abort(c(
      "{.arg periods} must be the output of {.fn summarise_periods}.",
      "i" = "Try {.code annual_exceedances(threshold = 35) |> summarise_periods(2000)}."
    ))
  }

  s <- attr(periods, "settings")
  if (is.null(variable)) variable <- if (is.null(s$variable)) "tmax" else s$variable
  if (is.null(threshold)) threshold <- s$threshold
  variable <- match.arg(variable, c("tmax", "tmin"))

  noun <- if (variable == "tmax") "hot days" else "hot nights"
  measure <- if (variable == "tmax") "a daily maximum" else "a daily minimum"
  above <- if (is.null(threshold)) {
    paste(measure, "above the threshold")
  } else {
    sprintf("%s above %s \u00B0C", measure, format(threshold))
  }
  split_label <- s$split_year

  if (any(periods$n_years < 3L)) {
    return(list(
      enough_data = FALSE,
      title = "Not enough years to compare the two periods",
      headline = sprintf(
        "Each period needs at least 3 years with enough data. The earlier period has %d and the later period has %d.",
        periods$n_years[1], periods$n_years[2]),
      how_sure = "Move the comparison year, include more months, or lower the smallest share of days recorded.",
      gap = NA_real_, low = NA_real_, high = NA_real_
    ))
  }

  if (all(periods$mean_exceed == 0)) {
    return(list(
      enough_data = FALSE,
      title = sprintf("No %s to compare at this threshold", noun),
      headline = sprintf("No year in either period had %s.", above),
      how_sure = "Lower the threshold or include more months to see counts.",
      gap = NA_real_, low = NA_real_, high = NA_real_
    ))
  }

  gap <- periods$mean_exceed[2] - periods$mean_exceed[1]
  se <- sqrt(periods$sd_exceed[1]^2 / periods$n_years[1] +
               periods$sd_exceed[2]^2 / periods$n_years[2])
  low <- gap - 2 * se
  high <- gap + 2 * se

  years1 <- sprintf("%d\u2013%d", periods$first_year[1], periods$last_year[1])
  years2 <- sprintf("%d\u2013%d", periods$first_year[2], periods$last_year[2])

  change <- if (abs(gap) < 0.5) {
    sprintf("about the same number of %s", noun)
  } else if (gap > 0) {
    sprintf("%.1f more %s", gap, noun)
  } else {
    sprintf("%.1f fewer %s", abs(gap), noun)
  }
  title <- if (abs(gap) < 0.5) {
    sprintf("Melbourne Airport had about the same number of %s a year before and after %s",
            noun, split_label)
  } else {
    sprintf("Melbourne Airport had %s a year after %s", change, split_label)
  }
  headline <- sprintf(
    "In %s the airport averaged %.1f days a year with %s, against %.1f in %s. That is %s a year.",
    years2, periods$mean_exceed[2], above, periods$mean_exceed[1], years1, change)

  range_text <- sprintf("%+.1f to %+.1f", low, high)
  how_sure <- if (low > 0 || high < 0) {
    sprintf("The gap stands out from year-to-year noise: a rough 95%% range for the difference is %s days a year. This treats years as independent, so use it as a guide, not a formal test.",
            range_text)
  } else {
    sprintf("The gap is within the usual year-to-year noise: a rough 95%% range for the difference runs from %s days a year, which includes no change. The data do not clearly separate the two periods at this threshold.",
            range_text)
  }

  list(enough_data = TRUE, title = title, headline = headline,
       how_sure = how_sure, gap = gap, low = low, high = high)
}
