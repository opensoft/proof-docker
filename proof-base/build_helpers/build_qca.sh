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

PACKAGE_NAME="qca-opensoft"
PACKAGE_VERSION=$1
PACKAGE_MAINTAINER="Denis Kormalev <denis.kormalev@opensoftdev.com>"
PACKAGE_DESCRIPTION="QCA for Qt5 (Opensoft build)
 Contains QCA $PACKAGE_VERSION"

QCA_REPOSITORY="git://anongit.kde.org/qca.git"
QCA_TAG="v$PACKAGE_VERSION"

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

apt-get -qq update;
apt-get -qq install ca-certificates git make cmake pkg-config zlib1g-dev fakeroot libssl-dev -y --no-install-recommends;
apt-get -qq install libzstd-dev -t stretch-backports -y --no-install-recommends;

cp /etc/apt/sources.list /old_sources.list;
echo "deb http://deb.debian.org/debian testing main" >> /etc/apt/sources.list;
apt-get -qq update;
apt-get -qq install gcc-8 cpp-8 libcc1-0 libgcc-8-dev g++-8 libstdc++6 clang-7 -t testing -y --no-install-recommends;
cp /old_sources.list /etc/apt/sources.list;
apt-get -qq update;

dpkg -i /__deb/qt5-opensoft*.deb 2> /dev/null || apt-get -qq -f install -y --no-install-recommends;

ln -s /usr/bin/clang-7 /usr/bin/clang;
ln -s /usr/bin/clang++-7 /usr/bin/clang++;
export CC=/usr/bin/clang;
export CXX=/usr/bin/clang++;

QT_PATH="/opt/Opensoft/Qt"
BUILD_ROOT="/build"
PACKAGE_ROOT="$BUILD_ROOT/package"
DEPLOY_PREFIX="$QT_PATH"
DEPLOY_EXTPREFIX="$PACKAGE_ROOT/$DEPLOY_PREFIX"
SOURCES_DIR="$BUILD_ROOT/src"
BUILDING_THREADS_COUNT=$(( $(cat /proc/cpuinfo | grep processor | wc -l) + 1 ))
PACKAGE_FILEPATH="/__deb/${PACKAGE_NAME}-${PACKAGE_VERSION}.deb"

echo "Starting QCA package build."
echo "Final package will be at $PACKAGE_FILEPATH"
echo "QCA repo: $QCA_REPOSITORY"
echo "QCA tag: $QCA_TAG"

mkdir -p $SOURCES_DIR
cd $SOURCES_DIR
git clone $QCA_REPOSITORY qca
cd qca
git checkout $QCA_TAG
echo;
for patch in `(ls /patch/*.patch 2>/dev/null || true) | sort -V`; do
    echo "Applying `basename $patch`...";
    git apply $patch;
    echo "Applied.";
done;
sed -i s/-ansi/-std=c++17/ CMakeLists.txt
export PATH=/opt/Opensoft/Qt/bin:$PATH

cmake -DCMAKE_PREFIX_PATH=$QT_PATH -DUSE_RELATIVE_PATHS=ON -DWITH_ossl_PLUGIN=yes  .
make -j$BUILDING_THREADS_COUNT
make DESTDIR=$PACKAGE_ROOT install

export IGNORE_PACKAGES_PATTERN="qca"
export LD_LIBRARY_PATH=$QT_PATH/lib:$LD_LIBRARY_PATH
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

fakeroot dpkg-deb --build "$PACKAGE_ROOT" "$PACKAGE_FILEPATH"
