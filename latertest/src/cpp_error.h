// Rf_onintr is not exposed via public R headers; declare with C linkage.
extern "C" void Rf_onintr(void);

void oof(void *data) {
  int *v = (int *)data;
  int value = *v;
  delete v;

  if (value == 1) {
    throw std::runtime_error("This is a C++ exception.");

  } else if (value == 2) {
    // Throw an arbitrary object
    throw std::string();

  } else if (value == 3) {
    // Interrupt the interpreter
    Rf_onintr();

  } else if (value == 4) {
    // Calls R function, which interrupts
    SEXP e;
    PROTECT(e = Rf_lang1(Rf_install("r_interrupt")));
    Rf_eval(e, R_GlobalEnv);
    UNPROTECT(1);

  } else if (value == 5) {
    // Calls R function which calls stop()
    SEXP e;
    PROTECT(e = Rf_lang1(Rf_install("r_error")));
    Rf_eval(e, R_GlobalEnv);
    UNPROTECT(1);

  } else if (value == 6) {
    // Calls the `r_error` function via R's C API
    SEXP e;
    PROTECT(e = Rf_lang1(Rf_install("r_error")));
    Rf_eval(e, R_GlobalEnv);
    UNPROTECT(1);
  }
}

[[cpp11::register]] void cpp_error(int value) {
  int *v = new int(value);
  later::later(oof, v, 0);
}
