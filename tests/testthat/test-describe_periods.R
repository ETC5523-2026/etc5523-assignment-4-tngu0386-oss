periods_for <- function(n_exceed, split_year, years = 2000:2009) {
  ex <- data.frame(year = years, n_exceed = n_exceed, reliable = TRUE)
  attr(ex, "settings") <- list(variable = "tmax", threshold = 35)
  summarise_periods(ex, split_year)
}

test_that("a clear increase is described with a range that excludes zero", {
  p <- periods_for(c(1, 2, 1, 2, 1, 10, 11, 10, 11, 10), 2004)
  d <- describe_periods(p)
  expect_true(d$enough_data)
  expect_equal(d$gap, 9)
  expect_gt(d$low, 0)
  expect_match(d$title, "9.0 more hot days a year after 2004")
  expect_match(d$headline, "above 35")
  expect_match(d$how_sure, "stands out")
})

test_that("a gap inside the noise says so", {
  p <- periods_for(c(0, 10, 2, 12, 4, 6, 14, 1, 11, 3), 2004)
  d <- describe_periods(p)
  expect_lt(d$low, 0)
  expect_gt(d$high, 0)
  expect_match(d$how_sure, "within the usual year-to-year noise")
})

test_that("a decrease and no change get matching wording", {
  p <- periods_for(c(10, 11, 10, 11, 10, 1, 2, 1, 2, 1), 2004)
  expect_match(describe_periods(p)$title, "fewer hot days")
  flat <- periods_for(c(5, 6, 5, 6, 5, 5, 6, 5, 6, 5), 2004)
  expect_match(describe_periods(flat)$title, "about the same")
})

test_that("hot nights use the right words", {
  ex <- annual_exceedances(variable = "tmin", threshold = 20)
  d <- describe_periods(summarise_periods(ex, 2000))
  expect_match(d$headline, "daily minimum above 20")
  expect_match(d$title, "hot nights")
})

test_that("too few years returns advice, not an error", {
  ex <- data.frame(year = 2000:2004, n_exceed = 1:5, reliable = TRUE)
  d <- describe_periods(summarise_periods(ex, 2001))
  expect_false(d$enough_data)
  expect_true(is.na(d$gap))
  expect_match(d$how_sure, "Move the comparison year")
})

test_that("input from the wrong function is rejected", {
  expect_error(describe_periods(data.frame(a = 1)), "summarise_periods")
})

test_that("nothing to count returns advice, not a gap of zero", {
  p <- periods_for(rep(0, 10), 2004)
  d <- describe_periods(p)
  expect_false(d$enough_data)
  expect_match(d$headline, "No year in either period")
  expect_true(is.na(d$gap))
})
