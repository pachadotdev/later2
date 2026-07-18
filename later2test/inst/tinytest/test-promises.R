local({
  # later C++ BackgroundTask class works with later2's own promise
  # implementation ----
  #
  # Note: this deliberately uses later2::promise/then/catch (not the
  # `promises` package). `promises` schedules its callbacks via
  # `later::later()`, which runs on a different event loop than later2, so
  # `later2::run_now()` would never trigger their resolution.

  # test that resolve works
  result <- 0
  later2::promise(function(resolve, reject) {
    later2test::asyncFib(resolve, reject, 3)
  }) |>
    later2::then(\(x) {
      result <<- x
    })

  expect_identical(result, 0)
  later2::run_now(1)
  while (!later2::loop_empty()) {
    later2::run_now(0.1)
  }
  expect_identical(result, 2)

  # test that reject works (swap resolve/reject)
  err_result <- 0
  later2::promise(function(resolve, reject) {
    later2test::asyncFib(reject, resolve, 6)
  }) |>
    later2::catch(\(x) {
      err_result <<- x
    })

  expect_identical(err_result, 0)
  later2::run_now(1)
  while (!later2::loop_empty()) {
    later2::run_now(0.1)
  }
  expect_identical(err_result, 8)
})

