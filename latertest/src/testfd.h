void func(int *value, void *data) {}

[[cpp11::register]] int testfd() {
  later::later_fd(func, nullptr, 0, nullptr, 0.0, 0);
  return 0;
}
