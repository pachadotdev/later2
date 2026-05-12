test_that("run_now wakes up when a background thread calls later()", {
  # Skip due to false positives on UBSAN
  skip_if(later:::using_ubsan())

  # The background task sleeps
  launchBgTask(1)

  x <- system.time({
    result <- later::run_now(3)
  })
  # Wait for up to 1.5 seconds (for slow systems)
  expect_lt(as.numeric(x[["elapsed"]]), 1.5)
  expect_true(result)
})

test_that("When callbacks have tied timestamps, they respect order of creation", {
  # Skip due to false positives on UBSAN
  skip_if(later:::using_ubsan())

  expect_snapshot(later:::testCallbackOrdering())

  checkLaterOrdering()

  while (!later::loop_empty()) {
    later::run_now(0.1)
  }
})

test_that("interrupt and exception handling, C++", {
  skip_on_cran()
  skip_if(later:::using_ubsan())
  if (R.version$os == "mingw32" && R.version$arch == "i386") {
    skip("C++ exceptions in later callbacks are known bad on Windows i386")
  }

  .GlobalEnv$r_interrupt <- function() rlang::interrupt()
  .GlobalEnv$r_error <- function() stop("oopsie")
  on.exit(rm(r_interrupt, r_error, envir = .GlobalEnv), add = TRUE)

  errored <- FALSE
  tryCatch({ cpp_error(1); later::run_now(Inf) }, error = function(e) errored <<- TRUE)
  expect_true(errored)

  errored <- FALSE
  tryCatch({ cpp_error(2); later::run_now(-1) }, error = function(e) errored <<- TRUE)
  expect_true(errored)

  errored <- FALSE
  tryCatch({ cpp_error(5); later::run_now() }, error = function(e) errored <<- TRUE)
  expect_true(errored)

  errored <- FALSE
  tryCatch({ cpp_error(6); later::run_now() }, error = function(e) errored <<- TRUE)
  expect_true(errored)

  interrupted <- FALSE
  tryCatch({ cpp_error(3); later::run_now() }, interrupt = function(e) interrupted <<- TRUE)
  expect_true(interrupted)

  interrupted <- FALSE
  tryCatch({ cpp_error(4); later::run_now() }, interrupt = function(e) interrupted <<- TRUE)
  expect_true(interrupted)
})
