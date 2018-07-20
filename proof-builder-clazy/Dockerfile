FROM dkormalev/proof-builder-base

RUN BUILD_DEPS='libclang-6.0-dev llvm-6.0-dev' \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends $BUILD_DEPS \
    && git clone -b 1.3 --depth 1 https://github.com/KDE/clazy.git \
    && mkdir clazy/build \
    && cd clazy/build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr \
             -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_LIBDIR=lib \
             -DLLVM_CONFIG_EXECUTABLE:FILEPATH=/usr/bin/llvm-config-6.0 .. \
    && make -j4 \
    && make install \
    && cd ../.. \
    && rm -rf clazy \
    && apt-get -qq purge --auto-remove -y $BUILD_DEPS \
    && rm -rf /var/lib/apt/lists/*

ENV CLANGXX=$CXX \
    CXX=/usr/bin/clazy
