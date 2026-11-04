# Chart whether the conclusion depends on the threshold

Draws the average number of days per year in the earlier and later
period for each threshold from
[`threshold_sensitivity()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/threshold_sensitivity.md).
The title says at how many thresholds the later period had more days,
and the two lines are distinguished by one accent colour against a
neutral grey.

## Usage

``` r
plot_sensitivity(sensitivity, highlight = NULL, base_size = 14)
```

## Arguments

- sensitivity:

  A data frame returned by
  [`threshold_sensitivity()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/threshold_sensitivity.md).

- highlight:

  Optional single threshold to mark with a dashed line, for example the
  threshold currently chosen in the app.

- base_size:

  Base font size passed to the theme.

## Value

A `ggplot` object.

## See also

[`plot_exceedances()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/plot_exceedances.md)

## Examples

``` r
sens <- threshold_sensitivity(thresholds = 28:38, split_year = 2000)
plot_sensitivity(sens, highlight = 35)
```
