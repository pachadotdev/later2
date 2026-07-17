#!/usr/bin/env bash
set -euo pipefail

std=${1:-CXX17}
std=$(echo "$std" | tr '[:lower:]' '[:upper:]')
compiler=${2:-gcc}

echo "Restoring files for $std and $compiler"

# Restore CXX_STD to default
sed -i 's/^CXX_STD = .*/CXX_STD = CXX23/' ./later2test/src/Makevars

# Clear check files
rm -rf ./later2test.Rcheck || true
