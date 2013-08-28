#!/bin/bash

EMMAKE=emmake
EMCC=emcc
NODE=node

if [ ! -d "build" ]; then

    mkdir -p build
    cd build

    echo "Cloning from git"
    git clone https://github.com/niklasso/minisat.git

    echo "Patching minisat to build and work with emscripten"
    for p in ../patches/*.patch; do patch -p0 < $p; done

else

    cd build
    
fi

echo "Building"
cd minisat
$EMMAKE make r
cd build/release/bin
ln -s minisat minisat.bc
$EMCC -O3 -s EXPORTED_FUNCTIONS='["_solve_string"]' -s TOTAL_MEMORY=33554432 *.bc -o minisat.js
cd ../../../..
cp minisat/build/release/bin/minisat.js .

echo "Testing"
$NODE ../test.js
