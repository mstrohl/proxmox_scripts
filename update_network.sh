#!/bin/bash

echo "=== Proxmox interface file change"
if [ -f /etc/network/interfaces.new ]
 then
  mv /etc/network/interfaces /etc/network/interfaces.`date +%Y%m%d`
  mv /etc/network/interfaces.new /etc/network/interfaces
fi

echo "==== Proxmox Network-tap-ssh RESTART"

tar czvf save_proxmox_vmbr_`date +%Y%m%d`/etc/pve/nodes/*/qemu-server/*.conf

brctl show | grep 'vmbr' | awk '{print $1}' | while read line
do
>$line
brctl show $line | egrep -v 'bridge name|vmbr' | awk {'print $1'} >> $line
done


/etc/init.d/networking stop && /etc/init.d/networking start

grep -FH bridge= /etc/pve/nodes/*/qemu-server/*.conf \
 | perl -nle 'print "tap$1i$2 master $3" if /\/(\d+).conf:net(\d+):.*?bridge=(vmbr\d+)/' \
 | xargs -l1 ip link set

echo "=== Proxmox script end
