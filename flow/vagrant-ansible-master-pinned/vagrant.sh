#!/bin/bash

set -e

echo "[$(date)] START Flow Vagrant"

VAGRANT_CMAKE_FILE=/home/dan/builds/flow/vagrant-ansible-master-pinned/vagrant.cmake
VAGRANT_SETUP_FILE=/home/dan/builds/flow/setup.sh
DIR=$(mktemp -d)

function cleanup_vagrant {
    cd "$DIR" && vagrant destroy --force && rm -rf "$DIR"
}
trap cleanup_vagrant EXIT


# Clone Flow
git clone git@github.com:Kitware/Flow.git "$DIR"
pushd "$DIR"

# Copy files for the guest to $DIR so they will be mounted on /vagrant
cp -v $VAGRANT_SETUP_FILE $VAGRANT_CMAKE_FILE .

# "Disable" forwarded ports since they're unnecessary here and might conflict
sed -i '/forwarded_port/d' Vagrantfile

export VAGRANT_NO_PLUGINS=1

# Start up vagrant box
vagrant up --provider=virtualbox

# Install CMake
vagrant ssh --command "sudo apt-get install --yes cmake"

# Copy CTestConfig into Girder install to properly report it
vagrant ssh --command "sudo su girder -c 'cp /opt/flow/CTestConfig.cmake /opt/girder/CTestConfig.cmake'"

# Copy /vagrant/* scripts to a place where girder user can execute them
vagrant ssh --command "sudo cp /vagrant/setup.sh /opt/girder && sudo chown girder:girder /opt/girder/setup.sh"
vagrant ssh --command "sudo cp /vagrant/vagrant.cmake /opt/girder && sudo chown girder:girder /opt/girder/vagrant.cmake"
vagrant ssh --command "sudo cp /vagrant/devops/ansible/site.yml /opt/girder && sudo chown girder:girder /opt/girder/site.yml"

# Install pip dev requirements, npm install, etc
vagrant ssh --command "sudo su girder -c '/opt/girder/setup.sh'"

# Run ctest
vagrant ssh --command "sudo su girder -c '. /opt/.girderenv/bin/activate && ctest -S /opt/girder/vagrant.cmake -VV'"
