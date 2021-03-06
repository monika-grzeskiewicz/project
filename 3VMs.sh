#!/bin/bash
VM1_MAC=08:00:00:00:00:01
VM2_1_MAC=08:00:00:00:00:12
VM2_3_MAC=08:00:00:00:00:32
VM3_MAC=08:00:00:00:00:03

VM1_IP=10.10.10.11
VM2_1_IP=10.10.10.12
VM2_3_IP=10.10.20.12
VM3_IP=10.10.20.13

case $1 in

start)

#create 1. VM and interface
./basis-script.sh create_VM VM1
sleep 30
#uvt-kvm wait
./basis-script.sh create_VM_interface VM1 7

#create 2. VM (router) and interfaces
./basis-script.sh create_VM VM2
sleep 30
#uvt-kvm wait
./basis-script.sh create_VM_interface VM2 7
./basis-script.sh create_VM_interface VM2 8

#enable ip forwarding
./basis-script.sh enable_ip_forwarding VM2

#create 3. VM and interface
./basis-script.sh create_VM VM3 7
sleep 30
./basis-script.sh create_VM_interface VM3 7

#create bridge between 1. and 2. VM
./basis-script.sh create_bridge br-1 10.10.10.1 255.255.255.0 10.10.10.10 10.10.10.80

#create bridge between 2. and 3. VM
./basis-script.sh create_bridge br-2 10.10.20.1 255.255.255.0 10.10.20.10 10.10.20.80

#add a dhcp static host entry to the network
./basis-script.sh add_a_dhcp_static_host_entry_to_the_network br-1 ${VM1_MAC} ${VM1_IP}
./basis-script.sh add_a_dhcp_static_host_entry_to_the_network br-1 ${VM2_1_MAC} ${VM2_1_IP}
./basis-script.sh add_a_dhcp_static_host_entry_to_the_network br-2 ${VM2_3_MAC} ${VM2_3_IP}
./basis-script.sh add_a_dhcp_static_host_entry_to_the_network br-2 ${VM3_MAC} ${VM3_IP}

#attach interfaces to bridges
./basis-script.sh attach_interface_to_the_bridge VM1 br-1 ${VM1_MAC}
./basis-script.sh attach_interface_to_the_bridge VM2 br-1 ${VM2_1_MAC}
./basis-script.sh attach_interface_to_the_bridge VM2 br-2 ${VM2_3_MAC}
./basis-script.sh attach_interface_to_the_bridge VM3 br-2 ${VM3_MAC}

#add routes
./basis-script.sh add_route VM1 7 10.10.20.0 255.255.255.0 ${VM2_1_IP}
./basis-script.sh add_route VM3 7 10.10.10.0 255.255.255.0 ${VM2_3_IP}

#disable  cloud-init's network configuration capabilities
./basis-script.sh disable_cloud-inits_network_configuration_capabilities VM1
./basis-script.sh disable_cloud-inits_network_configuration_capabilities VM2
./basis-script.sh disable_cloud-inits_network_configuration_capabilities VM3

;;
stop)

./basis-script.sh destroy_VM VM1
./basis-script.sh destroy_VM VM2
./basis-script.sh destroy_VM VM3
./basis-script.sh delete_bridge br-1
./basis-script.sh delete_bridge br-2
;;

esac
