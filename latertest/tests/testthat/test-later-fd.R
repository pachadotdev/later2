test_that("later_fd C API works", {
  skip_if(later:::using_ubsan())
  expect_equal(testfd(), 0L)
  later::run_now()
})
