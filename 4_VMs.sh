#!/bin/bash

# VM1 -> VM2 -> VM3 -> VM4


case $1 in

start)

#       create 4 VMs
./basis-script.sh create_VM VM1
sleep 30
./basis-script.sh create_VM_interface VM1 7

./basis-script.sh create_VM VM2
#uvt-kvm wait VM2
sleep 30
./basis-script.sh create_VM_interface VM2 7
./basis-script.sh create_VM_interface VM2 8

./basis-script.sh create_VM VM3
#uvt-kvm wait VM3
sleep 30
./basis-script.sh create_VM_interface VM3 7
./basis-script.sh create_VM_interface VM3 8

./basis-script.sh create_VM VM4
sleep 30
#uvt-kvm wait VM4
./basis-script.sh create_VM_interface VM4 7

#       enable ip forwarding
./basis-script.sh enable_ip_forwarding VM2
./basis-script.sh enable_ip_forwarding VM3

;;

stop)

;;
esac



