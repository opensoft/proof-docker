#!/bin/bash

# Copyright 2018, OpenSoft Inc.
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted
# provided that the following conditions are met:

#     * Redistributions of source code must retain the above copyright notice, this list of
# conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright notice, this list of
# conditions and the following disclaimer in the documentation and/or other materials provided
# with the distribution.
#     * Neither the name of OpenSoft Inc. nor the names of its contributors may be used to endorse
# or promote products derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Author: denis.kormalev@opensoftdev.com (Denis Kormalev)

set -e

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BUILD_ROOT="$ROOT/../prebuilt/build/openssl"
PACKAGE_ROOT="$BUILD_ROOT/package"
DEPLOY_PREFIX="/opt/Opensoft/Qt"
DEPLOY_EXTPREFIX="${PACKAGE_ROOT}/OpenSSL"
SOURCES_DIR="$BUILD_ROOT/src"
BUILDING_THREADS_COUNT=$(( $(cat /proc/cpuinfo | grep processor | wc -l) + 1 ))

echo "Starting OpenSSL build."
echo "Version: $PROOF_OPENSSL_VERSION"

mkdir -p $SOURCES_DIR
cd $SOURCES_DIR
wget -q https://www.openssl.org/source/openssl-$PROOF_OPENSSL_VERSION.tar.gz
tar -xzf openssl-$PROOF_OPENSSL_VERSION.tar.gz
cd openssl-$PROOF_OPENSSL_VERSION

echo;
for patch in `(ls $ROOT/patch/openssl/*.patch 2>/dev/null || true) | sort -V`; do
    echo "Applying `basename $patch`...";
    git apply $patch;
    echo "Applied.";
done;

export ANDROID_TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64"
export PATH="$ANDROID_TOOLCHAIN/bin":"$PATH"
export ANDROID_NDK=$ANDROID_NDK_ROOT
export MACHINE=armv7
export RELEASE=2.6.37
export SYSTEM=android
export ARCH=arm
export CROSS_COMPILE="arm-linux-androideabi-"
export CC=clang

./Configure android-arm -march=armv7-a \
           -D__ANDROID_API__=$PROOF_ANDROID_PLATFORM \
           -D_FILE_OFFSET_BITS=32 \
           --sysroot="$ANDROID_NDK_ROOT/platforms/android-$PROOF_ANDROID_PLATFORM/arch-arm" \
           --prefix="$DEPLOY_EXTPREFIX" \
           --openssldir="$DEPLOY_EXTPREFIX" \
           -fPIC -mfloat-abi=softfp shared no-comp no-hw no-engine

make -j $BUILDING_THREADS_COUNT SHLIB_VERSION_NUMBER= SHLIB_EXT=.so
ln -s libcrypto.so libcrypto.so.1.1
ln -s libssl.so libssl.so.1.1
make install
rm "$DEPLOY_EXTPREFIX"/lib/libssl.so* "$DEPLOY_EXTPREFIX"/lib/libcrypto.so*
cp libcrypto.so libssl.so "$DEPLOY_EXTPREFIX"/lib/

cd $PACKAGE_ROOT
rm -rf OpenSSL/bin || true;
rm -rf OpenSSL/certs || true;
rm -rf OpenSSL/misc || true;
rm -rf OpenSSL/private || true;
rm -rf OpenSSL/share || true;
rm -rf OpenSSL/lib/engines* || true;
rm -rf OpenSSL/*.cnf || true;
rm -rf OpenSSL/*.dist || true;
tar -czf OpenSSL.tar.gz OpenSSL
mv OpenSSL.tar.gz $ROOT/../prebuilt
rm -rf $BUILD_ROOT
