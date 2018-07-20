FROM dkormalev/clang-base

RUN mkdir /prebuilt && mkdir /sandbox
COPY prebuilt/*.deb /prebuilt/
RUN cd /prebuilt \
    && apt-get -qq update \
    && dpkg -i *.deb 2> /dev/null || apt-get -qq -f install -y --no-install-recommends

RUN rm -rf /prebuilt && rm -rf /var/lib/apt/lists/*

ENV QTDIR=/opt/Opensoft/Qt \
    LD_LIBRARY_PATH=/opt/Opensoft/Qt/lib:$LD_LIBRARY_PATH \
    PKG_CONFIG_PATH=/opt/Opensoft/Qt/lib/pkgconfig:$PKG_CONFIG_PATH \
    PATH=/opt/Opensoft/Qt/bin:$PATH
