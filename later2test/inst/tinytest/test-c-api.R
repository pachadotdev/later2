local({
  # header and DLL API versions match ----
  expect_equal(latertest::later_dll_api_version(), latertest::later_h_api_version())
})
