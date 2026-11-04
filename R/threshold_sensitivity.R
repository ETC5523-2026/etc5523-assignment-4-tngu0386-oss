#' Does the conclusion depend on what counts as "hot"?
#'
#' Repeats the before-and-after comparison of [summarise_periods()] for a
#' range of temperature thresholds. If the later period has more hot days at
#' every threshold, the conclusion does not hinge on one arbitrary cut-off; if
#' it only appears at one threshold, it deserves caution.
#'
#' @inheritParams annual_exceedances
#' @param thresholds Numeric vector of thresholds in degrees Celsius. By
#'   default 25 to 40 for `"tmax"` and 12 to 26 for `"tmin"`, in steps of 1.
#' @param split_year A single year. Years `<= split_year` form the earlier
#'   period and years after it the later period.
#'
#' @return A data frame with one row per threshold and columns `threshold`,
#'   `mean_before`, `mean_after` (average days per year in each period),
#'   `n_before`, `n_after` (reliable years used), `difference`
#'   (`mean_after - mean_before`) and `ratio` (`mean_after / mean_before`, `NA`
#'   when the earlier average is 0). The settings are kept in
#'   `attr(, "settings")`.
#'
#' @seealso [plot_sensitivity()] to draw the result.
#'
#' @export
#'
#' @examples
#' sens <- threshold_sensitivity(thresholds = c(30, 35, 40), split_year = 2000)
#' sens
threshold_sensitivity <- function(data = melbheat::melb_temp,
                                  variable = c("tmax", "tmin"),
                                  thresholds = NULL,
                                  months = 1:12,
                                  split_year = 2000,
                                  min_coverage = 0.8) {
  variable <- match.arg(variable)
  if (is.null(thresholds)) {
    thresholds <- if (variable == "tmax") 25:40 else 12:26
  }
  if (!is.numeric(thresholds) || length(thresholds) == 0L || !all(is.finite(thresholds))) {
    cli::cli_abort(c(
      "{.arg thresholds} must be a non-empty numeric vector of temperatures.",
      "i" = "For example {.code thresholds = c(30, 35, 40)}."
    ))
  }
  thresholds <- sort(unique(thresholds))

  rows <- lapply(thresholds, function(th) {
    ex <- annual_exceedances(data, variable, th, months, min_coverage)
    sp <- summarise_periods(ex, split_year)
    before <- sp$mean_exceed[1]
    after <- sp$mean_exceed[2]
    data.frame(
      threshold = th,
      mean_before = before,
      mean_after = after,
      n_before = sp$n_years[1],
      n_after = sp$n_years[2],
      difference = after - before,
      ratio = if (isTRUE(before > 0)) after / before else NA_real_
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  attr(out, "settings") <- list(
    variable = variable, months = sort(unique(as.integer(months))),
    min_coverage = min_coverage, split_year = as.integer(split_year)
  )
  out
}
