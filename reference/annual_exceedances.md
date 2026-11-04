# Count the days each year above a temperature threshold

For every year, counts the days on which the daily maximum (hot days) or
daily minimum (hot nights) temperature was **above** `threshold`,
restricted to the chosen months. Days without an observation cannot be
counted, so the function also reports how much of each year was observed
and flags years whose coverage falls below `min_coverage`. An incomplete
year is then not mistaken for a cool one.

## Usage

``` r
annual_exceedances(
  data = melbheat::melb_temp,
  variable = c("tmax", "tmin"),
  threshold,
  months = 1:12,
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

- threshold:

  A single number: the temperature in degrees Celsius. A day counts when
  its temperature is strictly greater than this value.

- months:

  Integer vector of months to include, 1 (January) to 12 (December).
  Defaults to the whole year. Years are calendar years, so a summer
  spanning December to February is split across two years.

- min_coverage:

  A number between 0 and 1. A year is marked `reliable` when the share
  of days in the chosen months with an observation is at least this
  value.

## Value

A data frame with one row per year and columns:

- year:

  Calendar year.

- n_days:

  Number of calendar days in the chosen months.

- n_observed:

  Days with a recorded temperature.

- n_exceed:

  Observed days above `threshold`.

- coverage:

  `n_observed / n_days`.

- prop_exceed:

  `n_exceed / n_observed`, or `NA` if nothing was observed.

- reliable:

  `TRUE` if `coverage >= min_coverage`.

The settings used are stored in `attr(, "settings")` so that
[`summarise_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/summarise_periods.md),
[`describe_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/describe_periods.md)
and
[`plot_exceedances()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/plot_exceedances.md)
can label their results without being told again.

## Details

Use this function when you need one number per year to compare across
time. Do not use the counts of a year marked `reliable = FALSE` as if
they were complete: they are lower bounds.

## See also

[`summarise_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/summarise_periods.md)
to compare two periods and
[`plot_exceedances()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/plot_exceedances.md)
to draw the result.

## Examples

``` r
# Days above 35 degrees, whole year
ex <- annual_exceedances(threshold = 35)
tail(ex)
#>    year n_days n_observed n_exceed  coverage prop_exceed reliable
#> 48 2017    365        365       10 1.0000000  0.02739726     TRUE
#> 49 2018    365        365       11 1.0000000  0.03013699     TRUE
#> 50 2019    365        365       22 1.0000000  0.06027397     TRUE
#> 51 2020    366        366        5 1.0000000  0.01366120     TRUE
#> 52 2021    365        365        4 1.0000000  0.01095890     TRUE
#> 53 2022    365        201        5 0.5506849  0.02487562    FALSE

# Warm nights (minimum above 20 degrees) in December to February
annual_exceedances(variable = "tmin", threshold = 20, months = c(12, 1, 2))
#>    year n_days n_observed n_exceed  coverage prop_exceed reliable
#> 1  1970     90         31        1 0.3444444  0.03225806    FALSE
#> 2  1971     90         90        5 1.0000000  0.05555556     TRUE
#> 3  1972     91         91        2 1.0000000  0.02197802     TRUE
#> 4  1973     90         90        3 1.0000000  0.03333333     TRUE
#> 5  1974     90         90        8 1.0000000  0.08888889     TRUE
#> 6  1975     90         90        4 1.0000000  0.04444444     TRUE
#> 7  1976     91         91        2 1.0000000  0.02197802     TRUE
#> 8  1977     90         90        1 1.0000000  0.01111111     TRUE
#> 9  1978     90         90        3 1.0000000  0.03333333     TRUE
#> 10 1979     90         90        6 1.0000000  0.06666667     TRUE
#> 11 1980     91         91        3 1.0000000  0.03296703     TRUE
#> 12 1981     90         90        8 1.0000000  0.08888889     TRUE
#> 13 1982     90         90        8 1.0000000  0.08888889     TRUE
#> 14 1983     90         90        4 1.0000000  0.04444444     TRUE
#> 15 1984     91         91        0 1.0000000  0.00000000     TRUE
#> 16 1985     90         90        0 1.0000000  0.00000000     TRUE
#> 17 1986     90         90        1 1.0000000  0.01111111     TRUE
#> 18 1987     90         90        1 1.0000000  0.01111111     TRUE
#> 19 1988     91         91        4 1.0000000  0.04395604     TRUE
#> 20 1989     90         90        1 1.0000000  0.01111111     TRUE
#> 21 1990     90         88        2 0.9777778  0.02272727     TRUE
#> 22 1991     90         90        3 1.0000000  0.03333333     TRUE
#> 23 1992     91         91        0 1.0000000  0.00000000     TRUE
#> 24 1993     90         90        5 1.0000000  0.05555556     TRUE
#> 25 1994     90         90        3 1.0000000  0.03333333     TRUE
#> 26 1995     90         90        8 1.0000000  0.08888889     TRUE
#> 27 1996     91         91        1 1.0000000  0.01098901     TRUE
#> 28 1997     90         90       11 1.0000000  0.12222222     TRUE
#> 29 1998     90         90        4 1.0000000  0.04444444     TRUE
#> 30 1999     90         90        6 1.0000000  0.06666667     TRUE
#> 31 2000     91         91        5 1.0000000  0.05494505     TRUE
#> 32 2001     90         90       13 1.0000000  0.14444444     TRUE
#> 33 2002     90         90        4 1.0000000  0.04444444     TRUE
#> 34 2003     90         90        8 1.0000000  0.08888889     TRUE
#> 35 2004     91         91        0 1.0000000  0.00000000     TRUE
#> 36 2005     90         90        1 1.0000000  0.01111111     TRUE
#> 37 2006     90         90        7 1.0000000  0.07777778     TRUE
#> 38 2007     90         90        7 1.0000000  0.07777778     TRUE
#> 39 2008     91         91        4 1.0000000  0.04395604     TRUE
#> 40 2009     90         90        4 1.0000000  0.04444444     TRUE
#> 41 2010     90         90        6 1.0000000  0.06666667     TRUE
#> 42 2011     90         90        5 1.0000000  0.05555556     TRUE
#> 43 2012     91         91        8 1.0000000  0.08791209     TRUE
#> 44 2013     90         90        4 1.0000000  0.04444444     TRUE
#> 45 2014     90         90        7 1.0000000  0.07777778     TRUE
#> 46 2015     90         90        6 1.0000000  0.06666667     TRUE
#> 47 2016     91         91        6 1.0000000  0.06593407     TRUE
#> 48 2017     90         90        5 1.0000000  0.05555556     TRUE
#> 49 2018     90         90        9 1.0000000  0.10000000     TRUE
#> 50 2019     90         90        2 1.0000000  0.02222222     TRUE
#> 51 2020     91         91        3 1.0000000  0.03296703     TRUE
#> 52 2021     90         90        1 1.0000000  0.01111111     TRUE
#> 53 2022     90         59        1 0.6555556  0.01694915    FALSE
```
