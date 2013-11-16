#!/bin/bash

DOWNLOAD_DIR=http://llvm.org/releases/3.3/
LLVM_FILENAME=llvm-3.3.src
CLANG_FILENAME=cfe-3.3.src
LLVM_TAR_FILE=${LLVM_FILENAME}.tar.gz
CLANG_TAR_FILE=${CLANG_FILENAME}.tar.gz

EMCONFIGURE=emconfigure
EMMAKE=emmake
EMCC=emcc
NODE=node

CONFIGURE_OPTIONS="--enable-optimized --disable-assertions --disable-jit --disable-threads --disable-pthreads --enable-targets=sparc"
CORES=4

echo "Setting up directories"
mkdir -p build
cd build
if [ ! -e "$LLVM_TAR_FILE" ]; then
    wget ${DOWNLOAD_DIR}${LLVM_TAR_FILE}
fi
if [ ! -e "$CLANG_TAR_FILE" ]; then
    wget ${DOWNLOAD_DIR}${CLANG_TAR_FILENAME}
fi
tar xaf $LLVM_TAR_FILE
tar xaf $CLANG_TAR_FILE
mv $CLANG_FILENAME ${LLVM_FILENAME}/tools/clang
cd $LLVM_FILENAME

echo "Building native"
mkdir -p native
cd native
../configure $CONFIGURE_OPTIONS
make -j $CORES
if [ ! -e "Release/bin/clang" ]; then
    echo "The clang executable does not exist."
    exit 1
fi
cd ..

echo "Patching"
for p in ../../patches/*.patch; do patch -p0 < $p; done
sed -i 's/TOOLNAME = llvm-tblgen/TOOLNAME =/' utils/TableGen/Makefile
sed -i 's/TOOLNAME := llvm-config/TOOLNAME :=/' tools/llvm-config/Makefile
sed -i 's/TOOLNAME = clang-tblgen/TOOLNAME =/' tools/clang/utils/TableGen/Makefile
mkdir -p js/Release/bin
cp native/Release/bin/llvm-tblgen js/Release/bin/
chmod +x js/Release/bin/llvm-tblgen
cp native/Release/bin/llvm-config js/Release/bin/
chmod +x js/Release/bin/llvm-config
cp native/Release/bin/clang-tblgen js/Release/bin/
chmod +x js/Release/bin/clang-tblgen

echo "Building JavaScript"
mkdir -p js
cd js
$EMCONFIGURE ../configure $CONFIGURE_OPTIONS
$EMMAKE make
if [ ! -e "Release/bin/clang" ]; then
    echo "The clang bytecode file does not exist."
    exit 1
fi
cd Release/bin
ln -s clang clang.bc
echo "Compiling the final JavaScript file."
echo "Unfortunately, the generated code will crash when run."
$EMCC -O2 clang.bc -o clang.js -s ASM_JS=2
