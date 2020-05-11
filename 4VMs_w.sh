#!/bin/bash

#4 VMs und 2 Wege:
#4VMs mit 4 bridges: VM1->VM2, VM1->VM3, VM2->VM4, VM3->VM4

VM1_2_MAC=08:00:00:00:00:12
VM1_3_MAC=08:00:00:00:00:13
VM2_1_MAC=08:00:00:00:00:21
VM2_4_MAC=08:00:00:00:00:24
VM3_1_MAC=08:00:00:00:00:31
VM3_4_MAC=08:00:00:00:00:34
VM4_2_MAC=08:00:00:00:00:42
VM4_3_MAC=08:00:00:00:00:43

                        #interface
VM1_2_IP=10.10.10.12    #7
VM1_3_IP=10.10.20.13    #8
VM2_1_IP=10.10.10.21    #7
VM2_4_IP=10.10.30.24    #8
VM3_1_IP=10.10.20.31    #7
VM3_4_IP=10.10.40.34    #8
VM4_2_IP=10.10.30.42    #7
VM4_3_IP=10.10.40.43    #8

MAC=($VM1_2_MAC $VM1_3_MAC $VM2_1_MAC $VM2_4_MAC $VM3_1_MAC $VM3_4_MAC $VM4_2_MAC $VM4_3_MAC)
IP=($VM1_2_IP $VM1_3_IP $VM2_1_IP $VM2_4_IP $VM3_1_IP $VM3_4_IP $VM4_2_IP $VM4_3_IP)
BRIDGE=(br-1 br-2 br-1 br-3 br-2 br-4 br-3 br-4)

bridge=(br-1 br-2 br-3 br-4)


case $1 in

start)

#       create 4 VMs
./basis-script.sh create_VM VM1
uvt-kvm wait VM1 --insecure
./basis-script.sh create_VM_interface VM1 7

./basis-script.sh create_VM VM2
uvt-kvm wait VM2 --insecure
./basis-script.sh create_VM_interface VM2 7
./basis-script.sh create_VM_interface VM2 8

./basis-script.sh create_VM VM3
uvt-kvm wait VM3 --insecure
./basis-script.sh create_VM_interface VM3 7
./basis-script.sh create_VM_interface VM3 8


./basis-script.sh create_VM VM4
uvt-kvm wait VM4 --insecure
./basis-script.sh create_VM_interface VM4 7

#       enable ip forwarding
./basis-script.sh enable_ip_forwarding VM2
./basis-script.sh enable_ip_forwarding VM3

#       create bridge between 1. and 2. VM
./basis-script.sh create_bridge br-1 10.10.10.1 255.255.255.0 10.10.10.10 10.10.10.80

#       create bridge between 1. and 3. VM
./basis-script.sh create_bridge br-2 10.10.20.1 255.255.255.0 10.10.20.10 10.10.20.80

#       create bridge between 2. and 4. VM
./basis-script.sh create_bridge br-3 10.10.30.1 255.255.255.0 10.10.30.10 10.10.30.80

#       create bridge between 3. and 4. VM
./basis-script.sh create_bridge br-4 10.10.40.1 255.255.255.0 10.10.40.10 10.10.40.80
