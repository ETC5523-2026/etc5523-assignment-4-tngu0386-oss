# Shared look for melbheat charts: one accent colour carries the message and
# everything else stays neutral (see the Week 6 and Week 7 design recipes).
melbheat_colours <- c(accent = "#b45309", ink = "#1f2933",
                      grey = "#cbd5e1", slate = "#64748b")

# A reusable finishing layer. Data colours and scales are set in each plot.
theme_melbheat <- function(base_size = 14) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.title = ggplot2::element_text(face = "bold", colour = melbheat_colours[["ink"]]),
      plot.subtitle = ggplot2::element_text(colour = melbheat_colours[["slate"]]),
      plot.caption = ggplot2::element_text(hjust = 0, colour = melbheat_colours[["slate"]]),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      legend.position = "top",
      legend.justification = "left",
      plot.margin = ggplot2::margin(10, 36, 10, 10)
    )
}

# Words for the chosen months, used in subtitles.
months_label <- function(months) {
  months <- sort(unique(as.integer(months)))
  if (length(months) == 12L) "all months" else paste(month.abb[months], collapse = ", ")
}

# Wrap long subtitles so they never run off the plot.
wrap_text <- function(x, width = 80) paste(strwrap(x, width = width), collapse = "\n")

measure_words <- function(variable) {
  if (identical(variable, "tmin")) {
    list(noun = "hot nights", phrase = "a daily minimum above")
  } else {
    list(noun = "hot days", phrase = "a daily maximum above")
  }
}

#' Chart the number of hot days (or nights) per year
#'
#' Draws one bar per year from [annual_exceedances()]. Years with too many
#' missing days are grey. If `split_year` is given, a dashed line separates the
#' two periods, a dark line marks each period's average, and the title states
#' the claim the chart supports (see [describe_periods()]). Only the hottest
#' year is labelled, so the label points to the one observation that
#' stands out.
#'
#' @param exceedances A data frame returned by [annual_exceedances()].
#' @param split_year Optional single year at which to split the record into
#'   two periods.
#' @param base_size Base font size passed to the theme.
#'
#' @return A `ggplot` object, so it can be changed or saved with
#'   [ggplot2::ggsave()].
#'
#' @seealso [plot_sensitivity()]
#'
#' @export
#'
#' @examples
#' ex <- annual_exceedances(threshold = 35)
#' plot_exceedances(ex, split_year = 2000)
plot_exceedances <- function(exceedances, split_year = NULL, base_size = 14) {
  needed <- c("year", "n_exceed", "reliable")
  if (!is.data.frame(exceedances) || !all(needed %in% names(exceedances))) {
    cli::cli_abort(c(
      "{.arg exceedances} must be the output of {.fn annual_exceedances}.",
      "i" = "Try {.code annual_exceedances(threshold = 35) |> plot_exceedances(2000)}."
    ))
  }
  if (!is.null(split_year) &&
      (!is.numeric(split_year) || length(split_year) != 1L || !is.finite(split_year))) {
    cli::cli_abort("{.arg split_year} must be {.code NULL} or a single year such as {.code 2000}.")
  }

  s <- attr(exceedances, "settings")
  variable <- if (is.null(s$variable)) "tmax" else s$variable
  words <- measure_words(variable)
  above <- if (is.null(s$threshold)) {
    paste(words$phrase, "the threshold")
  } else {
    sprintf("%s %s \u00B0C", words$phrase, format(s$threshold))
  }
  months_text <- if (is.null(s$months)) "" else paste0(" Months: ", months_label(s$months), ".")

  d <- exceedances
  d$status <- factor(ifelse(d$reliable, "Enough data", "Too many missing days"),
                     levels = c("Enough data", "Too many missing days"))

  title <- sprintf("Days per year with %s", above)
  subtitle <- paste0("Each bar is one year.", months_text)
  periods <- NULL
  if (!is.null(split_year)) {
    periods <- summarise_periods(exceedances, split_year)
    said <- describe_periods(periods)
    if (said$enough_data) title <- said$title
    subtitle <- paste0(sprintf("Days per year with %s.", above), months_text,
                       " Dashed line splits the two periods.")
  }

  p <- ggplot2::ggplot(d, ggplot2::aes(x = .data$year, y = .data$n_exceed, fill = .data$status)) +
    ggplot2::geom_col(width = 0.8) +
    ggplot2::scale_fill_manual(
      values = c("Enough data" = melbheat_colours[["accent"]],
                 "Too many missing days" = melbheat_colours[["grey"]]),
      name = NULL, drop = FALSE
    ) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.12))) +
    ggplot2::labs(
      title = title, subtitle = wrap_text(subtitle), x = NULL, y = "Days per year",
      caption = "Source: Bureau of Meteorology, Melbourne Airport (086282). Grey bars are excluded from averages."
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    theme_melbheat(base_size)

  if (!is.null(split_year)) {
    p <- p + ggplot2::geom_vline(xintercept = split_year + 0.5, linetype = "dashed",
                                 colour = melbheat_colours[["slate"]])
    seg <- periods[periods$n_years > 0, , drop = FALSE]
    if (nrow(seg) > 0) {
      p <- p +
        ggplot2::geom_segment(
          data = seg,
          ggplot2::aes(x = .data$first_year - 0.4, xend = .data$last_year + 0.4,
                       y = .data$mean_exceed, yend = .data$mean_exceed),
          inherit.aes = FALSE, colour = melbheat_colours[["ink"]], linewidth = 1.1
        ) +
        ggplot2::geom_label(
          data = seg,
          ggplot2::aes(x = .data$first_year, y = .data$mean_exceed,
                       label = sprintf("average %.1f", .data$mean_exceed)),
          inherit.aes = FALSE, hjust = 0, vjust = -0.3, size = 4,
          colour = melbheat_colours[["ink"]], fill = "white", linewidth = 0
        )
    }
  }

  reliable <- d[d$reliable %in% TRUE, , drop = FALSE]
  if (nrow(reliable) > 0 && max(reliable$n_exceed) > 0) {
    top <- reliable[which.max(reliable$n_exceed), , drop = FALSE]
    p <- p + ggplot2::geom_text(
      data = top,
      ggplot2::aes(label = sprintf("%d: %d days", .data$year, .data$n_exceed)),
      inherit.aes = FALSE, x = top$year, y = top$n_exceed, vjust = -0.6,
      fontface = "bold", size = 4, colour = melbheat_colours[["accent"]]
    )
  }
  p
}

