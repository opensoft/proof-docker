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

set -e

PACKAGE_NAME="qt5-opensoft"
PACKAGE_VERSION=$1.$2
PACKAGE_MAINTAINER="Denis Kormalev <denis.kormalev@opensoftdev.com>"
PACKAGE_DESCRIPTION="Qt5 (Opensoft build)
 Contains Qt5 $PACKAGE_VERSION"

QT_MODULES_WHITELIST="qtandroidextras qtbase qtconnectivity qtdeclarative qtgraphicaleffects qtimageformats qtlocation qtmultimedia qtnetworkauth qtquickcontrols qtquickcontrols2 qtremoteobjects qtscxml qtsensors qtserialbus qtserialport qtsvg qttools qttranslations qtwebchannel qtwebengine qtwebsockets qtwebview qtx11extras";

QT_SRC_FILENAME="qt-everywhere-src-$1.$2.tar.xz"
QT_DOWNLOAD_URL="http://download.qt.io/official_releases/qt/$1/$1.$2/single/$QT_SRC_FILENAME"

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

apt-get -qq update;
apt-get -qq install wget ca-certificates git make cmake pkg-config zlib1g-dev libgl1-mesa-dev libegl1-mesa-dev libx11-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev  fakeroot python3 python ruby gperf bison flex libicu-dev libxslt-dev libproxy-dev libproxy1-plugin-webkit libfontconfig1-dev libfreetype6-dev libssl-dev libxkbcommon-x11-dev libxcb1-dev libx11-xcb-dev libxcb-glx0-dev libpq-dev libdbus-1-dev libharfbuzz-dev libjpeg62-turbo-dev libpng-dev libinput-dev libmtdev-dev libxcomposite-dev libxcursor-dev libxrandr-dev libxdamage-dev libcap-dev libpulse-dev libudev-dev libpci-dev libasound2-dev libxss-dev libbz2-dev libgcrypt11-dev libdrm-dev libcups2-dev libatkmm-1.6-dev libxtst-dev libnss3-dev libatspi2.0-dev libgstreamermm-1.0-dev -y --no-install-recommends;
apt-get -qq install libzstd-dev -t stretch-backports -y --no-install-recommends;

cp /etc/apt/sources.list /old_sources.list;
echo "deb http://deb.debian.org/debian testing main" >> /etc/apt/sources.list;
apt-get -qq update;
apt-get -qq install gcc-8 cpp-8 libcc1-0 libgcc-8-dev g++-8 libstdc++6 clang-7 -t testing -y --no-install-recommends;
cp /old_sources.list /etc/apt/sources.list;
apt-get -qq update;

ln -s /usr/bin/clang-7 /usr/bin/clang;
ln -s /usr/bin/clang++-7 /usr/bin/clang++;
export CC=/usr/bin/clang;
export CXX=/usr/bin/clang++;

BUILD_ROOT="/build"
PACKAGE_ROOT="$BUILD_ROOT/package"
DEPLOY_PREFIX="/opt/Opensoft/Qt"
DEPLOY_EXTPREFIX="${PACKAGE_ROOT}${DEPLOY_PREFIX}"
SOURCES_DIR="$BUILD_ROOT/src"
BUILDING_THREADS_COUNT=$(( $(cat /proc/cpuinfo | grep processor | wc -l) + 1 ))
PACKAGE_FILEPATH="/__deb/${PACKAGE_NAME}-${PACKAGE_VERSION}.deb"

echo "Starting Qt package build."
echo "Final package will be at $PACKAGE_FILEPATH"
echo "Qt sources URL: $QT_DOWNLOAD_URL"

mkdir -p $SOURCES_DIR
cd $SOURCES_DIR
wget $QT_DOWNLOAD_URL
tar -xJf $QT_SRC_FILENAME;
rm $QT_SRC_FILENAME;
mv qt-everywhere-src-* qt5;
cd qt5;

mkdir ../protected;
mv $QT_MODULES_WHITELIST ../protected/;
find -maxdepth 1 -type d -name "qt*" | xargs rm -rf;
mv ../protected/* ./;
rm -rf ../protected;

echo;
for patch in `(ls /patch/*.patch 2>/dev/null || true) | sort -V`; do
    echo "Applying `basename $patch`...";
    git apply $patch;
    echo "Applied.";
done;

./configure -platform linux-clang -prefix $DEPLOY_PREFIX -extprefix $DEPLOY_EXTPREFIX -release -shared \
-plugin-sql-psql -plugin-sql-sqlite -qt-xcb -libproxy \
-openssl-linked -c++std c++1z -dbus-linked -fontconfig -nomake examples -nomake tests -no-gtk -no-qml-debug \
-opensource -confirm-license -silent -no-use-gold-linker

make -j $BUILDING_THREADS_COUNT
make install

mkdir -p $DEPLOY_EXTPREFIX/include;
mkdir -p $DEPLOY_EXTPREFIX/src;
cp -R qtandroidextras/include/QtAndroidExtras $DEPLOY_EXTPREFIX/include/QtAndroidExtras;
cp -R qtandroidextras/src/androidextras $DEPLOY_EXTPREFIX/src/androidextras;

export IGNORE_PACKAGES_PATTERN="libqt:qt5"
DEPENDS="`/$ROOT/extract_deb_dependencies.sh -v $DEPLOY_EXTPREFIX | paste -s -d,`"

# Building package
mkdir -p "$PACKAGE_ROOT/DEBIAN"
cat << EOT > "$PACKAGE_ROOT/DEBIAN/control"
Package: $PACKAGE_NAME
Version: $PACKAGE_VERSION
Section: misc
Depends: $DEPENDS
Architecture: amd64
Maintainer: $PACKAGE_MAINTAINER
Description: $PACKAGE_DESCRIPTION

EOT

cat << EOT > "$PACKAGE_ROOT/opt/Opensoft/Qt/bin/qt.conf"
[Paths]
Prefix=/opt/Opensoft/Qt
EOT

fakeroot dpkg-deb --build "$PACKAGE_ROOT" "$PACKAGE_FILEPATH"
