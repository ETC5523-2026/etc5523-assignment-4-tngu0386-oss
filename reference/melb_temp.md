# Daily temperatures at Melbourne Airport, 1970 to 2022

Daily maximum and minimum air temperature recorded at the Melbourne
Airport weather station (Bureau of Meteorology station 086282). Every
calendar day from 1 January 1970 to 26 July 2022 has a row, so days
without an observation appear as `NA` rather than being dropped.
Readings that accumulate over more than one day were set to `NA` because
they cannot be assigned to a single date.

## Usage

``` r
melb_temp
```

## Format

A data frame with one row per calendar day and 7 columns:

- date:

  Calendar date (`Date`).

- year:

  Calendar year (integer).

- month:

  Calendar month, 1 (January) to 12 (December) (integer).

- tmax:

  Daily maximum temperature in degrees Celsius; `NA` if not observed.

- tmax_quality:

  Bureau of Meteorology quality flag for `tmax`: `"Y"` if quality
  controlled, `"N"` if not yet completely quality controlled; `NA` if
  there is no observation.

- tmin:

  Daily minimum temperature in degrees Celsius, recorded over the 24
  hours to 9am; `NA` if not observed.

- tmin_quality:

  Quality flag for `tmin`, coded as for `tmax_quality`.

## Source

Australian Bureau of Meteorology, Climate Data Online,
<http://www.bom.gov.au/climate/data/>, products IDCJAC0010 (maximum
temperature) and IDCJAC0011 (minimum temperature), station 086282.
Copyright Commonwealth of Australia, Bureau of Meteorology. The data
preparation script is in `data-raw/melb_temp.R`.

## Examples

``` r
head(melb_temp)
#>         date year month tmax tmax_quality tmin tmin_quality
#> 1 1970-01-01 1970     1   NA         <NA>   NA         <NA>
#> 2 1970-01-02 1970     1   NA         <NA>   NA         <NA>
#> 3 1970-01-03 1970     1   NA         <NA>   NA         <NA>
#> 4 1970-01-04 1970     1   NA         <NA>   NA         <NA>
#> 5 1970-01-05 1970     1   NA         <NA>   NA         <NA>
#> 6 1970-01-06 1970     1   NA         <NA>   NA         <NA>
summary(melb_temp$tmax)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.     NAs 
#>    5.70   14.80   18.60   19.87   23.60   46.80     188 
```
