# Data provenance

`melb-airport-max-temp-data.csv` and `melb-airport-min-temp-data.csv` are daily
temperature observations for the **Melbourne Airport** weather station
(Bureau of Meteorology station number 086282), downloaded from the Bureau of
Meteorology's Climate Data Online (<http://www.bom.gov.au/climate/data/>).
They were supplied with the ETC5523 unit materials and are kept unmodified.

* Product IDCJAC0010: daily maximum temperature (degrees Celsius)
* Product IDCJAC0011: daily minimum temperature (degrees Celsius)

Run `source("data-raw/melb_temp.R")` from the package root to rebuild
`data/melb_temp.rda`. The script

1. reads both files,
2. sets readings that accumulate over more than one day to missing,
3. converts blank quality flags to `NA`,
4. joins maximum and minimum temperature by date, keeping every calendar
   day so that missing observations stay visible, and
5. saves the result with `usethis::use_data()`.

Data are Copyright Commonwealth of Australia, Bureau of Meteorology, and are
used here for educational purposes with attribution.
