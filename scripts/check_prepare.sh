#!/usr/bin/env bash
set -euo pipefail

std=${1:-CXX17}
std=$(echo "$std" | tr '[:lower:]' '[:upper:]')
compiler=${2:-gcc}

echo "==============================="
echo "Preparing C++ code with $std standard and $compiler compiler"
echo ""

# Patch CXX_STD in latertest/src/Makevars
sed -i "s/^CXX_STD = .*/CXX_STD = ${std}/" ./latertest/src/Makevars
