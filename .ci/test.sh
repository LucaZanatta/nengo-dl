#!/usr/bin/env bash
set -e -v

NAME=$0
COMMAND=$1

if [[ "$COMMAND" == "install" ]]; then
    pip install git+https://github.com/drasmuss/spaun2.0.git
elif [[ "$COMMAND" == "script" ]]; then
    pytest $TEST_ARGS -v -n 2 --color=yes --pyargs nengo
    pytest $TEST_ARGS -v -n 2 --color=yes --durations 20 nengo_dl
elif [[ -z "$COMMAND" ]]; then
    echo "$NAME requires a command like 'install' or 'script'"
else
    echo "$NAME does not define $COMMAND"
fi
