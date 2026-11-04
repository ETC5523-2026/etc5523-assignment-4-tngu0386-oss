# Prepare `melb_temp`: daily maximum and minimum temperature at the Melbourne
# Airport weather station (BoM station 086282).
#
# Run from the package root:  source("data-raw/melb_temp.R")
# Needs the `usethis` package to save the result into `data/`.
#
# Raw inputs (downloaded from the Bureau of Meteorology's Climate Data Online,
# supplied with the ETC5523 unit materials, and kept unmodified in this folder):
#   data-raw/melb-airport-max-temp-data.csv   (product IDCJAC0010)
#   data-raw/melb-airport-min-temp-data.csv   (product IDCJAC0011)

read_bom <- function(path, value_name) {
  raw <- read.csv(
    path,
    check.names = FALSE,
    stringsAsFactors = FALSE,
    colClasses = c("character", "character", "integer", "integer", "integer",
                   "numeric", "integer", "character")
  )
  names(raw) <- c("product", "station", "year", "month", "day",
                  "value", "accumulation_days", "quality")

  # Every row must come from the Melbourne Airport station.
  stopifnot(all(raw$station == "086282"))

  # A reading covering more than one day (accumulation_days > 1) cannot be
  # attributed to a single date, so it is treated as missing.
  multi_day <- !is.na(raw$accumulation_days) & raw$accumulation_days > 1
  raw$value[multi_day] <- NA_real_

  # Blank quality flags mean "no observation".
  raw$quality[raw$quality == ""] <- NA_character_

  date <- as.Date(sprintf("%04d-%02d-%02d", raw$year, raw$month, raw$day))
  out <- data.frame(date = date, value = raw$value, quality = raw$quality,
                    stringsAsFactors = FALSE)
  names(out) <- c("date", value_name, paste0(value_name, "_quality"))
  out
}

tmax <- read_bom("data-raw/melb-airport-max-temp-data.csv", "tmax")
tmin <- read_bom("data-raw/melb-airport-min-temp-data.csv", "tmin")

# Keep every calendar day so that missing observations are explicit.
melb_temp <- merge(tmax, tmin, by = "date", all = TRUE)
melb_temp <- melb_temp[order(melb_temp$date), ]
melb_temp$year <- as.integer(format(melb_temp$date, "%Y"))
melb_temp$month <- as.integer(format(melb_temp$date, "%m"))
melb_temp <- melb_temp[, c("date", "year", "month",
                           "tmax", "tmax_quality", "tmin", "tmin_quality")]
rownames(melb_temp) <- NULL

# Sanity checks: one row per date, plausible temperatures.
stopifnot(
  !anyDuplicated(melb_temp$date),
  all(melb_temp$tmax > -10 & melb_temp$tmax < 55, na.rm = TRUE),
  all(melb_temp$tmin > -10 & melb_temp$tmin < 40, na.rm = TRUE)
)

usethis::use_data(melb_temp, overwrite = TRUE, compress = "bzip2")

