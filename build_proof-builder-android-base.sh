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

if [ -z "$ANDROID_SDK_ROOT" ]; then
    echo "ANDROID_SDK_ROOT environment variable is not set"
    exit 1
fi

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/proof-builder-android-base"
PREBUILT_DIR="$ROOT/prebuilt"

docker rm qt_android_builder --force || true;

sudo rm -rf "$PREBUILT_DIR";
mkdir -p "$PREBUILT_DIR";
docker run -id --name qt_android_builder \
    -e "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" -e "ANDROID_SDK_ROOT=/android-sdk" \
    -v "$PREBUILT_DIR":/prebuilt -v "$ROOT/extras":/extras -v "$ROOT/build_helpers":/build_helpers -v $ANDROID_SDK_ROOT:/android-sdk \
    debian:buster tail -f /dev/null;
docker exec -t qt_android_builder bash -c 'echo "deb http://deb.debian.org/debian stretch main" >> /etc/apt/sources.list';
docker exec -t qt_android_builder apt-get update;
docker exec -t qt_android_builder apt-get -qq install -y --no-install-recommends unzip clang-7 g++ libclang-dev wget ca-certificates openjdk-8-jdk xz-utils python python3 git cmake make;
docker exec -t qt_android_builder git config --global advice.detachedHead false;
docker exec -t qt_android_builder /build_helpers/build_all.sh;
docker rm qt_android_builder --force;

docker build --force-rm --no-cache -t opensoftdev/proof-builder-android-base -f "$ROOT/Dockerfile" "$ROOT/";

docker push opensoftdev/proof-builder-android-base;
