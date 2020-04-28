#!/bin/bash

VM1_MAC=08:00:00:00:00:01
VM2_MAC=08:00:00:00:00:02
VM1_IP=10.10.80.11
VM2_IP=10.10.80.12

#create 1. VM and interface
./basis-script.sh 1 VM1
sleep 30
./basis-script.sh 4 VM1

#create 2. VM and interface
./basis-script.sh 1 VM2
sleep 30
./basis-script.sh 4 VM2 

#create bridge
./basis-script.sh 3 br-1 10.10.80.1 255.255.255.0 10.10.80.10 10.10.80.80

#add a dhcp static host entry to the network
./basis-script.sh 7 br-1 ${VM1_MAC} ${VM1_IP}
./basis-script.sh 7 br-1 ${VM2_MAC} ${VM2_IP}

#add interfaces to the bridge
./basis-script.sh 5 VM1 br-1 ${VM1_MAC}
./basis-script.sh 5 VM2 br-1 ${VM2_MAC}
