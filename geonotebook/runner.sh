#!/bin/bash

# Necessary to use notify-send within a cron environment
# See http://unix.stackexchange.com/a/111194
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

$HOME/builds/geonotebook/vagrant.sh >> $HOME/builds/logs/geonotebook/$(date +%F).log

if [ $? -eq 0 ]; then
    notify-send -u normal "Geonotebook built successfully."
else
    notify-send -u critical "Geonotebook failed to build."
fi
