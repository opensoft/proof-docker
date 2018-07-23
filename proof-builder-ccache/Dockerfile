FROM dkormalev/proof-builder-base

COPY etc_apt_aptconfd_default-release /etc/apt/apt.conf.d/default-release
COPY etc_apt_sources.list /etc/apt/sources.list

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends -t testing ccache -V \
    && /usr/sbin/update-ccache-symlinks \
    && rm -rf /var/lib/apt/lists/*

ENV CC=/usr/lib/ccache/clang \
    CXX=/usr/lib/ccache/clang++ \
    PATH=/usr/lib/ccache:$PATH
