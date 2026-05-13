[[cpp11::register]] int later_dll_api_version() {
  int (*dll_api_version)() = (int (*)())R_GetCCallable("later", "apiVersion");
  return (*dll_api_version)();
}

[[cpp11::register]] int later_h_api_version() { return LATER_H_API_VERSION; }
