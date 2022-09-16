#!/bin/bash

OVS_DIR=/home/git-repo/ovs

kill_ovs() {
	echo "1"
        pkill -9 ovsdb-server
        pkill -9 ovs-vswitchd
        rm -rf /usr/local/var/run/openvswitch
        rm -rf /usr/local/var/log/openvswitch
        rm -rf /usr/local/etc/openvswitch/
        rm -f /usr/local/etc/openvswitch/conf.db
        mkdir -p /usr/local/etc/openvswitch
        mkdir -p /usr/local/var/run/openvswitch
        mkdir -p /usr/local/var/log/openvswitch

        cd $OVS_DIR
        ./ovsdb/ovsdb-tool create /usr/local/etc/openvswitch/conf.db ./vswitchd/vswitch.ovsschema

        cd -
}

module_init_and_hugepage_init() {
	echo "2"
	sudo modprobe vfio-pci
	sudo modprobe openvswitch
	sudo mount -t hugetlbfs hugetlbfs /mnt/huge
	sudo mount -t hugetlbfs none /mnt/huge_2mb -o pagesize=2MB

	echo 4096 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
}

activate_ovs() {
	ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --pidfile --detach
	ovs-vswitchd unix:/usr/local/var/run/openvswitch/db.sock --pidfile --detach

	ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
	ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask=0x123
	ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask=0x123
	ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem="1024,1024"

	#dpdk-devbind.py --bind=vfio-pci ens4f0
}

ovs_cfg() {
	ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev

	ovs-vsctl add-port br0 dpdkvhostclient0 -- set Interface dpdkvhostclient0 type=dpdkvhostuserclient options:vhost-server-path=/tmp/dpdkvhostclient0
	ovs-vsctl add-port br0 dpdkvhostclient1 -- set Interface dpdkvhostclient1 type=dpdkvhostuserclient options:vhost-server-path=/tmp/dpdkvhostclient1
}

kill_ovs
module_init_and_hugepage_init
activate_ovs
ovs_cfg
