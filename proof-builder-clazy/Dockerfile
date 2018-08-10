FROM opensoftdev/proof-builder-base

RUN CLANG_VERSION=6.0 \
    BUILD_DEPS="libclang-$CLANG_VERSION-dev llvm-$CLANG_VERSION-dev cmake" \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends $BUILD_DEPS \
    && git clone -b master --depth 1 https://github.com/KDE/clazy.git \
    && mkdir clazy/build \
    && cd clazy/build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr \
             -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_LIBDIR=lib \
             -DLLVM_CONFIG_EXECUTABLE:FILEPATH=/usr/bin/llvm-config-$CLANG_VERSION .. \
    && make -j4 && make install \
    && cd ../.. \
    && rm -rf clazy \
    && apt-get -qq purge --auto-remove -y $BUILD_DEPS \
    && /image_cleaner.sh

ENV CLANGXX=$CXX \
    CXX=/usr/bin/clazy
