#!/usr/bin/env bash
set -e -v

NAME=$0
COMMAND=$1

if [[ "$COMMAND" == "install" ]]; then
    pip install -e .[tests]
    pip install git+https://github.com/drasmuss/spaun2.0.git
elif [[ "$COMMAND" == "script" ]]; then
    coverage run -m pytest $TEST_ARGS -v --color=yes --pyargs nengo
    coverage run -a -m pytest $TEST_ARGS -v --color=yes --durations 20 nengo_dl
    coverage report -m
elif [[ "$COMMAND" == "after_success" ]]; then
    eval "bash <(curl -s https://codecov.io/bash)"
elif [[ -z "$COMMAND" ]]; then
    echo "$NAME requires a command like 'install' or 'script'"
else
    echo "$NAME does not define $COMMAND"
fi
