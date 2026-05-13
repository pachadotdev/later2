# run_now doesn't go past a failed task

    Code
      run_now()
    Condition
      Error:
      ! boom

# Callbacks cannot affect the caller

    Code
      g()
    Condition
      Error:
      ! no function to return from, jumping to top level

