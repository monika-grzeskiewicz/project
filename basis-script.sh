#!/bin/bash

#	1	create_VM
#	2	destroy_VM
#	3	create_bridge
#	4	create_VM_interface
#	5	attach_interface_to_the_bridge
#	6	detach_interface
#	7	add_a_dhcp_static_host_entry_to_the_network
#	8	enable_ip_forwarding
#	9	delete_bridge
#	10	disable_cloud-init's_network_configuration_capabilities
#	11	add_route
#	12	add_route_weight
#	13	quagga

case $1 in

  #1
  create_VM)

        uvt-kvm create $2 release=bionic
        ;;
  #2
  destroy_VM)

        uvt-kvm destroy  $2
        ;;
  #3
  create_bridge)

        printf  "<network>
                  <name>$2</name>
                  <bridge name='$2' stp='on' delay='0'/>
                          <forward mode = 'route' />
                        <ip address='$3' netmask='$4'>
                    <dhcp>
                      <range start='$5' end='$6'/>
                    </dhcp>
                  	</ip>
                </network>"              >> $2.xml

	virsh net-define $2.xml
        virsh net-start $2
        virsh net-autostart $2
        ;;
  #4
  create_VM_interface)

        if [[ $3 -eq 7 ]]
        then
        uvt-kvm ssh $2 'sudo apt-get install ifupdown'
        uvt-kvm ssh $2 "sudo chmod  777 /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo auto ens7 >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo iface ens7 inet dhcp >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo        >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo auto lo >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo iface lo inet loopback >> /etc/network/interfaces"
	uvt-kvm ssh $2 "sudo echo auto ens3 >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo iface ens3 inet dhcp>> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo up ip route change default via 192.168.122.1>> /etc/network/interfaces"
        else
        uvt-kvm ssh $2 "sudo echo auto ens$3 >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo iface ens$3 inet dhcp >> /etc/network/interfaces"
        fi
        ;;
  #5
  attach_interface_to_the_bridge)
        sudo virsh attach-interface --domain $2 --type network --source $3 --model virtio --mac $4 --config --live
        ;;

  #6
  detach_interface)
        sudo virsh detach-interface --domain $2 --type network --mac $3 --config
        ;;

  #7
  add_a_dhcp_static_host_entry_to_the_network)
        virsh net-update $2 add ip-dhcp-host \
          "<host mac='$3' \
           ip='$4' />" \
           --live --config
        ;;

  #8
  enable_ip_forwarding)
        uvt-kvm ssh $2 "sudo  chmod 777 /etc/sysctl.conf"
        uvt-kvm ssh $2 "sudo echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf"
       	uvt-kvm ssh $2 "sudo /etc/init.d/procps restart"
        ;;
  #9

  delete_bridge)
        sudo ifconfig $2 down
        sudo brctl delbr $2
        sudo virsh net-destroy $2
        sudo virsh net-undefine $2
        sudo rm $2.xml
        ;;
  #10
  disable_cloud-inits_network_configuration_capabilities)
	uvt-kvm ssh $2 "sudo chmod 777 /etc/netplan/50-cloud-init.yaml"
	uvt-kvm ssh $2 "sudo echo '.disable' >> /etc/netplan/50-cloud-init.yaml"
	uvt-kvm ssh $2 "sudo touch /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"
	uvt-kvm ssh $2 "sudo chmod 777 /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"
	uvt-kvm ssh $2 "sudo echo network: {config: disabled}  >> /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"
	uvt-kvm ssh $2 "sudo reboot"
	;;
  #11
  add_route)
	uvt-kvm ssh $2 "sudo echo up ip route add $3 via $4 >> /etc/network/interfaces"
	;;

  #12
  add_route_weight)
	uvt-kvm ssh $2 "echo up ip route add $3 \
	nexthop via $4 dev ens$5 weight $6 \
	nexthop via $7 dev ens$8 weight $9 >> /etc/network/interfaces"
	;;
  #13
  quagga)

	 echo " "
#	 uvt-kvm ssh $2  sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove
	 uvt-kvm ssh $2 "sudo apt-get update"
	 echo " "
         uvt-kvm ssh $2 "sudo apt-get install --assume-yes quagga"
	 echo " "
         uvt-kvm ssh $2  sudo apt-get install quagga-doc
	 uvt-kvm ssh $2  sudo chmod 777 /etc/sysctl.conf
         uvt-kvm ssh $2  echo "net.ipv4.ip_forward=1 >> /etc/sysctl.conf"

         uvt-kvm ssh $2 sudo touch /etc/quagga/vtysh.conf
         uvt-kvm ssh $2 sudo touch /etc/quagga/zebra.conf
         uvt-kvm ssh $2 sudo touch /etc/quagga/ospfd.conf
         uvt-kvm ssh $2 sudo touch /etc/quagga/daemons

	 uvt-kvm ssh $2  sudo cp /usr/share/doc/quagga-core/examples/vtysh.conf.sample /etc/quagga/vtysh.conf
#         uvt-kvm ssh $2  sudo cp /usr/share/doc/quagga-core/examples/zebra.conf.sample /etc/quagga/zebra.conf

         uvt-kvm ssh $2  sudo chown quagga:quagga /etc/quagga/ospfd.conf
         uvt-kvm ssh $2  sudo chown quagga:quagga /etc/quagga/zebra.conf
         uvt-kvm ssh $2  sudo chown quagga:quagga /etc/quagga/vtysh.conf

         uvt-kvm ssh $2  sudo chown quagga:quaggavty /etc/quagga/vtysh.conf
         uvt-kvm ssh $2  sudo chmod 777 /etc/quagga/ospfd.conf
         uvt-kvm ssh $2  sudo chmod 777 /etc/quagga/zebra.conf
         uvt-kvm ssh $2  sudo chmod 640 /etc/quagga/vtysh.conf
         uvt-kvm ssh $2  sudo chmod 777 /etc/quagga/daemons
         uvt-kvm ssh $2  sudo chmod 777 /etc/environment
         uvt-kvm ssh $2  sudo chmod 777 /etc/bash.bashrc

	uvt-kvm ssh $2 sudo printf "'
	zebra=yes
	bgpd=no
	ospfd=yes
	ospf6d=no
	ripd=no
	ripngd=no	'>> /etc/quagga/daemons"


uvt-kvm ssh $2 "echo 'YSH_PAGER=more' >> /etc/environment"
uvt-kvm ssh $2 "echo 'export VTYSH_PAGER=more' >> /etc/bash.bashrc"
uvt-kvm ssh $2 sudo printf "'
interface ens3
interface ens7
interface ens8
interface lo
router ospf
 passive-interface ens3
 network $3/24 area 0.0.0.0
 network $4/24 area 0.0.0.0
 line vty '>> /etc/quagga/ospfd.conf"

uvt-kvm ssh $2 "sudo printf   '
interface ens7
 ip address $5/24
 ipv6 nd suppress-ra
interface ens8
 ip address $6/24
 ipv6 nd suppress-ra
interface lo
ip forwarding
line vty ' >>  /etc/quagga/zebra.conf"

      uvt-kvm ssh $2  "sudo service zebra start"
      uvt-kvm ssh $2  "sudo service ospfd start"
;;
esac

