FROM debian:stretch-backports

COPY image_cleaner.sh /image_cleaner.sh
COPY prebuilt/*.deb /prebuilt/

RUN chmod +x /image_cleaner.sh \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends ca-certificates \
    && cd /prebuilt && (dpkg -i *.deb 2> /dev/null || apt-get -qq -f install -y --no-install-recommends) \
    && apt-get -qq install -y --no-install-recommends libqrencode3 libproxy1v5 libproxy1-plugin-webkit \
    && rm /opt/Opensoft/Qt/lib/libQt5Designer* && rm /opt/Opensoft/Qt/bin/designer \
    && rm /opt/Opensoft/Qt/bin/assistant && rm /opt/Opensoft/Qt/bin/linguist \
    && rm /opt/Opensoft/Qt/bin/qdoc && rm -rf /opt/Opensoft/Qt/doc && rm -rf /opt/Opensoft/Qt/share \
    && rm -rf /prebuilt && /image_cleaner.sh

ENV QTDIR=/opt/Opensoft/Qt \
    LD_LIBRARY_PATH=/opt/Opensoft/Qt/lib:$LD_LIBRARY_PATH \
    PKG_CONFIG_PATH=/opt/Opensoft/Qt/lib/pkgconfig:$PKG_CONFIG_PATH \
    PATH=/opt/Opensoft/Qt/bin:$PATH

ENTRYPOINT exec /bin/bash
