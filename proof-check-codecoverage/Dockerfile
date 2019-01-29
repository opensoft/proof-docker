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

FROM opensoftdev/proof-base

COPY etc_apt_sources.list /etc/apt/sources.list
COPY etc_apt_preferences /etc/apt/preferences

# Switch to system lcov when 1.14 will be released
RUN rm /etc/apt/sources.list.d/backports.list \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends -t stretch-backports cmake make pkg-config git fakeroot libgl1-mesa-dev python3 libqrencode-dev libproxy-dev \
    && apt-get -qq install -y --no-install-recommends -t testing zlib1g-dev abi-dumper g++ g++-8 lcov ccache ninja-build \
    && apt-get -qq remove -y lcov \
    && mkdir /extra && cd /extra \
    && git clone https://github.com/linux-test-project/lcov.git && cd lcov && make install \
    && cd / && rm -rf /extra \
    && /usr/sbin/update-ccache-symlinks \
    && mkdir /sandbox \
    && git config --global advice.detachedHead false \
    && /image_cleaner.sh

ENV CTEST_OUTPUT_ON_FAILURE=1 \
    CC=/usr/lib/ccache/gcc \
    CXX=/usr/lib/ccache/g++ \
    PATH=/usr/lib/ccache:$PATH
