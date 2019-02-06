#!/usr/bin/env bash
set -e -v

# see https://oncletom.io/2016/travis-ssh-deploy/ for instructions on how the
# remote server is set up for this script to connect to

NAME=$0
COMMAND=$1

if [[ "$COMMAND" == "install" ]]; then
    pip install coverage  # needed for the uploading in after_success
    # decrypt private key, see https://docs.travis-ci.com/user/encrypting-files/
    openssl aes-256-cbc -K $encrypted_fcdbeb54a1c4_key -iv $encrypted_fcdbeb54a1c4_iv -in .ci/travis_rsa.enc -out ~/.ssh/id_rsa -d
    chmod 600 ~/.ssh/id_rsa
    echo -e "$ABRGPU_INFO" >> ~/.ssh/config  # ssh config, stored in travis-ci settings
    ssh -o StrictHostKeyChecking=no abrgpu "echo 'Connected to abrgpu'"
    scp -r . abrgpu:/tmp/nengo-dl-$TRAVIS_JOB_NUMBER
elif [[ "$COMMAND" == "script" ]]; then
    ssh abrgpu << EOF
        source ~/.profile
        cd /tmp/nengo-dl-$TRAVIS_JOB_NUMBER
        conda create -q -y -n travis-ci-$TRAVIS_JOB_NUMBER python=$PYTHON_VERSION
        source activate travis-ci-$TRAVIS_JOB_NUMBER
        pip install -e .[tests]
        pip install $TF_VERSION $NENGO_VERSION $NUMPY_VERSION
        pip install git+https://github.com/drasmuss/spaun2.0.git
        coverage run -m pytest $TEST_ARGS -v --color=yes --pyargs nengo && \
        coverage run -a -m pytest $TEST_ARGS -v --durations 20 --color=yes nengo_dl && \
        coverage report -m && \
        coverage xml
EOF
elif [[ "$COMMAND" == "after_success" ]]; then
    scp abrgpu:/tmp/nengo-dl-$TRAVIS_JOB_NUMBER/coverage.xml coverage.xml
    eval "bash <(curl -s https://codecov.io/bash)"
elif [[ "$COMMAND" == "after_script" ]]; then
    ssh abrgpu "source ~/.profile; conda-env remove -y -n travis-ci-$TRAVIS_JOB_NUMBER"
    ssh abrgpu "rm -rf /tmp/nengo-dl-$TRAVIS_JOB_NUMBER"
elif [[ -z "$COMMAND" ]]; then
    echo "$NAME requires a command like 'install' or 'script'"
else
    echo "$NAME does not define $COMMAND"
fi
