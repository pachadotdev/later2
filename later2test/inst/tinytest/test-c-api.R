local({
  # header and DLL API versions match ----
  expect_equal(later2test::later2_dll_api_version(), later2test::later2_h_api_version())
})
