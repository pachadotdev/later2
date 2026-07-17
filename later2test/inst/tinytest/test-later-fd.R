local({
  # later_fd C API works ----
  if (later2:::using_ubsan()) { return (NULL) }
  expect_equal(latertest::testfd(), 0L)
  later2::run_now()
})
