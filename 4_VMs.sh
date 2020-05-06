#!/bin/bash

# VM1 -> VM2 -> VM3 -> VM4



VM1_MAC=08:00:00:00:00:01
VM2_1_MAC=08:00:00:00:00:21
VM2_3_MAC=08:00:00:00:00:23
VM3_2_MAC=08:00:00:00:00:32
VM3_4_MAC=08:00:00:00:00:34
VM4_MAC=08:00:00:00:00:04

VM1_IP=10.10.10.01
VM2_1_IP=10.10.10.21
VM2_3_IP=10.10.20.23
VM3_2_IP=10.10.20.32
VM3_4_IP=10.10.30.34
VM4_IP=10.10.30.43

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



