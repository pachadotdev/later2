test_that("header and DLL API versions match", {
  expect_identical(later_dll_api_version(), later_h_api_version())
})
