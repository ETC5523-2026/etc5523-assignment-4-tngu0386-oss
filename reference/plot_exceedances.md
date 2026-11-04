# Chart the number of hot days (or nights) per year

Draws one bar per year from
[`annual_exceedances()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/annual_exceedances.md).
Years with too many missing days are grey. If `split_year` is given, a
dashed line separates the two periods, a dark line marks each period's
average, and the title states the claim the chart supports (see
[`describe_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/describe_periods.md)).
Only the hottest year is labelled, so the label points to the one
observation that stands out.

## Usage

``` r
plot_exceedances(exceedances, split_year = NULL, base_size = 14)
```

## Arguments

- exceedances:

  A data frame returned by
  [`annual_exceedances()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/annual_exceedances.md).

- split_year:

  Optional single year at which to split the record into two periods.

- base_size:

  Base font size passed to the theme.

## Value

A `ggplot` object, so it can be changed or saved with
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html).

## See also

[`plot_sensitivity()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/plot_sensitivity.md)

## Examples

``` r
ex <- annual_exceedances(threshold = 35)
plot_exceedances(ex, split_year = 2000)
```
