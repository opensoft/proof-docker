FROM debian:stretch-backports

COPY image_cleaner.sh /image_cleaner.sh
# stripped tar.xz with ndk-bundle from SDK with qrencode and libssl/libcrypto
COPY prebuilt/ndk-bundle.tar.xz /ndk-bundle.tar.xz
# qt5 from 5.10.1 offline installer with qca
ADD prebuilt/qt.tar.xz /opt/android
COPY qmake_wrapper.sh /qmake_wrapper.sh

RUN chmod +x /qmake_wrapper.sh && chmod +x /image_cleaner.sh \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends ca-certificates openjdk-8-jdk xz-utils python3 git make \
    && /image_cleaner.sh

ENV QTDIR=/opt/android/qt/5.10.1/android_armv7 \
    LD_LIBRARY_PATH=/opt/android/qt/5.10.1/android_armv7/lib:$LD_LIBRARY_PATH \
    PKG_CONFIG_PATH=/opt/android/qt/5.10.1/android_armv7/lib/pkgconfig:$PKG_CONFIG_PATH \
    PATH=/opt/android/qt/5.10.1/android_armv7/bin:/opt/android/sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:/usr/lib/jvm/java-8-openjdk-amd64:$PATH \
    CC=/opt/android/sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gcc \
    CXX=/opt/android/sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-g++ \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    ANDROID_SDK_ROOT=/opt/android/sdk \
    ANDROID_NDK_ROOT=/opt/android/sdk/ndk-bundle

ENTRYPOINT exec /bin/bash
