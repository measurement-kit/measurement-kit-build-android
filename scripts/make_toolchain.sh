#!/bin/sh -e

if [ $# -ne 3 ]; then
    echo "Usage: $0 NDK_DIR ARCH API" 1>&2
    echo "  NDK_DIR: path where NDK is installed" 1>&2
    echo "  ARCH: arm-linux-androideabi mipsel-linux-android x86" 1>&2
    echo "  API: 1 ... 21" 1>&2
    echo "Example usage (on MacOS using brew):" 1>&2
    echo "  $0 /usr/local/Cellar/android-ndk/r10e" 1>&2
    exit 1
fi

NDK_DIR=$1
ARCH=$2
API=$3
BASEDIR=./toolchain

MAKE_TOOLCHAIN=${NDK_DIR}/build/tools/make-standalone-toolchain.sh

INSTALL_DIR=$BASEDIR/${ARCH}-${API}
echo "Creating toolchain for API ${API} and ARCH ${ARCH}-4.9 in ${INSTALL_DIR}"

# Bash is recommended to make the toolchain
bash $MAKE_TOOLCHAIN \
  --platform=android-${API} \
  --toolchain=${ARCH}-4.9 \
  --install-dir=${INSTALL_DIR} \
  --llvm-version=3.5 \
  --stl=libc++ \
  --system=$(uname | tr -s 'A-Z' 'a-z')-x86_64

if [ $ARCH = x86 ]; then
    cp $NDK_DIR/sources/cxx-stl/llvm-libc++/libs/x86/libc++_static.a $INSTALL_DIR/sysroot/usr/lib/
elif [ $ARCH = arm-linux-androideabi ]; then
    cp $NDK_DIR/sources/cxx-stl/llvm-libc++/libs/armeabi/libc++_static.a $INSTALL_DIR/sysroot/usr/lib/
elif [ $ARCH = mipsel-linux-android ]; then
    cp $NDK_DIR/sources/cxx-stl/llvm-libc++/libs/mips/libc++_static.a $INSTALL_DIR/sysroot/usr/lib/
else
    echo "FATAL: unknown architecture: $ARCH" 1>&2
    exit 1
fi
