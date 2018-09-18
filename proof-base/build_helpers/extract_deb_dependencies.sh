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

WITH_VERSION="no"
while getopts "v" opt; do
    case $opt in
        v)
            WITH_VERSION="yes"
            ;;
        \?)
            echo "Invalid option" >&2
            exit 1
            ;;
    esac
done
shift $(($OPTIND - 1))

LIBS=`find "$1" -type f \( -executable -o -name "*.so" \) -exec ldd "{}" \; | awk '{print $1}' | sort | uniq`

for l in $LIBS; do
    IGNORE=0
    package=`find $(echo $LD_LIBRARY_PATH | sed "s/:/ /g") /lib /usr/lib -name "$(basename $l)" -exec dpkg -S '{}' \; -quit | awk -F: '{print $1}'`
    if [ -z "$package" ]; then
        continue
    fi

    for p in $(echo $IGNORE_PACKAGES_PATTERN | tr -s ':' ' '); do
        echo $package | grep -q $p &> /dev/null
        if [ $? -eq 0 ]; then
            IGNORE=1
            break
        fi
    done

    test $IGNORE -ne 0 && continue

    dpkg -s "$package" &> /dev/null
    if [ $? -ne 0 ]; then
        continue
    fi

    echo -n $package
    if [ "x$WITH_VERSION" == "xyes" ]; then
        echo -n \ \(\>=`dpkg -s "$package" | grep -m 1 -e "Version:" | awk '{print $2}'`\)
    fi
    echo
done | sort | uniq
