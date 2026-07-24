#!/usr/bin/env bash
set -euo pipefail

std=${1:-CXX17}
std=$(echo "$std" | tr '[:lower:]' '[:upper:]')
compiler=${2:-gcc}

echo "==============================="
echo "Preparing C++ code with $std standard and $compiler compiler"
echo ""

# Regenerate later2test/src/Makevars from Makevars.in, pinned to $std, via
# the package's own configure script (the same one R CMD INSTALL runs from a
# tarball) so this local check exercises the same code path as check.sh.
(cd ./later2test && LATER2TEST_CXX_STD="$std" ./configure)