#' Chart whether the conclusion depends on the threshold
#'
#' Draws the average number of days per year in the earlier and later period
#' for each threshold from [threshold_sensitivity()]. The title says at how
#' many thresholds the later period had more days, and the two lines are
#' distinguished by one accent colour against a neutral grey.
#'
#' @param sensitivity A data frame returned by [threshold_sensitivity()].
#' @param highlight Optional single threshold to mark with a dashed line, for
#'   example the threshold currently chosen in the app.
#' @param base_size Base font size passed to the theme.
#'
#' @return A `ggplot` object.
#'
#' @seealso [plot_exceedances()]
#'
#' @export
#'
#' @examples
#' sens <- threshold_sensitivity(thresholds = 28:38, split_year = 2000)
#' plot_sensitivity(sens, highlight = 35)
plot_sensitivity <- function(sensitivity, highlight = NULL, base_size = 14) {
  needed <- c("threshold", "mean_before", "mean_after", "difference")
  if (!is.data.frame(sensitivity) || !all(needed %in% names(sensitivity))) {
    cli::cli_abort(c(
      "{.arg sensitivity} must be the output of {.fn threshold_sensitivity}.",
      "i" = "Try {.code threshold_sensitivity() |> plot_sensitivity()}."
    ))
  }

  s <- attr(sensitivity, "settings")
  variable <- if (is.null(s$variable)) "tmax" else s$variable
  words <- measure_words(variable)
  split_year <- s$split_year
  split_text <- if (is.null(split_year)) "the later period" else paste("after", split_year)

  valid <- sensitivity[!is.na(sensitivity$difference), , drop = FALSE]
  n_valid <- nrow(valid)
  n_higher <- sum(valid$difference > 0)
  title <- if (n_valid == 0L) {
    "No threshold has enough data in both periods"
  } else if (n_higher == n_valid) {
    sprintf("Years %s had more %s at every threshold tested", split_text, words$noun)
  } else {
    sprintf("Years %s had more %s at %d of %d thresholds tested",
            split_text, words$noun, n_higher, n_valid)
  }
  months_text <- if (is.null(s$months)) "" else paste0(" Months: ", months_label(s$months), ".")

  long <- rbind(
    data.frame(threshold = sensitivity$threshold, mean = sensitivity$mean_before,
               period = "Earlier years"),
    data.frame(threshold = sensitivity$threshold, mean = sensitivity$mean_after,
               period = "Later years")
  )
  long <- long[!is.na(long$mean), , drop = FALSE]
  long$period <- factor(long$period, levels = c("Earlier years", "Later years"))
  p <- ggplot2::ggplot(long, ggplot2::aes(x = .data$threshold, y = .data$mean,
                                          colour = .data$period)) +
    ggplot2::geom_line(linewidth = 1.2) +
    ggplot2::geom_point(size = 2.2) +
    ggplot2::scale_colour_manual(
      values = c("Earlier years" = melbheat_colours[["slate"]],
                 "Later years" = melbheat_colours[["accent"]]),
      name = NULL
    ) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0.03)) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0.03, 0.12))) +
    ggplot2::labs(
      title = title,
      subtitle = wrap_text(paste0("Average days per year in each period, for different ",
                                  "definitions of a hot day.", months_text)),
      x = "Temperature threshold (\u00B0C)", y = "Average days per year",
      caption = "Source: Bureau of Meteorology, Melbourne Airport (086282)."
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    theme_melbheat(base_size)

  if (!is.null(highlight)) {
    p <- p + ggplot2::geom_vline(xintercept = highlight, linetype = "dashed",
                                 colour = melbheat_colours[["slate"]])
  }
  p
}
