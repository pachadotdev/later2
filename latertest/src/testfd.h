void func(int *value, void *data) {}

[[cpp4r::register]] int testfd() {
  later::later_fd(func, nullptr, 0, nullptr, 0.0, 0);
  return 0;
}
