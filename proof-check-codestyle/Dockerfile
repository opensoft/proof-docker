FROM debian:stretch-backports

COPY .clang-format /sandbox/.clang-format
COPY image_cleaner.sh /image_cleaner.sh

RUN chmod +x /image_cleaner.sh \
    && CLANG_VERSION=6.0 \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends clang-format-$CLANG_VERSION \
    && ln -s /usr/lib/llvm-$CLANG_VERSION/bin/clang-format /usr/bin/clang-format \
    && /image_cleaner.sh
