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
PACKAGE_VERSION=$1
PACKAGE_MAINTAINER="Denis Kormalev <denis.kormalev@opensoftdev.com>"
PACKAGE_DESCRIPTION="Qt5 (Opensoft build)
 Contains Qt5 $PACKAGE_VERSION"

QT_REPOSITORY="git://code.qt.io/qt/qt5.git"
QT_TAG="v$PACKAGE_VERSION"

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

apt-get -qq update;
apt-get -qq install ca-certificates git make cmake pkg-config zlib1g-dev libgl1-mesa-dev libegl1-mesa-dev libx11-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev  fakeroot clang-6.0 python3 python ruby gperf bison flex libicu-dev libxslt-dev libproxy-dev libproxy1-plugin-webkit libfontconfig1-dev libfreetype6-dev libssl-dev libxkbcommon-x11-dev libxcb1-dev libx11-xcb-dev libxcb-glx0-dev libpq-dev libdbus-1-dev libharfbuzz-dev libjpeg62-turbo-dev libpng-dev libinput-dev libmtdev-dev libxcomposite-dev libxcursor-dev libxrandr-dev libxdamage-dev libcap-dev libpulse-dev libudev-dev libpci-dev libasound2-dev libxss-dev libbz2-dev libgcrypt11-dev libdrm-dev libcups2-dev libatkmm-1.6-dev libxtst-dev libnss3-dev libatspi2.0-dev libgstreamermm-1.0-dev -y --no-install-recommends;

ln -s /usr/lib/llvm-6.0/bin/clang /usr/bin/clang;
ln -s /usr/lib/llvm-6.0/bin/clang++ /usr/bin/clang++;
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
echo "Qt repo: $QT_REPOSITORY"
echo "Qt tag: $QT_TAG"

mkdir -p $SOURCES_DIR
cd $SOURCES_DIR
git clone $QT_REPOSITORY qt5
cd qt5
git checkout $QT_TAG

# Before new version release Qt breaks repository and changes branches that were used in gitmodules. This replacement changes it to tags usage
sed -i -re 's/(branch\s=\s)([0-9]\.[0-9]\.[0-9])/\1v\2/' .gitmodules

# We need only essential and addon modules here, no deprecated or techpreview
# We don't need any non LGPL modules or mac/win extras
./init-repository --module-subset=essential,addon,-qtdoc,-qtpurchasing,-qtactiveqt,-qtcharts,-qtdatavis3d,-qtmacextras,-qtvirtualkeyboard,-qtwinextras,-qtwayland,-qtandroidextras,-qt3d,-qtcanvas3d

echo;
for patch in `(ls /patch/*.patch 2>/dev/null || true) | sort -V`; do
    echo "Applying `basename $patch`...";
    git apply $patch;
    echo "Applied.";
done;

./configure -platform linux-clang -prefix $DEPLOY_PREFIX -extprefix $DEPLOY_EXTPREFIX -release -shared \
-plugin-sql-psql -plugin-sql-sqlite -qt-xcb -libproxy \
-openssl-linked -c++std c++1y -dbus-linked -fontconfig -nomake examples -nomake tests -no-gtk -no-qml-debug \
-opensource -confirm-license -silent -no-use-gold-linker

make -j $BUILDING_THREADS_COUNT
make install

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
