FROM debian:stretch-backports

COPY image_cleaner.sh /image_cleaner.sh

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends ca-certificates wget \
    && cp /etc/resolv.conf etc/resolv.conf.old \
    && echo "nameserver 10.40.98.45" > /etc/resolv.conf \
    && mkdir /prebuilt && cd /prebuilt \
    && wget -nv https://deploy02-ct-ca01.tech-corps.com/view/PROOF%20on%20Debian%209/job/opensoft-qt-deb9/15/artifact/qt5-opensoft-5.10.1-j15.deb \
    && wget -nv https://deploy02-ct-ca01.tech-corps.com/view/PROOF%20on%20Debian%209/job/opensoft-qca-deb9/5/artifact/qca-opensoft-2.1.0-j5.deb \
    && wget -nv https://deploy02-ct-ca01.tech-corps.com/view/PROOF%20on%20Debian%209/job/OpenCV-deb9/35/artifact/opencv-3.4.1-j35.deb \
    && cat /etc/resolv.conf.old > /etc/resolv.conf \
    && rm /etc/resolv.conf.old \
    && apt-get -qq install -y --no-install-recommends libqrencode3 libproxy1v5 libproxy1-plugin-webkit \
    && cd /prebuilt && (dpkg -i *.deb 2> /dev/null || apt-get -qq -f install -y --no-install-recommends) \
    && apt-get -qq purge --auto-remove -y wget \
    && rm /opt/Opensoft/Qt/lib/libQt53D* && rm /opt/Opensoft/Qt/lib/libQt5Designer* \
    && rm /opt/Opensoft/Qt/bin/assistant && rm /opt/Opensoft/Qt/bin/linguist && rm /opt/Opensoft/Qt/bin/designer \
    && rm /opt/Opensoft/Qt/bin/qdoc && rm /opt/Opensoft/Qt/bin/qgltf \
    && rm -rf /opt/Opensoft/Qt/doc && rm -rf /opt/Opensoft/Qt/share \
    && rm -rf /prebuilt && /bin/bash /image_cleaner.sh

ENV QTDIR=/opt/Opensoft/Qt \
    LD_LIBRARY_PATH=/opt/Opensoft/Qt/lib:$LD_LIBRARY_PATH \
    PKG_CONFIG_PATH=/opt/Opensoft/Qt/lib/pkgconfig:$PKG_CONFIG_PATH \
    PATH=/opt/Opensoft/Qt/bin:$PATH

ENTRYPOINT exec /bin/bash
