void *max_seen = 0;

void callback(void *data) {
  if (data < max_seen) {
    cpp11::stop("Bad ordering detected");
  }
  max_seen = data;
}

[[cpp11::register]] void checkLaterOrdering() {
  max_seen = 0;
  for (size_t i = 0; i < 10000; i++) {
    later::later(callback, (void *)i, 0);
  }
}
