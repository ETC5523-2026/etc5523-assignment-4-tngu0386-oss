#' Daily temperatures at Melbourne Airport, 1970 to 2022
#'
#' Daily maximum and minimum air temperature recorded at the Melbourne Airport
#' weather station (Bureau of Meteorology station 086282). Every calendar day
#' from 1 January 1970 to 26 July 2022 has a row, so days without an
#' observation appear as `NA` rather than being dropped. Readings that
#' accumulate over more than one day were set to `NA` because they cannot be
#' assigned to a single date.
#'
#' @format A data frame with one row per calendar day and 7 columns:
#' \describe{
#'   \item{date}{Calendar date (`Date`).}
#'   \item{year}{Calendar year (integer).}
#'   \item{month}{Calendar month, 1 (January) to 12 (December) (integer).}
#'   \item{tmax}{Daily maximum temperature in degrees Celsius; `NA` if not
#'     observed.}
#'   \item{tmax_quality}{Bureau of Meteorology quality flag for `tmax`:
#'     `"Y"` if quality controlled, `"N"` if not yet completely quality
#'     controlled; `NA` if there is no observation.}
#'   \item{tmin}{Daily minimum temperature in degrees Celsius, recorded over
#'     the 24 hours to 9am; `NA` if not observed.}
#'   \item{tmin_quality}{Quality flag for `tmin`, coded as for
#'     `tmax_quality`.}
#' }
#' @source Australian Bureau of Meteorology, Climate Data Online,
#'   <http://www.bom.gov.au/climate/data/>, products IDCJAC0010 (maximum
#'   temperature) and IDCJAC0011 (minimum temperature), station 086282.
#'   Copyright Commonwealth of Australia, Bureau of Meteorology. The data
#'   preparation script is in `data-raw/melb_temp.R`.
#'
#' @examples
#' head(melb_temp)
#' summary(melb_temp$tmax)
"melb_temp"
