#!/usr/bin/env bash
set -e -v

NAME=$0
COMMAND=$1

if [[ "$COMMAND" == "install" ]]; then
    pip install -e .[docs]
    conda install -q pandoc
elif [[ "$COMMAND" == "script" ]]; then
    git clone -b gh-pages-release https://github.com/nengo/nengo-dl.git ../nengo-dl-docs
    RELEASES=$(find ../nengo-dl-docs -maxdepth 1 -type d -name "v[0-9].*" -printf "%f,")

    if [[ "$TRAVIS_BRANCH" == "$TRAVIS_TAG" ]]; then
        RELEASES="$RELEASES$TRAVIS_TAG"
        sphinx-build -b html docs ../nengo-dl-docs/"$TRAVIS_TAG" -vW -A building_version="$TRAVIS_TAG" -A releases="$RELEASES"
    else
        sphinx-build -b html docs ../nengo-dl-docs -vW -A building_version=latest -A releases="$RELEASES"
    fi
elif [[ "$COMMAND" == "after_success" ]]; then
    cd ../nengo-dl-docs
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "TravisCI"
    git add --all

    if [[ "$TRAVIS_BRANCH" == "$TRAVIS_TAG" ]]; then
        git commit -m "Documentation for release $TRAVIS_TAG"
        git push -q "https://$GH_TOKEN@github.com/nengo/nengo-dl.git" gh-pages-release
    elif [[ "${TRAVIS_PULL_REQUEST_BRANCH:-$TRAVIS_BRANCH}" == "master" ]]; then
        git commit -m "Last update at $(date '+%Y-%m-%d %T')"
        git push -fq "https://$GH_TOKEN@github.com/nengo/nengo-dl.git" gh-pages-release:gh-pages
    elif [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
        git commit -m "Documentation for branch $TRAVIS_BRANCH"
        git push -fq "https://$GH_TOKEN@github.com/nengo/nengo-dl.git" gh-pages-release:gh-pages-test
    fi
elif [[ -z "$COMMAND" ]]; then
    echo "$NAME requires a command like 'install' or 'script'"
else
    echo "$NAME does not define $COMMAND"
fi
