/* roxygen
@title Testing Function
@rdname testing
@export
*/
[[cpp4r::register]] int later2_dll_api_version() {
  int (*dll_api_version)() = (int (*)())R_GetCCallable("later2", "apiVersion");
  return (*dll_api_version)();
}

/* roxygen
@title Testing Function
@rdname testing
@export
*/
[[cpp4r::register]] int later2_h_api_version() { return LATER2_H_API_VERSION; }
