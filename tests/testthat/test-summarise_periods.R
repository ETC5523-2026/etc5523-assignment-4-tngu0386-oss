test_that("periods are averaged over reliable years only", {
  ex <- data.frame(
    year = 2000:2005,
    n_exceed = c(2L, 4L, 100L, 6L, 8L, 10L),
    reliable = c(TRUE, TRUE, FALSE, TRUE, TRUE, TRUE)
  )
  out <- summarise_periods(ex, split_year = 2002)
  expect_equal(nrow(out), 2L)
  expect_equal(out$n_years, c(2L, 3L))
  expect_equal(out$mean_exceed, c(3, 8))
  expect_equal(out$first_year, c(2000L, 2003L))
})

test_that("an empty period gives NA rather than an error", {
  ex <- data.frame(year = 2000:2002, n_exceed = 1:3, reliable = TRUE)
  out <- summarise_periods(ex, split_year = 2010)
  expect_equal(out$n_years, c(3L, 0L))
  expect_true(is.na(out$mean_exceed[2]))
})

test_that("bad input is rejected", {
  expect_error(summarise_periods(data.frame(a = 1), 2000), "annual_exceedances")
  ex <- data.frame(year = 2000:2002, n_exceed = 1:3, reliable = TRUE)
  expect_error(summarise_periods(ex, c(2000, 2001)), "split_year")
})

test_that("year-to-year spread is reported", {
  ex <- data.frame(year = 2000:2005, n_exceed = c(2L, 4L, 6L, 10L, 10L, 10L),
                   reliable = TRUE)
  out <- summarise_periods(ex, split_year = 2002)
  expect_equal(out$sd_exceed, c(stats::sd(c(2, 4, 6)), 0))
  one <- summarise_periods(ex, split_year = 2004)
  expect_equal(one$n_years, c(5L, 1L))
  expect_true(is.na(one$sd_exceed[2]))
})

test_that("settings and the split year are kept", {
  ex <- annual_exceedances(threshold = 35)
  s <- attr(summarise_periods(ex, 2000), "settings")
  expect_equal(s$split_year, 2000L)
  expect_equal(s$threshold, 35)
})
