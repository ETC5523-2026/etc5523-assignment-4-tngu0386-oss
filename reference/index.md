# Package index

## Launch the app

One call opens the Shiny app in your browser.

- [`run_app()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/run_app.md)
  : Launch the Melbourne Airport heat explorer

## Count and compare

The analysis behind the app. Each function takes the output of the one
before it.

- [`annual_exceedances()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/annual_exceedances.md)
  : Count the days each year above a temperature threshold
- [`summarise_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/summarise_periods.md)
  : Compare the average annual count before and after a year
- [`describe_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/describe_periods.md)
  : Say what a period comparison shows, and how sure we can be
- [`threshold_sensitivity()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/threshold_sensitivity.md)
  : Does the conclusion depend on what counts as "hot"?

## Draw the results

ggplot2 charts that state the finding in their title.

- [`plot_exceedances()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/plot_exceedances.md)
  : Chart the number of hot days (or nights) per year
- [`plot_sensitivity()`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/plot_sensitivity.md)
  : Chart whether the conclusion depends on the threshold

## Data

Daily temperatures at Melbourne Airport, 1970 to 2022.

- [`melb_temp`](https://etc5523-2026.github.io/etc5523-assignment-4-tngu0386-oss/reference/melb_temp.md)
  : Daily temperatures at Melbourne Airport, 1970 to 2022
