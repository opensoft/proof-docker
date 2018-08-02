FROM debian:stretch-backports

COPY image_cleaner.sh /image_cleaner.sh
# stripped tar.xz with ndk-bundle from SDK with qrencode and libssl/libcrypto
COPY prebuilt/ndk-bundle.tar.xz /ndk-bundle.tar.xz
# qca bits
COPY prebuilt/opt_android_qt5.tar.xz /opt_android_qt5.tar.xz

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends ca-certificates wget openjdk-8-jdk xz-utils python3 git make \
    && cp /etc/resolv.conf etc/resolv.conf.old \
    && echo "nameserver 10.40.98.45" > /etc/resolv.conf \
    && mkdir /prebuilt && cd /prebuilt \
    && wget -nv https://deploy02-ct-ca01.tech-corps.com/view/PROOF%20Android/job/opensoft-qt-android/50/artifact/qt5-android-opensoft-5.11.1-j50.deb \
    && cat /etc/resolv.conf.old > /etc/resolv.conf \
    && rm /etc/resolv.conf.old \
    && cd /prebuilt && (dpkg -i *.deb 2> /dev/null || apt-get -qq -f install -y --no-install-recommends) \
    && apt-get -qq purge --auto-remove -y wget \
    && rm /opt/android/qt5/lib/libQt53D* && rm /opt/android/qt5/bin/qgltf && rm -rf /opt/android/qt5/doc \
    && cd /prebuilt && mv /opt_android_qt5.tar.xz ./ && tar -xJf opt_android_qt5.tar.xz && cp -R -t /opt/android/qt5 opt_android_qt5/* \
    && rm -rf /prebuilt && /bin/bash /image_cleaner.sh

ENV QTDIR=/opt/android/qt5 \
    LD_LIBRARY_PATH=/opt/android/qt5/lib:$LD_LIBRARY_PATH \
    PKG_CONFIG_PATH=/opt/android/qt5/lib/pkgconfig:$PKG_CONFIG_PATH \
    PATH=/opt/android/qt5/bin:/opt/android/sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:/usr/lib/jvm/java-8-openjdk-amd64:$PATH \
    CC=/opt/android/sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gcc \
    CXX=/opt/android/sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-g++ \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    ANDROID_SDK_ROOT=/opt/android/sdk \
    ANDROID_NDK_ROOT=/opt/android/sdk/ndk-bundle

ENTRYPOINT exec /bin/bash
