#!/usr/bin/env bash
set -e -v

NAME=$0
COMMAND=$1

if [[ "$COMMAND" == "install" ]]; then
    pip install -e .[docs]
    conda install -q pandoc
elif [[ "$COMMAND" == "script" ]]; then
    pylint nengo_dl --rcfile=setup.cfg
    codespell -q 3
    sphinx-build -b linkcheck docs docs/_build -W -D nbsphinx_execute=never
elif [[ -z "$COMMAND" ]]; then
    echo "$NAME requires a command like 'install' or 'script'"
else
    echo "$NAME does not define $COMMAND"
fi
