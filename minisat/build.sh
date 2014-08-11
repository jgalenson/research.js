#!/bin/bash

EMMAKE=emmake
EMCC=emcc
NODE=node

mkdir -p build
cd build

if [ ! -d "minisat" ]; then
    echo "Cloning from git"
    git clone https://github.com/niklasso/minisat.git

    echo "Patching minisat to build and work with emscripten"
    for p in ../patches/*.patch; do patch -p0 < $p; done
fi

echo "Building"
cd minisat
$EMMAKE make r
cd build/release/bin
ln -s minisat minisat.bc
$EMCC -O3 -s EXPORTED_FUNCTIONS='["_solve_string"]' -s TOTAL_MEMORY=67108864 minisat.bc -o minisat.js
cd ../../../..
cp minisat/build/release/bin/minisat.js{,.mem} .

echo "Testing"
$NODE ../test.js
