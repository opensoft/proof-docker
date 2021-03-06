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

set -e;

QRENCODE_REPOSITORY="https://github.com/fukuchi/libqrencode.git"
QRENCODE_TAG="v$PROOF_QRENCODE_VERSION"

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BUILD_ROOT="$ROOT/../prebuilt/build/qrencode"
PACKAGE_ROOT="$BUILD_ROOT/package"
DEPLOY_PREFIX="/opt/Opensoft/Qt"
SOURCES_DIR="$BUILD_ROOT/src"
BUILDING_THREADS_COUNT=$(( $(cat /proc/cpuinfo | grep processor | wc -l) + 1 ))

echo "Starting qrencode build."
echo "qrencode repo: $QRENCODE_REPOSITORY"
echo "qrencode tag: $QRENCODE_TAG"

mkdir -p $BUILD_ROOT/deps
cd $BUILD_ROOT/deps
cp $ROOT/../prebuilt/Qt.tar.gz ./
tar -xzf Qt.tar.gz

mkdir -p $SOURCES_DIR
cd $SOURCES_DIR
git clone $QRENCODE_REPOSITORY qrencode
cd qrencode
git checkout $QRENCODE_TAG

echo;
for patch in `(ls $ROOT/patch/qrencode/*.patch 2>/dev/null || true) | sort -V`; do
    echo "Applying `basename $patch`...";
    git apply $patch;
    echo "Applied.";
done;

export PATH=$BUILD_ROOT/deps/Qt/bin:$PATH
cmake -DCMAKE_INSTALL_PREFIX=$DEPLOY_PREFIX -DCMAKE_BUILD_TYPE=Release \
    -DANDROID_PLATFORM=android-$PROOF_ANDROID_PLATFORM -DANDROID_STL=c++_shared -DCMAKE_FIND_ROOT_PATH=$BUILD_ROOT/deps/Qt \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake \
    -DWITH_TOOLS=OFF .
make -j $BUILDING_THREADS_COUNT
make DESTDIR=$PACKAGE_ROOT install
mv $PACKAGE_ROOT/$DEPLOY_PREFIX $PACKAGE_ROOT/Qt

cd $PACKAGE_ROOT
rm -rf Qt/share || true
tar -czf qrencode.tar.gz Qt
mv qrencode.tar.gz $ROOT/../prebuilt
rm -rf $BUILD_ROOT

