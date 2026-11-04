make_days <- function() {
  dates <- seq(as.Date("2000-01-01"), as.Date("2001-12-31"), by = "day")
  data.frame(
    date = dates,
    year = as.integer(format(dates, "%Y")),
    month = as.integer(format(dates, "%m")),
    tmax = 20,
    tmin = 10
  )
}

test_that("days above the threshold are counted per year", {
  d <- make_days()
  d$tmax[d$date %in% as.Date(c("2000-01-05", "2000-01-06", "2001-02-01"))] <- 38
  out <- annual_exceedances(d, "tmax", threshold = 35)
  expect_equal(out$year, c(2000L, 2001L))
  expect_equal(out$n_exceed, c(2L, 1L))
  expect_true(all(out$reliable))
})

test_that("the threshold is strict and months are respected", {
  d <- make_days()
  d$tmax[d$date == as.Date("2000-07-01")] <- 35
  d$tmax[d$date == as.Date("2000-01-10")] <- 36
  expect_equal(annual_exceedances(d, "tmax", 35)$n_exceed[1], 1L)
  expect_equal(annual_exceedances(d, "tmax", 35, months = 7)$n_exceed[1], 0L)
  expect_equal(annual_exceedances(d, "tmax", 34, months = 7)$n_days[1], 31L)
})

test_that("missing days lower coverage and flag unreliable years", {
  d <- make_days()
  d$tmax[d$year == 2001 & d$month <= 6] <- NA
  out <- annual_exceedances(d, "tmax", threshold = 35, min_coverage = 0.8)
  expect_lt(out$coverage[out$year == 2001], 0.8)
  expect_equal(out$reliable, c(TRUE, FALSE))
})

test_that("invalid input gives an informative error", {
  d <- make_days()
  expect_error(annual_exceedances(d, "tmax"), "threshold")
  expect_error(annual_exceedances(d, "tmax", threshold = NA_real_), "threshold")
  expect_error(annual_exceedances(d, "tmax", threshold = 35, months = integer(0)),
               "months")
  expect_error(annual_exceedances(d, "tmax", threshold = 35, months = 13), "months")
  expect_error(annual_exceedances(d, "tmax", threshold = 35, min_coverage = 2),
               "min_coverage")
})

test_that("the bundled data work with the function", {
  out <- annual_exceedances(threshold = 30)
  expect_true(all(out$n_exceed <= out$n_observed))
  expect_true(all(out$coverage >= 0 & out$coverage <= 1))
})

test_that("a year that stops part-way is not treated as complete", {
  d <- make_days()
  d <- d[d$date <= as.Date("2001-07-31"), ]
  out <- annual_exceedances(d, "tmax", threshold = 35)
  expect_equal(out$n_days, c(366L, 365L))
  expect_lt(out$coverage[out$year == 2001], 0.8)
  expect_false(out$reliable[out$year == 2001])
})

test_that("the bundled data mark 2022 and 1970 as unreliable", {
  out <- annual_exceedances(threshold = 35)
  expect_false(out$reliable[out$year == 2022])
  expect_false(out$reliable[out$year == 1970])
  expect_true(out$reliable[out$year == 2000])
})

test_that("settings travel with the result", {
  d <- make_days()
  out <- annual_exceedances(d, "tmin", threshold = 12, months = c(2, 1, 1))
  s <- attr(out, "settings")
  expect_equal(s$variable, "tmin")
  expect_equal(s$threshold, 12)
  expect_equal(s$months, c(1L, 2L))
})

test_that("error messages say what to do", {
  d <- make_days()
  expect_error(annual_exceedances(d, "tmax"), "Give a temperature")
  expect_error(annual_exceedances(d, "tmax", threshold = 35, months = 0), "You supplied")
  expect_error(annual_exceedances(data.frame(a = 1), "tmax", threshold = 35),
               "bundled")
})
