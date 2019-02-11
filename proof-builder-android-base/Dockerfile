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

FROM debian:testing

COPY image_cleaner.sh /image_cleaner.sh
# stripped tar.gz with Android NDK with iconv
COPY prebuilt/ndk.tar.gz /ndk.tar.gz

ADD prebuilt/Qt.tar.gz /opt/Opensoft

RUN CLANG_VERSION=7 BUILD_DEPS="clang-$CLANG_VERSION" \
    && chmod +x /image_cleaner.sh \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        wget ca-certificates openjdk-8-jdk xz-utils python3 git make cmake ninja-build $BUILD_DEPS \
    && mkdir /sandbox \
    && git config --global advice.detachedHead false \
    && apt-get -qq purge --auto-remove -y $BUILD_DEPS \
    && /image_cleaner.sh

ENV QTDIR=/opt/Opensoft/Qt \
    LD_LIBRARY_PATH=$QTDIR/lib:$LD_LIBRARY_PATH \
    PKG_CONFIG_PATH=$QTDIR/lib/pkgconfig:$PKG_CONFIG_PATH \
    PATH=$QTDIR/bin:/usr/lib/jvm/java-8-openjdk-amd64:$PATH \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    ANDROID_SDK_ROOT=/opt/android/sdk \
    ANDROID_NDK_ROOT=/opt/android/ndk

ENTRYPOINT exec /bin/bash
