test_that("plot_exceedances returns a ggplot that can be drawn", {
  ex <- annual_exceedances(threshold = 35)
  p <- plot_exceedances(ex, split_year = 2000)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  expect_match(p$labels$title, "after 2000")
  expect_s3_class(plot_exceedances(ex), "ggplot")
})

test_that("the title says what to change when there is too little data", {
  ex <- annual_exceedances(threshold = 35, min_coverage = 1)
  p <- plot_exceedances(ex, split_year = 2000)
  expect_no_error(ggplot2::ggplot_build(p))
  expect_match(p$labels$title, "^Days per year|Not enough|hot days")
})

test_that("a threshold nobody reaches still draws", {
  ex <- annual_exceedances(threshold = 60)
  expect_no_error(ggplot2::ggplot_build(plot_exceedances(ex, 2000)))
})

test_that("plot_sensitivity states how many thresholds agree", {
  sens <- threshold_sensitivity(thresholds = 28:38, split_year = 2000)
  p <- plot_sensitivity(sens, highlight = 35)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  expect_match(p$labels$title, "every threshold tested|of 11 thresholds")
})

test_that("wrong inputs are explained", {
  expect_error(plot_exceedances(data.frame(a = 1)), "annual_exceedances")
  expect_error(plot_exceedances(annual_exceedances(threshold = 35), split_year = "a"),
               "split_year")
  expect_error(plot_sensitivity(data.frame(a = 1)), "threshold_sensitivity")
})
