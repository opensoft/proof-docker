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

FROM debian:stretch-backports

COPY etc_apt_sources.list /etc/apt/sources.list
COPY etc_apt_preferences /etc/apt/preferences

COPY image_cleaner.sh /image_cleaner.sh
# stripped tar.xz with ndk-bundle from SDK with qrencode and libssl/libcrypto
COPY prebuilt/ndk-bundle.tar.xz /ndk-bundle.tar.xz
# qt5 from 5.12.0 offline installer with qca
ADD prebuilt/qt.tar.xz /opt/android

RUN CLANG_VERSION=6.0 \
    BUILD_DEPS="clang-$CLANG_VERSION" \
    && chmod +x /image_cleaner.sh \
    && rm /etc/apt/sources.list.d/backports.list \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends -t stretch-backports \
        wget ca-certificates openjdk-8-jdk xz-utils python3 git make $BUILD_DEPS \
    && apt-get -qq install -y --no-install-recommends -t testing ninja-build \
    && mkdir /sandbox \
    && git config --global advice.detachedHead false \
    && mkdir /extras && cd /extras \
    && wget https://github.com/Kitware/CMake/releases/download/v3.13.1/cmake-3.13.1.tar.gz && tar -xzf cmake-3.13.1.tar.gz && cd cmake-3.13.1 \
    && env CC=/usr/lib/llvm-$CLANG_VERSION/bin/clang CXX=/usr/lib/llvm-$CLANG_VERSION/bin/clang++ ./bootstrap -- -DCMAKE_BUILD_TYPE=Release && make -j4 && make install \
    && cd / && rm -rf extras \
    && apt-get -qq purge --auto-remove -y $BUILD_DEPS \
    && /image_cleaner.sh

ENV QTDIR=/opt/android/qt/5.12.0/android_armv7 \
    LD_LIBRARY_PATH=$QTDIR/lib:$LD_LIBRARY_PATH \
    PKG_CONFIG_PATH=$QTDIR/lib/pkgconfig:$PKG_CONFIG_PATH \
    PATH=$QTDIR/bin:/usr/lib/jvm/java-8-openjdk-amd64:$PATH \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    ANDROID_SDK_ROOT=/opt/android/sdk \
    ANDROID_NDK_ROOT=/opt/android/sdk/ndk-bundle

ENTRYPOINT exec /bin/bash
