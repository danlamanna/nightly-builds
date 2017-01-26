#!/bin/bash
set -e

DIR=$(mktemp -d)

function cleanup_vagrant {
    echo "cleaning up"
    # Run vagrant destroy if a machine is still running
    vagrant destroy -f

    # Delete the top level directory made for this run
    rm -rf "$DIR"
}
trap cleanup_vagrant EXIT

pushd "$DIR"
git clone -b fix-geonotebook-role git@github.com:opengeoscience/geonotebook.git .

# Print versions of everything
vagrant --version
ansible --version
echo "geonotebook: $(git rev-parse --short HEAD)"

# Set this to a port less likely to conflict
sed -i 's/host: 8888/host: 9821/' Vagrantfile

# Spin up notebook server
vagrant up

# Assert that Jupyter is in the source code
curl --silent --location http://localhost:9821 | grep 'Jupyter'
