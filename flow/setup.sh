#!/bin/bash

# Mysterious requirement
mongo --eval 'db.runCommand({setParameter: 1, textSearchEnabled: true})' admin

GIRDER_HOME=/opt/girder

. /opt/.girderenv/bin/activate

# Setup Girder
pip install -r $GIRDER_HOME/requirements.txt -r $GIRDER_HOME/requirements-dev.txt
cd $GIRDER_HOME && npm install
