#!/bin/bash

EMCONFIGURE=emconfigure
EMMAKE=emmake
EMCC=emcc
NODE=node

LINGELING_FILE=lingeling-ats-57807c8-131016

mkdir -p build
cd build

if [ -e $LINGELING_FILE ]; then

    cd $LINGELING_FILE

else

    if [ ! -e "$LINGELING_FILE.tar.gz" ]; then
	echo "Downloading sources"
	wget http://fmv.jku.at/lingeling/${LINGELING_FILE}.tar.gz
    fi

    tar xaf $LINGELING_FILE.tar.gz
    cd $LINGELING_FILE

    echo "Patching lingeling to build and work with emscripten"
    for p in ../../patches/*.patch; do patch -p0 < $p; done

fi

echo "Building"
$EMCONFIGURE ./configure.sh
$EMMAKE make lingeling
ln -s lingeling lingeling.bc
$EMCC -O3 -s EXPORTED_FUNCTIONS='["_solve_string"]' -s TOTAL_MEMORY=33554432 -s PRECISE_I64_MATH=1 lingeling.bc -o lingeling.js
cp lingeling.js{,.mem} ../
cd ..

echo "Testing"
$NODE ../test.js
