#!/bin/bash
case $1 in
  1)    #create VM#
        uvt-kvm create $2 release=bionic
        ;;

  2)    #destroy VM#
        uvt-kvm destroy  $2 
        ;;

  3)    #create bridge
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

  4)    #VM interface
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

        else
        uvt-kvm ssh $2 "sudo echo auto ens$3 >> /etc/network/interfaces"
        uvt-kvm ssh $2 "sudo echo iface ens$3 inet dhcp >> /etc/network/interfaces"
        fi

	sudo service networking restart
        ;;

  5)    #attach interface to the bridge
        sudo virsh attach-interface --domain $2 --type network --source $3 --model virtio --mac $4 --config --live
        ;;

  6)    #detach -interface
        sudo virsh detach-interface --domain $2 --type network --mac $3 --config
        ;;

  7)    #add a dhcp static host entry to the network
        virsh net-update $2 add ip-dhcp-host \
          "<host mac='$3' \
           ip='$4' />" \
           --live --config
        ;;

  8)    #enable ip forwarding
        uvt-kvm ssh $2 "sudo  chmod 777 /etc/sysctl.conf"
        uvt-kvm ssh $2 "sudo echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf"
       	uvt-kvm ssh $2 "sudo /etc/init.d/procps restart"
        ;;

  9)    #delete bridge
        sudo ifconfig $2 down
        sudo brctl delbr $2
        sudo virsh net-destroy $2
        sudo virsh net-undefine $2
        sudo rm $2.xml
        ;;

  10)	#disable cloud-init's network configuration capabilities
	uvt-kvm ssh $2 "sudo touch /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"
	uvt-kvm ssh $2 "sudo chmod 777 /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"
	uvt-kvm ssh $2 "sudo echo network: {config: disabled}  >> /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"
	;;
esac
