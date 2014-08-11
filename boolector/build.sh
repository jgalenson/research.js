#!/bin/bash

EMCONFIGURE=emconfigure
EMMAKE=emmake
EMCC=emcc
NODE=node

BOOLECTOR_FILE=boolector-1.5.118-6b56be4-121013
LINGELING_FILE=lingeling-ats-57807c8-131016

if [ $# == 0 ]; then
    echo "Please give one argument, either \"minisat\" or \"lingeling\""
    exit 1
fi

if [ ! -d "build" ]; then

    mkdir -p build
    cd build

    if [ ! -e "$BOOLECTOR_FILE.tar.gz" ]; then
	echo "Downloading sources"
	wget http://fmv.jku.at/boolector/${BOOLECTOR_FILE}.tar.gz
    fi

else

    cd build
    
fi

CONFIGURE_FLAG=""
EMCC_FLAG=""
if [ "$1" = "minisat" ]; then
    echo "Building minisat"
    git clone https://github.com/niklasso/minisat.git
    patch -p0 < ../../minisat/patches/fix-build.patch
    patch -p0 < ../../minisat/patches/remove-zlib.patch
    cd minisat
    $EMMAKE make lr
    cd ..
    CONFIGURE_FLAG="--only-minisat"
elif [ "$1" = "lingeling" ]; then
    echo "Building Lingeling"
    if [ ! -e "$LINGELING_FILE.tar.gz" ]; then
	wget http://fmv.jku.at/lingeling/${LINGELING_FILE}.tar.gz
    fi
    tar xaf $LINGELING_FILE.tar.gz
    ln -s $LINGELING_FILE lingeling
    cd $LINGELING_FILE
    for p in ../../../lingeling/patches/*.patch; do patch -p0 < $p; done
    $EMCONFIGURE ./configure.sh
    $EMMAKE make liblgl.a
    cd ..
    CONFIGURE_FLAG="--only-lingeling"
    EMCC_FLAG="-s PRECISE_I64_MATH=1"
else
    echo "Please give one argument, either \"minisat\" or \"lingeling\""
    exit 1
fi

echo "Building boolector"
tar xaf $BOOLECTOR_FILE.tar.gz
cd $BOOLECTOR_FILE
for p in ../../patches/*.patch; do patch -p0 < $p; done
emconfigure ./configure $CONFIGURE_FLAG
$EMMAKE make boolector
ln -s boolector boolector.bc
$EMCC -O3 -s EXPORTED_FUNCTIONS='["_solve_string"]' -s TOTAL_MEMORY=268435456 $EMCC_FLAG *.bc -o boolector.js
cp boolector.js{,.mem} ../
cd ..

echo "Testing"
$NODE ../test.js
