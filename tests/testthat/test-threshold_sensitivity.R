test_that("one row per threshold with matching averages", {
  sens <- threshold_sensitivity(thresholds = c(40, 30, 35, 35), split_year = 2000)
  expect_equal(sens$threshold, c(30, 35, 40))
  expect_equal(sens$difference, sens$mean_after - sens$mean_before)

  ex <- annual_exceedances(threshold = 35)
  sp <- summarise_periods(ex, 2000)
  expect_equal(sens$mean_before[2], sp$mean_exceed[1])
  expect_equal(sens$mean_after[2], sp$mean_exceed[2])
})

test_that("ratio is NA when the earlier period has no hot days", {
  sens <- threshold_sensitivity(thresholds = c(35, 60), split_year = 2000)
  expect_true(is.na(sens$ratio[2]))
  expect_equal(sens$mean_before[2], 0)
})

test_that("default thresholds depend on the measure", {
  expect_equal(range(threshold_sensitivity()$threshold), c(25, 40))
  expect_equal(range(threshold_sensitivity(variable = "tmin")$threshold), c(12, 26))
})

test_that("bad thresholds are explained", {
  expect_error(threshold_sensitivity(thresholds = "hot"), "non-empty numeric")
  expect_error(threshold_sensitivity(thresholds = numeric(0)), "thresholds")
})
