#!/usr/bin/env bash
set -e -v

NAME=$0
COMMAND=$1

if [[ "$COMMAND" == "install" ]]; then
    pip install -e .[docs]
elif [[ "$COMMAND" == "before_script" ]]; then
    export DISPLAY=:99.0
    sh -e /etc/init.d/xvfb start
    sleep 3
elif [[ "$COMMAND" == "script" ]]; then
    python docs/whitepaper/whitepaper2018_code.py > /dev/null
    pytest -v --durations 20 --nbval-lax docs/examples
elif [[ -z "$COMMAND" ]]; then
    echo "$NAME requires a command like 'install' or 'script'"
else
    echo "$NAME does not define $COMMAND"
fi
