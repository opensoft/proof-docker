FROM opensoftdev/proof-base

RUN CLANG_VERSION=6.0 \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        make pkg-config git fakeroot \
        clang-$CLANG_VERSION clang-format-$CLANG_VERSION \
        zlib1g-dev libgl1-mesa-dev python3 libqrencode-dev libproxy-dev \
    && mkdir /sandbox \
    && ln -s /usr/lib/llvm-$CLANG_VERSION/bin/clang /usr/bin/clang \
    && ln -s /usr/lib/llvm-$CLANG_VERSION/bin/clang++ /usr/bin/clang++ \
    && ln -s /usr/lib/llvm-$CLANG_VERSION/bin/clang-format /usr/bin/clang-format \
    && git config --global advice.detachedHead false \
    && /image_cleaner.sh

ENV CC=/usr/bin/clang \
    CXX=/usr/bin/clang++
