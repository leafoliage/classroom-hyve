#!/bin/sh

pkg install vm-bhyve qemu bhyve-firmware py311-qt5-pyqt

pool=$(zpool list | awk 'NR == 2 { print $1 }')
sysrc -qc vm_dir || {
	zpool create ${pool}/vm
	sysrc vm_dir="zfs:${pool}/vm"
	vm init
	cp /usr/local/share/examples/vm-bhyve/* /${pool}/vm/.templates/
	vm switch create public
	vm switch add public em0
}

pip install -r requirements.txt

wheel_ids=$(getent group wheel | cut -d : -f 4 | sed 's/,/ /g' | xargs -n1 id -u)
for uid in ${wheel_ids}; do
        [ ${uid} -eq 0 ] && continue
        echo "security.mac.do.rules=\"uid=${uid}>uid=0,gid=0,+gid=0,+gid=5\"" >> /etc/sysctl.conf
done
