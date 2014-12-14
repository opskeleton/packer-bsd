#!/bin/sh -eux

zfs set compression=off tank/ROOT/default
zfs set compression=off tank/root
dd if=/dev/zero of=/EMPTY bs=1M
dd if=/dev/zero of=/root/EMPTY bs=1M
rm -f /EMPTY
rm -f /root/EMPTY
zfs set compression=on tank/ROOT/default
zfs set compression=on tank/root
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync
