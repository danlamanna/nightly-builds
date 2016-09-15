#!/bin/bash
set -e
export PATH="/home/dan/bin:$PATH"

NOW=$(date)
echo "[$NOW] START CDash Vagrant"

VAGRANT_CMAKE_FILE=/home/dan/builds/cdash/vagrant-ansible-master-redis/vagrant.cmake
START_CONSUMER_FILE=/home/dan/builds/cdash/vagrant-ansible-master-redis/start-consumer.sh
DIR=$(mktemp -d)

function cleanup_vagrant {
    cd "$DIR" && vagrant destroy --force && rm -rf "$DIR"
}
trap cleanup_vagrant EXIT


# Clone CDash, startup vagrant box
git clone git@github.com:Kitware/CDash.git "$DIR"
pushd "$DIR"

# I might have a vagrant box running, forwarded ports are unnecessary for this so strip them out
sed -i '/forwarded_port/d' Vagrantfile && vagrant up --provider=virtualbox

if [ $? -ne 0 ]; then
    echo "Failed to start vagrant box"
    exit 1
fi

# Copy vagrant.cmake to the machine, and run ctest
cp $VAGRANT_CMAKE_FILE "$DIR"  # These are implicitly copied onto the machine via a shared folder
cp $START_CONSUMER_FILE "$DIR"
vagrant ssh --command "ctest -S /vagrant/vagrant.cmake -VV"

# Tear down everything
vagrant destroy --force

if [ $? -ne 0 ]; then
    echo "Failed to destroy vagrant box"
    exit 1
fi
