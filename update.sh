#!/bin/sh

# This script is meant to be run as a cron job to update a gentoo system automatically
set -e

# Redirect output
#exec 1>>/var/log/autoupdate.log
#exec 2>>/var/log/autoupdate.log

echo
echo "Starting system update on $(date)"

# Drop our priority to the lowest possible
#renice -n 20 $$
#ionice -c3 -p$$
#chrt -i -p 0 $$

emerge --sync
layman -S
eix-update

emerge -f @world
emerge -uDN  --keep-going --complete-graph=y --with-bdeps=y @world
python-updater
perl-cleaner --all
haskell-updater
emerge -uDN  --keep-going --complete-graph=y --with-bdeps=y @system
emerge -uDN  --keep-going --complete-graph=y --with-bdeps=y @world
emerge -c
emerge -1 --keep-going  @preserved-rebuild
revdep-rebuild -i -- --keep-going
prelink -amR
env-update && source /etc/profile
