#!/bin/bash

DOWNLOAD_DIR=http://cvs.haskell.org/Hugs/downloads/2006-09/
HUGS_FILENAME=hugs98-Sep2006
HUGS_TAR_FILE=${HUGS_FILENAME}.tar.gz

EMCONFIGURE=emconfigure
EMMAKE=emmake
EMCC=emcc
NODE=node

echo "Setting up directories"
mkdir -p build
cd build
if [ ! -e "$HUGS_TAR_FILE" ]; then
    wget ${DOWNLOAD_DIR}${HUGS_TAR_FILE}
fi
tar xaf $HUGS_TAR_FILE
cp -r $HUGS_FILENAME ${HUGS_FILENAME}-native
mv $HUGS_FILENAME ${HUGS_FILENAME}-js

echo "Building native"
cd ${HUGS_FILENAME}-native
./configure
make
cd ..

# The build process creates files that it later executes.
# We need to copy over ones from a separate native build and ensure they are not overwritten.
echo "Patching"
cd ${HUGS_FILENAME}-js
sed -i 's/all\t\t:: hugs$(EXEEXT) runhugs$(EXEEXT) ffihugs$(EXEEXT)/all\t\t:: hugs$(EXEEXT)/' src/Makefile.in
cp ../${HUGS_FILENAME}-native/src/runhugs src/
chmod +x src/runhugs
cp ../${HUGS_FILENAME}-native/src/ffihugs src/
chmod +x src/ffihugs

echo "Building JavaScript"
mkdir -p hugs-dir
$EMCONFIGURE ./configure --prefix=`pwd`/hugs-dir
$EMMAKE make
$EMMAKE make install
cp src/hugs hugs.bc
# TODO: This leaves the absolute directory in the JS file, which is annoying.
$EMCC -O2 hugs.bc -o hugs.html -s TOTAL_MEMORY=67108864 --preload-file hugs-dir/lib/hugs/packages/@`pwd`/hugs-dir/lib/hugs/packages/
echo "Replacing references to readline in the generated file."
sed -i 's/Module\['\''printErr'\'']('\''missing function: readline'\''); abort(-1);/  var input = window.prompt('\''Input:'\'');\n    if (input === null)\n      input = '\'':quit'\'';\n    input += '\''\\n'\'';\n    return allocate(intArrayFromString(input), '\''i8'\'', ALLOC_NORMAL);/' hugs.js
sed -i 's/Module\['\''printErr'\'']('\''missing function: add_history'\''); abort(-1);//' hugs.js
