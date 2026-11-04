# Say what a period comparison shows, and how sure we can be

Turns the output of
[`summarise_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/summarise_periods.md)
into plain-language text with two parts: **what happened** (the
headline) and **how sure we are** (how the gap between the two averages
compares with the usual year-to-year variation).

## Usage

``` r
describe_periods(periods, variable = NULL, threshold = NULL)
```

## Arguments

- periods:

  A data frame returned by
  [`summarise_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/summarise_periods.md).

- variable, threshold:

  Optional overrides for the temperature measure (`"tmax"` or `"tmin"`)
  and threshold used in the wording. By default they are read from the
  settings stored in `periods`.

## Value

A list with elements

- enough_data:

  `TRUE` if each period has at least 3 reliable years and at least one
  of them had a hot day (or night).

- title:

  A one-line claim suitable for a chart title.

- headline:

  A sentence giving the two averages and the gap.

- how_sure:

  A sentence comparing the gap with year-to-year noise.

- gap:

  Later average minus earlier average, in days per year.

- low, high:

  Ends of the rough 95% range for `gap`.

If `enough_data` is `FALSE`, `title`, `headline` and `how_sure` explain
what to change and the numeric elements are `NA`.

## Details

The "how sure" part uses a rough 95% range for the difference in means,
`gap +/- 2 * standard error`, where the standard error combines the
year-to-year spread and the number of years in each period. It treats
years as independent and ignores any trend inside a period, so it is a
guide to whether the gap stands out from noise, not a formal
significance test.

## Examples

``` r
ex <- annual_exceedances(threshold = 35)
periods <- summarise_periods(ex, split_year = 2000)
describe_periods(periods)$headline
#> [1] "In 2001–2021 the airport averaged 11.8 days a year with a daily maximum above 35 °C, against 8.2 in 1971–2000. That is 3.6 more hot days a year."
describe_periods(periods)$how_sure
#> [1] "The gap stands out from year-to-year noise: a rough 95% range for the difference is +0.8 to +6.3 days a year. This treats years as independent, so use it as a guide, not a formal test."
```
