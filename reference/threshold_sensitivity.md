# Does the conclusion depend on what counts as "hot"?

Repeats the before-and-after comparison of
[`summarise_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/summarise_periods.md)
for a range of temperature thresholds. If the later period has more hot
days at every threshold, the conclusion does not hinge on one arbitrary
cut-off; if it only appears at one threshold, it deserves caution.

## Usage

``` r
threshold_sensitivity(
  data = melbheat::melb_temp,
  variable = c("tmax", "tmin"),
  thresholds = NULL,
  months = 1:12,
  split_year = 2000,
  min_coverage = 0.8
)
```

## Arguments

- data:

  A data frame with the columns `year`, `month` and the column named in
  `variable`. Defaults to
  [melb_temp](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/melb_temp.md).

- variable:

  Which temperature to use: `"tmax"` (daily maximum, hot days) or
  `"tmin"` (daily minimum, hot nights).

- thresholds:

  Numeric vector of thresholds in degrees Celsius. By default 25 to 40
  for `"tmax"` and 12 to 26 for `"tmin"`, in steps of 1.

- months:

  Integer vector of months to include, 1 (January) to 12 (December).
  Defaults to the whole year. Years are calendar years, so a summer
  spanning December to February is split across two years.

- split_year:

  A single year. Years `<= split_year` form the earlier period and years
  after it the later period.

- min_coverage:

  A number between 0 and 1. A year is marked `reliable` when the share
  of days in the chosen months with an observation is at least this
  value.

## Value

A data frame with one row per threshold and columns `threshold`,
`mean_before`, `mean_after` (average days per year in each period),
`n_before`, `n_after` (reliable years used), `difference`
(`mean_after - mean_before`) and `ratio` (`mean_after / mean_before`,
`NA` when the earlier average is 0). The settings are kept in
`attr(, "settings")`.

## See also

[`plot_sensitivity()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/plot_sensitivity.md)
to draw the result.

## Examples

``` r
sens <- threshold_sensitivity(thresholds = c(30, 35, 40), split_year = 2000)
sens
#>   threshold mean_before mean_after n_before n_after difference    ratio
#> 1        30  28.8333333  36.571429       30      21   7.738095 1.268373
#> 2        35   8.2000000  11.761905       30      21   3.561905 1.434379
#> 3        40   0.8333333   2.428571       30      21   1.595238 2.914286
```
