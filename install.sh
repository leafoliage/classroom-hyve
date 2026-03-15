#!/bin/sh

pkg install vm-bhyve qemu bhyve-firmware py311-qt5-pyqt py311-pip
sysrc vm_enable="YES"

pool=$(zpool list | awk 'NR == 2 { print $1 }')
sysrc -qc vm_dir || {
	zfs create ${pool}/vm
	sysrc vm_dir="zfs:${pool}/vm"
	vm init
	cp /usr/local/share/examples/vm-bhyve/* /${pool}/vm/.templates/
	vm switch create public
	vm switch add public em0
}
cp zvol-uefi-graph.conf /${pool}/vm/.templates/

pip install -r requirements.txt

wheel_ids=$(getent group wheel | cut -d : -f 4 | sed 's/,/ /g' | xargs -n1 id -u)
rules=""
for uid in ${wheel_ids}; do
        [ ${uid} -eq 0 ] && continue
	[ -n "${rules}" ] && rules="${rules}; " || rules="security.mac.do.rules=\""
        rules="${rules}uid=${uid}>uid=0,gid=0,+gid=0,+gid=5"
done
rules="${rules}\""
grep -q "security.mac.do.rules" /etc/sysctl.conf || echo ${rules} >> /etc/sysctl.conf
