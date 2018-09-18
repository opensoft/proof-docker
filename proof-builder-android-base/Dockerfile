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

COPY image_cleaner.sh /image_cleaner.sh
# stripped tar.xz with ndk-bundle from SDK with qrencode and libssl/libcrypto
COPY prebuilt/ndk-bundle.tar.xz /ndk-bundle.tar.xz
# qt5 from 5.10.1 offline installer with qca
ADD prebuilt/qt.tar.xz /opt/android
COPY qmake_wrapper.sh /qmake_wrapper.sh

RUN chmod +x /qmake_wrapper.sh && chmod +x /image_cleaner.sh \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends ca-certificates openjdk-8-jdk xz-utils python3 git make \
    && /image_cleaner.sh

ENV QTDIR=/opt/android/qt/5.10.1/android_armv7 \
    LD_LIBRARY_PATH=/opt/android/qt/5.10.1/android_armv7/lib:$LD_LIBRARY_PATH \
    PKG_CONFIG_PATH=/opt/android/qt/5.10.1/android_armv7/lib/pkgconfig:$PKG_CONFIG_PATH \
    PATH=/opt/android/qt/5.10.1/android_armv7/bin:/opt/android/sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:/usr/lib/jvm/java-8-openjdk-amd64:$PATH \
    CC=/opt/android/sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gcc \
    CXX=/opt/android/sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-g++ \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    ANDROID_SDK_ROOT=/opt/android/sdk \
    ANDROID_NDK_ROOT=/opt/android/sdk/ndk-bundle

ENTRYPOINT exec /bin/bash
