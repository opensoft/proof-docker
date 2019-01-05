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

# libclang-dev is needed on host

set -e

QT_REPOSITORY="git://code.qt.io/qt/qt5.git"
QT_TAG="v$PROOF_QT_VERSION"

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BUILD_ROOT="$ROOT/../prebuilt/build/qt"
PACKAGE_ROOT="$BUILD_ROOT/package"
DEPLOY_PREFIX="/opt/Opensoft/Qt"
DEPLOY_EXTPREFIX=`readlink -m "$PACKAGE_ROOT"`
SOURCES_DIR="$BUILD_ROOT/src"
BUILDING_THREADS_COUNT=$(( $(cat /proc/cpuinfo | grep processor | wc -l) + 1 ))

echo "Starting Qt build."
echo "Qt repo: $QT_REPOSITORY"
echo "Qt tag: $QT_TAG"

mkdir -p $BUILD_ROOT/deps
cd $BUILD_ROOT/deps
cp $ROOT/../prebuilt/OpenSSL.tar.gz ./
tar -xzf OpenSSL.tar.gz

mkdir -p $SOURCES_DIR
cd $SOURCES_DIR
git clone $QT_REPOSITORY qt5
cd qt5
git checkout $QT_TAG

# Before new version release Qt breaks repository and changes branches that were used in gitmodules. This replacement changes it to tags usage
sed -i -re 's/(branch\s=\s)([0-9]\.[0-9]\.[0-9])/\1v\2/' .gitmodules

# We need only essential and addon modules here, no deprecated or techpreview
# We don't need any non LGPL modules or mac/win extras
./init-repository --module-subset=essential,addon,-qtdoc,-qtpurchasing,-qtactiveqt,-qtcharts,-qtdatavis3d,-qtmacextras,-qtvirtualkeyboard,-qtwinextras,-qtwayland,-qtx11extras,-qt3d,-qtcanvas3d,-qtwebengine

echo;
for patch in `(ls $ROOT/patch/qt/*.patch 2>/dev/null || true) | sort -V`; do
    echo "Applying `basename $patch`...";
    git apply $patch;
    echo "Applied.";
done;

OPENSSL_LIBS="-L$BUILD_ROOT/deps/OpenSSL/lib -lssl -lcrypto" ./configure -xplatform android-clang --disable-rpath -no-warnings-are-errors \
    -prefix $DEPLOY_PREFIX -release -shared -I $BUILD_ROOT/deps/OpenSSL/include \
    -plugin-sql-sqlite -openssl-runtime -opengl es2 -no-icu \
    -nomake tests -nomake examples -skip qtserialport -skip qtx11extras -no-qml-debug \
    -opensource -confirm-license -silent \
    -android-arch armeabi-v7a -android-ndk-host linux-x86_64 -android-toolchain-version 4.9 -android-ndk-platform android-$PROOF_ANDROID_PLATFORM
make -j $BUILDING_THREADS_COUNT
make INSTALL_ROOT="$DEPLOY_EXTPREFIX" install
mv "$DEPLOY_EXTPREFIX/opt/Opensoft/Qt" "$DEPLOY_EXTPREFIX/Qt"
rm -rf "$DEPLOY_EXTPREFIX/opt"

NORMALIZED_NDK_PATH=`readlink -m "$ANDROID_NDK_ROOT"`
find "$DEPLOY_EXTPREFIX" -type f \( -name "*.la" -o -name "*.pc" -o -name "*.prl" -o -name "*.pri" \) | xargs sed -i -e "s@$NORMALIZED_NDK_PATH@/opt/android/ndk@g"

cd $PACKAGE_ROOT
rm -rf Qt/doc || true
rm -rf Qt/translations/assistant* || true
rm -rf Qt/translations/designer* || true
rm -rf Qt/translations/linguist* || true
rm -rf Qt/translations/qmlviewer* || true

tar -czf Qt.tar.gz Qt
mv Qt.tar.gz $ROOT/../prebuilt
rm -rf $BUILD_ROOT
