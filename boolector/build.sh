#!/bin/bash

EMMAKE=emmake
EMCC=emcc
NODE=node

BOOLECTOR_FILE=boolector-1.5.118-6b56be4-121013

if [ ! -d "build" ]; then

    mkdir -p build
    cd build

    echo "Downloading sources"
    wget http://fmv.jku.at/boolector/${BOOLECTOR_FILE}.tar.gz

else

    cd build
    
fi

echo "Building minisat"
git clone https://github.com/niklasso/minisat.git
patch -p0 < ../../minisat/patches/fix-build.patch
cd minisat
$EMMAKE make
cd ..

echo "Building boolector"
tar xaf $BOOLECTOR_FILE.tar.gz
cd $BOOLECTOR_FILE
for p in ../../patches/*.patch; do patch -p0 < $p; done
emconfigure ./configure --only-minisat
$EMMAKE make
ln -s boolector boolector.bc
$EMCC -O3 -s EXPORTED_FUNCTIONS='["_solve_string"]' -s TOTAL_MEMORY=268435456 *.bc -o boolector.js
cp boolector.js ../
cd ..

echo "Testing"
$NODE ../test.js
