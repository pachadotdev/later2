class PromiseTask : public later2::BackgroundTask {
public:
  PromiseTask(cpp4r::sexp resolve, cpp4r::sexp reject)
      : resolve(resolve), reject(reject) {}

protected:
  virtual void execute() = 0;
  virtual cpp4r::sexp get_result() = 0;

  void complete() {
    cpp4r::sexp result = get_result();
    cpp4r::function{static_cast<SEXP>(resolve)}(static_cast<SEXP>(result));
  }

private:
  cpp4r::sexp resolve;
  cpp4r::sexp reject;
};

long fib(long x) {
  if (x <= 2) {
    return 1;
  }
  return fib(x - 1) + fib(x - 2);
}

class FibonacciTask : public PromiseTask {
public:
  FibonacciTask(cpp4r::sexp resolve, cpp4r::sexp reject, double x)
      : PromiseTask(resolve, reject), x(x) {}

  void execute() { result = fib((long)x); }

  cpp4r::sexp get_result() {
    cpp4r::writable::doubles res = {(double)result};
    return res;
  }

private:
  double x;
  long result;
};

/* roxygen
@title Testing Function
@rdname testing
@param resolve object to resolve (sexp)
@param reject object to reject (sexp)
@param x value for Fibonnacci task (double)
@export
*/
[[cpp4r::register]] void asyncFib(SEXP resolve, SEXP reject, double x) {
  FibonacciTask *fib = new FibonacciTask(resolve, reject, x);
  fib->begin();
}
