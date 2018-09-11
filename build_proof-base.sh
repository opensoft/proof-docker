#!/bin/bash
set -e;

OPENCV_VERSION=3.4.1
QT_VERSION=5.10.1
QCA_VERSION=2.2.0

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/proof-base"
PREBUILT_DIR="$ROOT/prebuilt"

rm -rf "$PREBUILT_DIR";
mkdir -p "$PREBUILT_DIR";

docker rm opencv_builder --force || true;
docker rm qt_builder --force || true;
docker rm qca_builder --force || true;

docker run -id --name opencv_builder -v "$PREBUILT_DIR":/__deb debian:stretch-backports tail -f /dev/null;
docker cp "$ROOT/build_helpers/build_opencv.sh" opencv_builder:/build_opencv.sh;
docker exec -t opencv_builder /build_opencv.sh "$OPENCV_VERSION";
docker rm opencv_builder --force;

docker run -id --name qt_builder -v "$PREBUILT_DIR":/__deb debian:stretch-backports tail -f /dev/null;
docker cp "$ROOT/build_helpers/extract_deb_dependencies.sh" qt_builder:/extract_deb_dependencies.sh;
docker cp "$ROOT/build_helpers/build_qt.sh" qt_builder:/build_qt.sh;
docker exec -t qt_builder /build_qt.sh "$QT_VERSION";
docker rm qt_builder --force;

docker run -id --name qca_builder -v "$PREBUILT_DIR":/__deb debian:stretch-backports tail -f /dev/null;
docker cp "$ROOT/build_helpers/extract_deb_dependencies.sh" qca_builder:/extract_deb_dependencies.sh;
docker cp "$ROOT/build_helpers/build_qca.sh" qca_builder:/build_qca.sh;
docker exec -t qca_builder /build_qca.sh "$QCA_VERSION";
docker rm qca_builder --force;

docker build --squash --force-rm --no-cache -t opensoftdev/proof-base -f "$ROOT/Dockerfile" "$ROOT/";

for prebuilt in "$PREBUILT_DIR"/*.deb; do
    aws s3 cp "$prebuilt" "s3://proof.travis.builds/__dependencies/`basename $prebuilt`";
done
docker push opensoftdev/proof-base;
