#include <cstring>

/* roxygen
@title Testing Function
@rdname testing
@export
*/
[[cpp4r::register]] int later2_dll_api_version() {
  // See later2_api.h's detail::from_dl_func() for why this uses memcpy
  // instead of a direct function-pointer cast (which would trigger
  // -Wcast-function-type and, if suppressed via pragma, a CRAN check NOTE).
  DL_FUNC raw = R_GetCCallable("later2", "apiVersion");
  int (*dll_api_version)();
  static_assert(sizeof(dll_api_version) == sizeof(raw),
                "function pointer size mismatch");
  std::memcpy(&dll_api_version, &raw, sizeof(dll_api_version));
  return (*dll_api_version)();
}

/* roxygen
@title Testing Function
@rdname testing
@export
*/
[[cpp4r::register]] int later2_h_api_version() { return LATER2_H_API_VERSION; }
