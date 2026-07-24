#!/usr/bin/env bash
set -euo pipefail

std=${1:-CXX17}
std=$(echo "$std" | tr '[:lower:]' '[:upper:]')
compiler=${2:-gcc}

echo "Restoring files for $std and $compiler"

# Restore CXX_STD to later2test's default (CXX23)
(cd ./later2test && ./configure)

# Clear check files
rm -rf ./later2test.Rcheck || true
