# Launch the Melbourne Airport heat explorer

Starts the Shiny app that is installed with the package in `inst/app`.
The app is built for a council or emergency-planning officer who wants
to know whether days above a chosen temperature have become more
frequent at Melbourne Airport, and whether the answer depends on what
counts as "hot".

## Usage

``` r
run_app(...)
```

## Arguments

- ...:

  Further arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), for
  example `launch.browser = FALSE` or `port = 4321`.

## Value

Called for its side effect of starting the app; it does not return a
value.

## Examples

``` r
if (interactive()) {
  run_app()
}
```
