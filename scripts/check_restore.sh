#!/usr/bin/env bash
set -euo pipefail

# Accept std as first arg, default to CXX11
std=${1:-CXX11}
std=$(echo "$std" | tr '[:lower:]' '[:upper:]')
compiler=${2:-gcc}

echo "Restoring files for $std and $compiler"

# Convert std to C++ format for DESCRIPTION (e.g., CXX20 -> C++20)
if [ "$std" = "CXX11" ]; then cpp_std="C++11"
elif [ "$std" = "CXX14" ]; then cpp_std="C++14"
elif [ "$std" = "CXX17" ]; then cpp_std="C++17"
elif [ "$std" = "CXX20" ]; then cpp_std="C++20"
elif [ "$std" = "CXX23" ]; then cpp_std="C++23"
else cpp_std="$std"; fi

# Restore Makevars to defaults
sed -i 's/^CXX_STD = .*/CXX_STD = CXX23/' ./latertest/src/Makevars
# Remove any leftover clang block from a previous prepare run
sed -i '/# cpp11-check-clang-begin/,/# cpp11-check-clang-end/d' ./latertest/src/Makevars

# Clear check files
rm -rf ./latertest.Rcheck || true
