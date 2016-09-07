#!/bin/bash
set -e

DIR=$(mktemp -d)

function cleanup_vagrant {
    cd "$DIR" && vagrant destroy --force && rm -rf "$DIR"
}
trap cleanup_vagrant EXIT

git clone -b ansible-role-refactor git@github.com:girder/girder.git "$DIR"
pushd "$DIR"

# Run on girder master
mkdir build && pushd build
SOURCE_DIR="$DIR" ctest -S /home/dan/builds/girder/vagrant.cmake -VV

# Run on latest girder tag
# git checkout "$(git describe --tags $(git rev-list --tags --max-count=1))"
# ctest -S vagrant.cmake -VV