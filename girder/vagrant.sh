#!/bin/bash
set -e

export PATH="/home/dan/bin:$PATH"
if [ "$#" -ne 1 ]; then
    export TEST_GROUP="Nightly"
else
    export TEST_GROUP="$1"
fi

DIR=$(mktemp -d)

function cleanup_vagrant {
    # Vagrant boxes are destroyed through the tests

    # Run vagrant destroy if a machine is still running (the tests failed to shut it down)


    # Delete the top level directory made for this run
    rm -rf "$DIR"
}
trap cleanup_vagrant EXIT

pushd "$DIR"
git clone git@github.com:girder/girder.git .

# Run on girder master
mkdir build && pushd build
SOURCE_DIR="$DIR" /home/dan/tmp/cmake/bin/ctest --repeat-until-pass 5 -S /home/dan/builds/girder/vagrant.cmake -VV

popd && rm -rf build

# Run on latest girder tag
mkdir build && pushd build
git checkout "$(git describe --tags $(git rev-list --tags --max-count=1))"
SOURCE_DIR="$DIR" /home/dan/tmp/cmake/bin/ctest --repeat-until-pass 5 -S /home/dan/builds/girder/vagrant.cmake -VV
