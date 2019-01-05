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

export PROOF_ANDROID_NDK_VERSION=18b
export PROOF_ANDROID_PLATFORM=28
export PROOF_OPENSSL_VERSION=1.1.1a
export PROOF_QT_VERSION=5.12.0
export PROOF_QCA_VERSION=2.2.0
export PROOF_QRENCODE_VERSION=4.0.2

PREBUILT_DIR="/prebuilt"

rm -rf "$PREBUILT_DIR/*" || true;
mkdir -p "$PREBUILT_DIR";
cd "$PREBUILT_DIR";
wget https://dl.google.com/android/repository/android-ndk-r${PROOF_ANDROID_NDK_VERSION}-linux-x86_64.zip;
unzip -q android-ndk-r${PROOF_ANDROID_NDK_VERSION}-linux-x86_64.zip;
mv android-ndk-r${PROOF_ANDROID_NDK_VERSION} ndk;
rm android-ndk-r${PROOF_ANDROID_NDK_VERSION}-linux-x86_64.zip;

rm -rf ndk/python-packages;
rm -rf ndk/shader-tools;
rm -rf ndk/simpleperf;
mv ndk/platforms/android-$PROOF_ANDROID_PLATFORM ndk/platforms/_android-$PROOF_ANDROID_PLATFORM;
rm -rf ndk/platforms/android-*;
mv ndk/platforms/_android-$PROOF_ANDROID_PLATFORM ndk/platforms/android-$PROOF_ANDROID_PLATFORM;
rm -rf ndk/platforms/android-$PROOF_ANDROID_PLATFORM/arch-arm64;
rm -rf ndk/platforms/android-$PROOF_ANDROID_PLATFORM/arch-x86;
rm -rf ndk/platforms/android-$PROOF_ANDROID_PLATFORM/arch-x86_64;
rm -rf ndk/toolchains/aarch64-linux-android-4.9;
rm -rf ndk/toolchains/renderscript;
rm -rf ndk/toolchains/x86_64-4.9;
rm -rf ndk/prebuilt/android-arm64;
rm -rf ndk/prebuilt/android-x86;
rm -rf ndk/prebuilt/android-x86_64;
rm -rf ndk/prebuilt/linux-x86_64;
rm -rf ndk/sources/third_party;

cd "$PREBUILT_DIR";
cp /extras/iconv.tar.gz ./;
tar -xzf iconv.tar.gz;
rm -rf iconv.tar.gz;
tar -czf ndk.tar.gz ndk;

export ANDROID_NDK_ROOT="$PREBUILT_DIR"/ndk;
/build_helpers/build_openssl.sh;
/build_helpers/build_qt.sh;
/build_helpers/build_qca.sh;
/build_helpers/build_qrencode.sh;

rm -rf "$PREBUILT_DIR"/ndk;
mkdir -p "$PREBUILT_DIR"/packaged;
cd "$PREBUILT_DIR"/packaged;
mv "$PREBUILT_DIR"/Qt.tar.gz "$PREBUILT_DIR"/QCA.tar.gz "$PREBUILT_DIR"/qrencode.tar.gz "$PREBUILT_DIR"/OpenSSL.tar.gz ./;
tar -xzf Qt.tar.gz;
tar -xzf QCA.tar.gz;
tar -xzf qrencode.tar.gz;
tar -xzf OpenSSL.tar.gz;
cp -R OpenSSL/* Qt/;
cp /extras/qca-qt5-android-dependencies.xml Qt/lib/;
rm -rf OpenSSL;
rm *.tar.gz;
tar -czf Qt.tar.gz Qt;
mv Qt.tar.gz "$PREBUILT_DIR"/Qt.tar.gz;
cd "$PREBUILT_DIR";
rm -rf "$PREBUILT_DIR"/packaged;
rm -rf "$PREBUILT_DIR"/build;
