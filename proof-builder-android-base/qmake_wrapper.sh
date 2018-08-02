#!/bin/bash
echo '$' qmake -r -spec android-g++ "QMAKE_CC=$CC" "QMAKE_CXX=$CXX" "QMAKE_LINK=$CXX" "$@"
qmake -r -spec android-g++ "QMAKE_CC=$CC" "QMAKE_CXX=$CXX" "QMAKE_LINK=$CXX" "$@"
