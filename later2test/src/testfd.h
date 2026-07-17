void func(int *value, void *data) {}

/* roxygen
@title Testing Function
@rdname testing
@export
*/
[[cpp4r::register]] int testfd() {
  later2::later_fd(func, nullptr, 0, nullptr, 0.0, 0);
  return 0;
}
