#!/bin/bash

PYTHON2=python2
EMMAKE=emmake
EMCONFIGURE=emconfigure
EMCC=emcc
NODE=node

if [ ! -d "build" ]; then

    mkdir -p build
    cd build

    echo "Cloning from git"
    git clone https://git01.codeplex.com/z3 

    echo "Patching Z3 to build and work with emscripten"
    cd z3
    autoconf
    for p in ../../patches/*.patch; do patch -p0 < $p; done

else

    cd build/z3
    autoconf
    
fi

echo "Building"
$EMCONFIGURE ./configure --with-python=$PYTHON2 CXX=em++
$PYTHON2 scripts/mk_make.py
cd build
$EMMAKE make
ln -s z3 z3.bc
$EMCC -O3 z3.bc -o z3.js -s EXPORTED_FUNCTIONS='["_solve_string"]' -s TOTAL_MEMORY=67108864 -s PRECISE_I64_MATH=1 -s DISABLE_EXCEPTION_CATCHING=0
cd ../..
cp z3/build/z3.js .

echo "Testing"
$NODE ../test.js
