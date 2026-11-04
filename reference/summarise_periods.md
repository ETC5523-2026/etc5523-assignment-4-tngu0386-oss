# Compare the average annual count before and after a year

Takes the output of
[`annual_exceedances()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/annual_exceedances.md)
and averages the annual count of days above the threshold in two
periods: years up to and including `split_year`, and years after it.
Only years marked `reliable` are used, so the averages are not pulled
down by years with many missing observations.

## Usage

``` r
summarise_periods(exceedances, split_year)
```

## Arguments

- exceedances:

  A data frame returned by
  [`annual_exceedances()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/annual_exceedances.md).

- split_year:

  A single year. Years `<= split_year` form the first period and years
  `> split_year` the second.

## Value

A data frame with two rows (earlier period first) and columns

- period:

  Label of the period.

- first_year, last_year:

  First and last reliable year in the period, `NA` if there is none.

- n_years:

  Number of reliable years in the period.

- mean_exceed:

  Mean annual number of days above the threshold, `NA` if `n_years` is
  0.

- sd_exceed:

  Standard deviation of the annual counts, a measure of year-to-year
  variation; `NA` if `n_years` is below 2.

- min_exceed, max_exceed:

  Smallest and largest annual count in the period, `NA` if `n_years` is
  0.

The settings of `exceedances` plus `split_year` are kept in
`attr(, "settings")`.

## Details

This is a descriptive comparison of two averages. Use
[`describe_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/describe_periods.md)
to put the gap next to the usual year-to-year variation.

## See also

[`describe_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/describe_periods.md)
for a plain-language reading of the result.

## Examples

``` r
ex <- annual_exceedances(threshold = 35)
summarise_periods(ex, split_year = 2000)
#>            period first_year last_year n_years mean_exceed sd_exceed min_exceed
#> 1 2000 or earlier       1971      2000      30      8.2000  4.693356          1
#> 2      after 2000       2001      2021      21     11.7619  5.009039          3
#>   max_exceed
#> 1         18
#> 2         22
```
