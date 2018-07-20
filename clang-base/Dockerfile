FROM debian:stretch-backports

RUN CLANG_VERSION=6.0 \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        ca-certificates \
        make cmake git \
        clang-$CLANG_VERSION clang-format-$CLANG_VERSION \
    && rm -rf /var/lib/apt/lists/* \
    && git config --global advice.detachedHead false

ENV CC=/usr/lib/llvm-6.0/bin/clang \
    CXX=/usr/lib/llvm-6.0/bin/clang++ \
    PATH=/usr/lib/llvm-6.0/bin:$PATH

ENTRYPOINT exec /bin/bash
