#!/bin/bash

sudo modprobe vfio-pci
sudo modprobe openvswitch
sudo mount -t hugetlbfs hugetlbfs /mnt/huge
sudo mount -t hugetlbfs none /mnt/huge_2mb -o pagesize=2MB

echo 4096 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --pidfile --detach
ovs-vswitchd unix:/usr/local/var/run/openvswitch/db.sock --pidfile --detach

ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask=0x123
ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask=0x123
ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem="1024,1024"

sudo dpdk-devbind.py --bind=vfio-pci ens4f0

ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev
ovs-vsctl add-port br0 vhost-user1 -- set Interface vhost-user1 type=dpdkvhostuser
ovs-vsctl add-port br0 vhost-user2 -- set Interface vhost-user2 type=dpdkvhostuser
