#!/bin/bash
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
