#!/bin/bash
virt-install \
--connect qemu:///system \
--name aiubuntu \
--os-variant ubuntu20.04 \
--os-type linux \
--ram 2048 \
--disk bus=virtio,pool=KVMs,size=15,format=qcow2 \
--network network=OVS0,model=virtio,virtualport_type=openvswitch,portgroup=VLAN100 \
--vcpus 2 \
--location '/home/tonyukuk/Downloads/ubuntu-20.04.2-live-server-amd64.iso',initrd=casper/initrd,kernel=casper/vmlinuz \
--extra-args='ip=dhcp autoinstall  ds=nocloud-net;s=http://192.168.122.1:3003/ console=ttyS0,115200n8'

#Static IP
#ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>:<dns0-ip>:<dns1-ip>:<ntp0-ip>
#For ubuntu net.ifnames=0 and biosdevname=0  for predictable NIC device name like eth0,1...
virt-install \
--connect qemu:///system \
--name aiubuntu \
--os-variant ubuntu20.04 \
--os-type linux \
--ram 2048 \
--disk bus=virtio,pool=KVMs,size=15,format=qcow2 \
--network network=OVS0,model=virtio,virtualport_type=openvswitch,portgroup=VLAN100 \
--vcpus 2 \
--location '/home/tonyukuk/Downloads/ubuntu-20.04.2-live-server-amd64.iso',initrd=casper/initrd,kernel=casper/vmlinuz \
--extra-args='net.ifnames=0 biosdevname=0 ip=10.5.100.45::10.5.100.254:255.255.255.0:ubuntutest:eth0:none:10.5.100.253 autoinstall  ds=nocloud-net;s=http://10.5.100.10:3003/'







