class PromiseTask : public later::BackgroundTask {
public:
  PromiseTask(cpp11::sexp resolve, cpp11::sexp reject)
      : resolve(resolve), reject(reject) {}

protected:
  virtual void execute() = 0;
  virtual cpp11::sexp get_result() = 0;

  void complete() {
    cpp11::sexp result = get_result();
    cpp11::function{static_cast<SEXP>(resolve)}(static_cast<SEXP>(result));
  }

private:
  cpp11::sexp resolve;
  cpp11::sexp reject;
};

long fib(long x) {
  if (x <= 2) {
    return 1;
  }
  return fib(x - 1) + fib(x - 2);
}

class FibonacciTask : public PromiseTask {
public:
  FibonacciTask(cpp11::sexp resolve, cpp11::sexp reject, double x)
      : PromiseTask(resolve, reject), x(x) {}

  void execute() { result = fib((long)x); }

  cpp11::sexp get_result() {
    cpp11::writable::doubles res = {(double)result};
    return res;
  }

private:
  double x;
  long result;
};

[[cpp11::register]] void asyncFib(SEXP resolve, SEXP reject, double x) {
  FibonacciTask *fib = new FibonacciTask(resolve, reject, x);
  fib->begin();
}

/* R
library(promises)
library(later)
library(latertest)

promise(function(resolve, reject) {
  asyncFib(resolve, reject, 45)
}) |>
  then(print)
*/
