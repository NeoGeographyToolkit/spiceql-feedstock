#!/bin/sh
set -e

# ASP: the bindings install runs `pip install .` with the bare PATH pip, which
# in conda-build targets the BUILD-env python, so pyspiceql lands in the wrong
# prefix and the package ends up with no pyspiceql ("No module named
# 'pyspiceql'"). Patch it to the HOST python (Python3_EXECUTABLE = $PYTHON) with
# --no-build-isolation (use host setuptools) so it installs into $PREFIX.
sed -i.bak 's|COMMAND pip install \.|COMMAND ${Python3_EXECUTABLE} -m pip install . --no-deps --no-build-isolation|' \
  "$SRC_DIR/bindings/python/CMakeLists.txt"

mkdir build && cd build

# to avoid complaints in conda-forge, see https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
export CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"
cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=RELEASE -DSPICEQL_BUILD_TESTS=OFF  -DPython3_EXECUTABLE=$PYTHON  ..
cmake --build . --config RELEASE
cmake --install . --config RELEASE
