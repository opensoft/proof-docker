FROM opensoftdev/proof-builder-android-base

COPY etc_apt_aptconfd_default-release /etc/apt/apt.conf.d/default-release
COPY etc_apt_sources.list /etc/apt/sources.list

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends -t testing ccache -V \
    && /image_cleaner.sh

ENV CC="ccache $CC" \
    CXX="ccache $CXX" \
    PATH=/usr/lib/ccache:$PATH
