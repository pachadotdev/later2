local({
  # later_fd ----

  # Uses the 'parallel' package (part of every base R installation) to
  # obtain real, pollable file descriptors instead of depending on an
  # external socket library. `parallel::mcparallel()` forks a child process
  # and hands back a pipe file descriptor (`$fd[1]`) in the parent that
  # becomes ready for reading once the child produces its result. This is
  # unix-only (fork-based), so the test is skipped elsewhere.
  if (.Platform$OS.type != "unix") return(NULL)

  jobs <- list()

  # A job whose fd becomes ready almost immediately.
  make_ready_fd <- function() {
    job <- parallel::mcparallel(TRUE)
    jobs[[length(jobs) + 1]] <<- job
    Sys.sleep(0.1)
    job
  }

  # A job whose fd stays "not ready" for the lifetime of the test.
  make_pending_fd <- function() {
    job <- parallel::mcparallel({ Sys.sleep(5); TRUE })
    jobs[[length(jobs) + 1]] <<- job
    job
  }

  on.exit({
    for (job in jobs) {
      tryCatch(tools::pskill(job$pid), error = function(e) NULL)
      suppressWarnings(parallel::mccollect(job, wait = TRUE, timeout = 1))
    }
  })

  result <- NULL
  callback <- function(x) result <<- x

  # timeout (both fds pending)
  job1 <- make_pending_fd()
  job2 <- make_pending_fd()
  fd1 <- job1$fd[1]
  fd2 <- job2$fd[1]
  later_fd(callback, c(fd1, fd2), timeout = 0)
  run_now(1)
  expect_equal(result, c(FALSE, FALSE))
  later_fd(callback, c(fd1, fd2), exceptfds = c(fd1, fd2), timeout = 0)
  run_now(1)
  expect_equal(result, c(FALSE, FALSE, FALSE, FALSE))

  # cancellation
  result <- NULL
  cancel <- later_fd(callback, c(fd1, fd2), timeout = 0.2)
  expect_equal(typeof(cancel), "closure")
  expect_true(cancel())
  Sys.sleep(0.25)
  expect_false(cancel())
  vis <- withVisible(cancel())
  expect_false(vis$visible)
  later2::run_now()
  expect_null(result)

  # timeout (> 1 loop)
  later_fd(callback, c(fd1, fd2), timeout = 1.1)
  run_now(1.3)
  expect_equal(result, c(FALSE, FALSE))

  # fd1 ready, fd2 pending
  job1 <- make_ready_fd()
  fd1 <- job1$fd[1]
  later_fd(callback, c(fd1, fd2), timeout = 0.9)
  run_now(1)
  expect_equal(result, c(TRUE, FALSE))

  # both fd1, fd2 ready
  job2 <- make_ready_fd()
  fd2 <- job2$fd[1]
  later_fd(callback, c(fd1, fd2), timeout = 1)
  run_now(1)
  expect_equal(result, c(TRUE, TRUE))

  # no exceptions
  later_fd(callback, c(fd1, fd2), exceptfds = c(fd1, fd2), timeout = -0.1)
  run_now(1)
  expect_equal(result, c(TRUE, TRUE, FALSE, FALSE))

  # fd1 not ready, fd2 ready
  job1 <- make_pending_fd()
  fd1 <- job1$fd[1]
  later_fd(callback, c(fd1, fd2), timeout = 1L)
  run_now(1)
  expect_equal(result, c(FALSE, TRUE))

  # fd2 invalid (already collected/closed)
  suppressWarnings(parallel::mccollect(job2, wait = TRUE, timeout = 1))
  later_fd(callback, c(fd1, fd2), exceptfds = c(fd1, fd2), timeout = 0.1)
  run_now(1)
  expect_length(result, 4L)

  # both fd1, fd2 invalid
  suppressWarnings(parallel::mccollect(job1, wait = TRUE, timeout = 1))
  later_fd(callback, c(fd1, fd2), c(fd1, fd2), timeout = 0)
  run_now(1)
  expect_equal(result, c(NA, NA, NA, NA))

  # no fds supplied
  later_fd(callback, timeout = -1)
  run_now(1)
  expect_equal(result, logical())
})

local({
  # loop_empty() reflects later_fd callbacks ----

  if (.Platform$OS.type != "unix") return(NULL)

  job <- parallel::mcparallel({ Sys.sleep(5); TRUE })
  on.exit({
    tryCatch(tools::pskill(job$pid), error = function(e) NULL)
    suppressWarnings(parallel::mccollect(job, wait = TRUE, timeout = 1))
  })

  fd1 <- job$fd[1]

  expect_true(loop_empty())

  cancel <- later_fd(~ {}, fd1)
  expect_false(loop_empty())
  cancel()
  Sys.sleep(1.25) # check for cancellation happens every ~1 sec
  expect_true(loop_empty())

  later_fd(~ {}, fd1, timeout = 0)
  expect_false(loop_empty())
  run_now(1)
  expect_true(loop_empty())
})

local({
  # later_fd() errors when passed destroyed loops ----

  loop <- create_loop()
  destroy_loop(loop)
  expect_error(later_fd(identity, loop = loop))
})
