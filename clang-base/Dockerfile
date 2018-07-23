FROM debian:stretch-backports

RUN CLANG_VERSION=6.0 \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        ca-certificates \
        make cmake git \
        clang-$CLANG_VERSION clang-format-$CLANG_VERSION \
    && ln -s /usr/lib/llvm-$CLANG_VERSION/bin/clang /usr/bin/clang \
    && ln -s /usr/lib/llvm-$CLANG_VERSION/bin/clang++ /usr/bin/clang++ \
    && ln -s /usr/lib/llvm-$CLANG_VERSION/bin/clang-format /usr/bin/clang-format \
    && rm -rf /var/lib/apt/lists/* \
    && git config --global advice.detachedHead false

ENV CC=/usr/bin/clang \
    CXX=/usr/bin/clang++

ENTRYPOINT exec /bin/bash
