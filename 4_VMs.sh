#!/bin/bash

# VM1 -> VM2 -> VM3 -> VM4

VM1_MAC=08:00:00:00:00:01
VM2_1_MAC=08:00:00:00:00:21
VM2_3_MAC=08:00:00:00:00:23
VM3_2_MAC=08:00:00:00:00:32
VM3_4_MAC=08:00:00:00:00:34
VM4_MAC=08:00:00:00:00:04

			#interface
VM1_IP=10.10.10.01	#7
VM2_1_IP=10.10.10.21	#7
VM2_3_IP=10.10.20.23	#8
VM3_2_IP=10.10.20.32	#7
VM3_4_IP=10.10.30.34	#8
VM4_IP=10.10.30.43	#7

MAC=($VM1_MAC $VM2_1_MAC $VM2_3_MAC $VM3_2_MAC $VM3_4_MAC $VM4_MAC)
IP=($VM1_IP $VM2_1_IP $VM2_3_IP $VM3_2_IP $VM3_4_IP $VM4_IP)
BRIDGE=(br-1 br-1 br-2 br-2 br-3 br-3)

bridge=(br-1 br-2 br-3)



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

#       create bridge between 2. and 3. VM
./basis-script.sh create_bridge br-2 10.10.20.1 255.255.255.0 10.10.20.10 10.10.20.80

#       create bridge between 3. and 4. VM
./basis-script.sh create_bridge br-3 10.10.30.1 255.255.255.0 10.10.30.10 10.10.30.80


for i in {0..5}
do

./basis-script.sh add_a_dhcp_static_host_entry_to_the_network ${BRIDGE[i]} ${MAC[i]} ${IP[i]}

if [ $i -lt 1 ]
then
 VM_number=1
elif [ $i -lt 3 ]
then
 VM_number=2
elif [ ${i} -lt 5 ]
then
 VM_number=3
else
 VM_number=4
fi

./basis-script.sh attach_interface_to_the_bridge VM${VM_number} ${BRIDGE[i]} ${MAC[i]}

done

#       add routes
./basis-script.sh add_route VM1 7 10.10.30.0 255.255.255.0 ${VM2_1_IP}
./basis-script.sh add_route VM2 8 10.10.40.0 255.255.255.0 ${VM3_2_IP}
./basis-script.sh add_route VM4 7 10.10.10.0 255.255.255.0 ${VM3_4_IP}
./basis-script.sh add_route VM3 8 10.10.10.0 255.255.255.0 ${VM2_3_IP}

for i in {1..4}
do
./basis-script.sh disable_cloud-inits_network_configuration_capabilities VM${i}
done

;;

stop)

for i in {0..4}
do
if [ ${i} -lt 4 ]
then
a=$(( $i + 1 ))
./basis-script.sh destroy_VM VM${a}
fi
./basis-script.sh delete_bridge ${bridge[i]}
done


;;
esac



