void *max_seen = 0;

void callback(void *data) {
  if (data < max_seen) {
    cpp4r::stop("Bad ordering detected");
  }
  max_seen = data;
}

/* roxygen
@title Testing Function
@rdname testing
@export
*/
[[cpp4r::register]] void checkLaterOrdering() {
  max_seen = 0;
  for (size_t i = 0; i < 10000; i++) {
    later2::later(callback, (void *)i, 0);
  }
}
