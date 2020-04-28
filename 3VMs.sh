#!/bin/bash

VM1_MAC=08:00:00:00:00:01
VM2_1_MAC=08:00:00:00:00:12
VM2_3_MAC=08:00:00:00:00:32
VM3_MAC=08:00:00:00:00:03

VM1_IP=10.10.10.11
VM2_1_IP=10.10.10.12
VM2_3_IP=10.10.20.12
VM3_IP=10.10.20.13

#create 1. VM and interface
./basis-script.sh 1 VM1
sleep 30
./basis-script.sh 4 VM1 7

#create 2. VM (router) and interfaces
./basis-script.sh 1 VM2
sleep 30
./basis-script.sh 4 VM2 7
./basis-script.sh 4 VM2 8

#enable ip forwarding
./basis-script.sh 8 VM2

#create 3. VM and interface
./basis-script.sh 1 VM3 7
sleep 30
./basis-script.sh 4 VM3 7

#create bridge between 1. and 2. VM
./basis-script.sh 3 br-1 10.10.10.1 255.255.255.0 10.10.10.10 10.10.10.80

#create bridge between 2. and 3. VM
./basis-script.sh 3 br-2 10.10.20.1 255.255.255.0 10.10.20.10 10.10.20.80

#add a dhcp static host entry to the network
./basis-script.sh 7 br-1 ${VM1_MAC} ${VM1_IP}
./basis-script.sh 7 br-1 ${VM2_1_MAC} ${VM2_1_IP}
./basis-script.sh 7 br-2 ${VM2_3_MAC} ${VM2_3_IP}
./basis-script.sh 7 br-2 ${VM3_MAC} ${VM3_IP}

#attach interfaces to bridges
./basis-script.sh 5 VM1 br-1 ${VM1_MAC}
./basis-script.sh 5 VM2 br-1 ${VM2_1_MAC}
./basis-script.sh 5 VM2 br-2 ${VM2_3_MAC}
./basis-script.sh 5 VM3 br-2 ${VM3_MAC}

