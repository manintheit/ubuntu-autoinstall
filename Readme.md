## Ubuntu Autoinstall Experiment

### Download Ubuntu image and mount it.

```shell
sudo mount -o loop ubuntu-20.04.2-live-server-amd64.iso /mnt/
```

### Create folder for http server to serve .
Create a folder /www and put necessary files to fetched by the Ubuntu auto-install. It is similar to cloud-init. So you need to have
**user-data** and **meta-data** files in the **/www**
```
mkdir /www
```

### Sample user-data file

```yaml
#cloud-config
autoinstall:
  version: 1
  early-commands:
    - systemctl stop ssh # otherwise packer tries to connect and exceed max attempts
  network:
    network:
      version: 2
      ethernets:
        eth0:
          addresses:
            - 10.5.100.23/24
          gateway4: 10.5.100.254
          nameservers: 
            search: [homelab.io]
            addresses: [8.8.8.8]
  apt:
    preserve_sources_list: false
    primary:
      - arches: [amd64]
        uri: "http://archive.ubuntu.com/ubuntu/"
  ssh:
    install-server: yes
#    authorized-keys:
#      - "your SSH pub key here"
    allow-pw: yes
  identity:
    hostname: ubuntu-00
    password: "$6$FhcddHFVZ7ABA4Gi$9l4yURWASWe8xEa1jzI0bacVLvhe3Yn4/G3AnU11K3X0yu/mICVRxfo6tZTB2noKljlIRzjkVZPocdf63MtzC0" # root
    username: ubuntu # root doesn't work
  packages:
    - apt-transport-https 
    - ca-certificates 
    - curl
  user-data:
    disable_root: false
  late-commands:
    - echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/ubuntu
    - sed -ie 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0 ipv6.disable=1 biosdevname=0 console=ttyS0,115200n8"/' /target/etc/default/grub
    - curtin in-target --target /target update-grub2
    - swapoff -a
    - sed -ie '/\/swap.img/s/^/#/g' /target/etc/fstab
    - echo 'HelloworlLD!' > /target/var/log/hello.txt
    - curl -vo /target/usr/share/keyrings/kubernetes-archive-keyring.gpg http://10.5.100.10:3003/apt-key.gpg
    - |
      cat <<EOF |  tee /target/etc/modules-load.d/k8s.conf
      br_netfilter
      EOF
    - |
      cat <<EOF | sudo tee /target/etc/sysctl.d/k8s.conf
      net.bridge.bridge-nf-call-ip6tables = 1
      net.bridge.bridge-nf-call-iptables = 1
      EOF
    - sysctl --system
    - echo 'deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main' | tee /target/etc/apt/sources.list.d/kubernetes.list
```

```shell
touch meta-data
```

### Create Virtual Machine with virt-install
This is the sample command to create virtual machine with **virt-install** with static IP. There is also an option for dhcp. For more information check **run.sh**
```shell
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
```


