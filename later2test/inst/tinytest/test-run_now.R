local({
  # run_now wakes up when a background thread calls later() ----

  # Skip due to false positives on UBSAN
  if (isTRUE(later2:::using_ubsan())) { return (NULL) }

  # The background task sleeps
  latertest::launchBgTask(1)

  x <- system.time({
    result <- later2::run_now(3)
  })
  # Wait for up to 1.5 seconds (for slow systems)
  expect_true(as.numeric(x[["elapsed"]]) < 1.5)
  expect_true(result)
})

local({
  # When callbacks have tied timestamps, they respect order of creation ----

  # Skip due to false positives on UBSAN
  if (isTRUE(later2:::using_ubsan())) { return (NULL) }

  expect_silent(later2:::testCallbackOrdering())

  latertest::checkLaterOrdering()

  while (!later2::loop_empty()) {
    later2::run_now(0.1)
  }
})

local({
  # interrupt and exception handling, C++ ----

  if (Sys.getenv("LATER_FULL_TEST") != "yes") { return(NULL) }
  
  if (isTRUE(later2:::using_ubsan())) { return (NULL) }

  if (R.version$os == "mingw32" && R.version$arch == "i386") {
    skip("C++ exceptions in later callbacks are known bad on Windows i386")
  }

  .GlobalEnv$r_interrupt <- function() rlang::interrupt()
  .GlobalEnv$r_error <- function() stop("oopsie")
  on.exit(rm(r_interrupt, r_error, envir = .GlobalEnv), add = TRUE)

  errored <- FALSE
  tryCatch({ cpp_error(1); later2::run_now(Inf) }, error = function(e) errored <<- TRUE)
  expect_true(errored)

  errored <- FALSE
  tryCatch({ cpp_error(2); later2::run_now(-1) }, error = function(e) errored <<- TRUE)
  expect_true(errored)

  errored <- FALSE
  tryCatch({ cpp_error(5); later2::run_now() }, error = function(e) errored <<- TRUE)
  expect_true(errored)

  errored <- FALSE
  tryCatch({ cpp_error(6); later2::run_now() }, error = function(e) errored <<- TRUE)
  expect_true(errored)

  interrupted <- FALSE
  tryCatch({ cpp_error(3); later2::run_now() }, interrupt = function(e) interrupted <<- TRUE)
  expect_true(interrupted)

  interrupted <- FALSE
  tryCatch({ cpp_error(4); later2::run_now() }, interrupt = function(e) interrupted <<- TRUE)
  expect_true(interrupted)
})
