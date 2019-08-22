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

OPENCV_VERSION=4.1.0
QT_VERSION=5.13
QT_VERSION_PATCH=0
QCA_VERSION=2.2.1

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/proof-base"
PREBUILT_DIR="$ROOT/prebuilt"

rm -rf "$PREBUILT_DIR";
mkdir -p "$PREBUILT_DIR";

docker rm opencv_builder --force || true;
docker rm qt_builder --force || true;
docker rm qca_builder --force || true;

docker run -id --name opencv_builder -v "$PREBUILT_DIR":/__deb debian:stretch-backports tail -f /dev/null;
docker cp "$ROOT/build_helpers/build_opencv.sh" opencv_builder:/build_opencv.sh;
docker exec opencv_builder mkdir -p /patch;
for patch in "$ROOT"/build_helpers/patch/opencv/*.patch; do
    docker cp $patch opencv_builder:/patch/`basename $patch`;
done || true;
docker exec -t opencv_builder /build_opencv.sh "$OPENCV_VERSION";
docker rm opencv_builder --force;

docker run -id --name qt_builder -v "$PREBUILT_DIR":/__deb debian:stretch-backports tail -f /dev/null;
docker cp "$ROOT/build_helpers/extract_deb_dependencies.sh" qt_builder:/extract_deb_dependencies.sh;
docker cp "$ROOT/build_helpers/build_qt.sh" qt_builder:/build_qt.sh;
docker exec qt_builder mkdir -p /patch;
for patch in "$ROOT"/build_helpers/patch/qt/*.patch; do
    docker cp $patch qt_builder:/patch/`basename $patch`;
done || true;
docker exec -t qt_builder /build_qt.sh "$QT_VERSION" "$QT_VERSION_PATCH";
docker rm qt_builder --force;

docker run -id --name qca_builder -v "$PREBUILT_DIR":/__deb debian:stretch-backports tail -f /dev/null;
docker cp "$ROOT/build_helpers/extract_deb_dependencies.sh" qca_builder:/extract_deb_dependencies.sh;
docker cp "$ROOT/build_helpers/build_qca.sh" qca_builder:/build_qca.sh;
docker exec qca_builder mkdir -p /patch;
for patch in "$ROOT"/build_helpers/patch/qca/*.patch; do
    docker cp $patch qca_builder:/patch/`basename $patch`;
done || true;
docker exec -t qca_builder /build_qca.sh "$QCA_VERSION";
docker rm qca_builder --force;

docker build --squash --force-rm --no-cache -t opensoftdev/proof-base -f "$ROOT/Dockerfile" "$ROOT/";
docker build --squash --force-rm --no-cache -t opensoftdev/proof-app-deploy-base -f "$ROOT/Dockerfile.app-deploy" "$ROOT/";

for prebuilt in "$PREBUILT_DIR"/*.deb; do
    aws s3 cp "$prebuilt" "s3://proof.travis.builds/__dependencies/`basename $prebuilt`";
done
docker push opensoftdev/proof-base;
docker push opensoftdev/proof-app-deploy-base;
