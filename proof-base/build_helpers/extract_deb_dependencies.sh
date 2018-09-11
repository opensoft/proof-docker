#!/bin/bash

WITH_VERSION="no"
while getopts "v" opt; do
    case $opt in
        v)
            WITH_VERSION="yes"
            ;;
        \?)
            echo "Invalid option" >&2
            exit 1
            ;;
    esac
done
shift $(($OPTIND - 1))

LIBS=`find "$1" -type f \( -executable -o -name "*.so" \) -exec ldd "{}" \; | awk '{print $1}' | sort | uniq`

for l in $LIBS; do
    IGNORE=0
    package=`find $(echo $LD_LIBRARY_PATH | sed "s/:/ /g") /lib /usr/lib -name "$(basename $l)" -exec dpkg -S '{}' \; -quit | awk -F: '{print $1}'`
    if [ -z "$package" ]; then
        continue
    fi

    for p in $(echo $IGNORE_PACKAGES_PATTERN | tr -s ':' ' '); do
        echo $package | grep -q $p &> /dev/null
        if [ $? -eq 0 ]; then
            IGNORE=1
            break
        fi
    done

    test $IGNORE -ne 0 && continue

    dpkg -s "$package" &> /dev/null
    if [ $? -ne 0 ]; then
        continue
    fi

    echo -n $package
    if [ "x$WITH_VERSION" == "xyes" ]; then
        echo -n \ \(\>=`dpkg -s "$package" | grep -m 1 -e "Version:" | awk '{print $2}'`\)
    fi
    echo
done | sort | uniq
