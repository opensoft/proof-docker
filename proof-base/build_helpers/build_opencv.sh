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

PACKAGE_NAME="opencv-opensoft"
PACKAGE_VERSION=$1
PACKAGE_MAINTAINER="Denis Kormalev <denis.kormalev@opensoftdev.com>"
PACKAGE_DESCRIPTION="OpenCV (Opensoft build)
 Contains openCV $PACKAGE_VERSION"

apt-get -qq update;
apt-get -qq install ca-certificates wget unzip make cmake pkg-config zlib1g-dev libgl1-mesa-dev fakeroot clang-6.0 libharfbuzz-dev liblapacke-dev libopenblas-dev libjpeg62-turbo-dev libtiff5-dev libopenexr-dev libpng-dev libopenjp2-7-dev ffmpeg libswscale-dev libgphoto2-dev -y --no-install-recommends;

ln -s /usr/lib/llvm-6.0/bin/clang /usr/bin/clang;
ln -s /usr/lib/llvm-6.0/bin/clang++ /usr/bin/clang++;
export CC=/usr/bin/clang;
export CXX=/usr/bin/clang++;

INSTALL_DIR=/usr/local
#PACKAGE_DEPENDS="libfreetype6,libharfbuzz0b,liblapacke,libopenblas-base,libjpeg62-turbo,libtiff5,libopenexr22,libpng16-16,libopenjp2-7,libnss3,ffmpeg,libswscale4,libgphoto2-6,libtesseract3,tesseract-ocr-eng"
PACKAGE_DEPENDS="libharfbuzz0b,liblapacke,libopenblas-base,libjpeg62-turbo,libtiff5,libopenexr22,libpng16-16,libopenjp2-7,ffmpeg,libswscale4,libgphoto2-6"
PACKAGE_FILEPATH=/__deb/${PACKAGE_NAME}-${PACKAGE_VERSION}.deb

wget -q -O opencv-${PACKAGE_VERSION}.zip https://github.com/opencv/opencv/archive/${PACKAGE_VERSION}.zip
unzip -q opencv-${PACKAGE_VERSION}.zip

#wget -q -O opencv_contrib-${PACKAGE_VERSION}.zip https://github.com/opencv/opencv_contrib/archive/${PACKAGE_VERSION}.zip
#unzip -q opencv_contrib-${PACKAGE_VERSION}.zip

cd opencv-${PACKAGE_VERSION}
mkdir build
mkdir deb-package
PACKAGE_ROOT=`pwd`/deb-package
mkdir -p ${PACKAGE_ROOT}${INSTALL_DIR}

cd build
#TESSDATA_PREFIX=/usr/share/tesseract-ocr/
#/usr/bin/cmake -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${PACKAGE_VERSION}/modules \
/usr/bin/cmake -DCMAKE_BUILD_TYPE=RELEASE \
               -DCMAKE_INSTALL_PREFIX=${PACKAGE_ROOT}${INSTALL_DIR} \
               -DENABLE_CXX11=ON \
               -DBUILD_TESTS=OFF \
               -DBUILD_PERF_TESTS=OFF \
               -DBUILD_EXAMPLES=OFF \
               -DBUILD_opencv_apps=ON \
               -DBUILD_SHARED_LIBS=ON \
               -DBUILD_opencv_java=OFF \
               -DBUILD_opencv_python=OFF \
              ..

BUILDING_THREADS_COUNT=$(( $(cat /proc/cpuinfo | grep processor | wc -l) + 1 ))
make -j $BUILDING_THREADS_COUNT

# Building package
mkdir -p "$PACKAGE_ROOT/DEBIAN"
cat << EOT > "$PACKAGE_ROOT/DEBIAN/control"
Package: $PACKAGE_NAME
Version: $PACKAGE_VERSION
Section: misc
Depends: $PACKAGE_DEPENDS
Architecture: amd64
Maintainer: $PACKAGE_MAINTAINER
Description: $PACKAGE_DESCRIPTION
EOT

make install

sed -i -e "s|${PACKAGE_ROOT}||g" ${PACKAGE_ROOT}${INSTALL_DIR}/lib/pkgconfig/opencv.pc

fakeroot dpkg-deb --build "$PACKAGE_ROOT" "$PACKAGE_FILEPATH"
