#!/bin/bash

# VM1 -> VM2 -> VM4
# VM2 -> VM3 -> VM4
# VM4 -> VM3 -> VM1
# VM3 -> VM2 -> VM1

VM1_2_MAC=08:00:00:00:00:12	#br1_2	0
VM1_3_MAC=08:00:00:00:00:13	#br1_3	1
VM2_1_MAC=08:00:00:00:00:21	#br1_2	2
VM2_3_MAC=08:00:00:00:00:23	#br2_3	3
VM2_4_MAC=08:00:00:00:00:24	#br2_4	4
VM3_1_MAC=08:00:00:00:00:31	#br1_3	5
VM3_2_MAC=08:00:00:00:00:32	#br2_3	6
VM3_4_MAC=08:00:00:00:00:34	#br3_4	7
VM4_2_MAC=08:00:00:00:00:42	#br2_4	8
VM4_3_MAC=08:00:00:00:00:43	#br3_4	9

VM1_2_IP=10.10.10.12
VM1_3_IP=10.10.20.13
VM2_1_IP=10.10.10.21
VM2_3_IP=10.10.30.23
VM2_4_IP=10.10.40.24
VM3_1_IP=10.10.20.25
VM3_2_IP=10.10.30.32
VM3_4_IP=10.10.50.34
VM4_2_IP=10.10.40.42
VM4_3_IP=10.10.50.43

MAC=($VM1_2_MAC $VM1_3_MAC $VM2_1_MAC $VM2_3_MAC $VM2_4_MAC $VM3_1_MAC $VM3_2_MAC $VM3_4_MAC $VM4_2_MAC $VM4_3_MAC)
IP=($VM1_2_IP $VM1_3_IP $VM2_1_IP $VM2_3_IP $VM2_4_IP $VM3_1_IP $VM3_2_IP $VM3_4_IP $VM4_2_IP $VM4_3_IP)
BRIDGE=(br-1_2 br-1_3 br-1_2 br-2_3 br-2_4 br-1_3 br-2_3 br-3_4 br-2_4 br-3_4)

bridge=(br-1_2 br-1_3 br-2_3 br-2_4 br-3_4)

case $1 in

start)

#	create 4 VMs
./basis-script.sh create_VM VM1
sleep 30
./basis-script.sh create_VM_interface VM1 7
./basis-script.sh create_VM_interface VM1 8

./basis-script.sh create_VM VM2
#uvt-kvm wait VM2
sleep 30
./basis-script.sh create_VM_interface VM2 7
./basis-script.sh create_VM_interface VM2 8
./basis-script.sh create_VM_interface VM1 9

./basis-script.sh create_VM VM3
#uvt-kvm wait VM3
sleep 30
./basis-script.sh create_VM_interface VM3 7
./basis-script.sh create_VM_interface VM3 8
./basis-script.sh create_VM_interface VM1 9

./basis-script.sh create_VM VM4
sleep 30
#uvt-kvm wait VM4
./basis-script.sh create_VM_interface VM4 7
./basis-script.sh create_VM_interface VM1 8

#	enable ip forwarding
./basis-script.sh enable_ip_forwarding VM2
./basis-script.sh enable_ip_forwarding VM3

#	create bridge between 1. and 2. VM
./basis-script.sh create_bridge br-1_2 10.10.10.1 255.255.255.0 10.10.10.10 10.10.10.80

#	create bridge between 1. and 3. VM
./basis-script.sh create_bridge br-1_3 10.10.20.1 255.255.255.0 10.10.20.10 10.10.20.80

#       create bridge between 2. and 3. VM
./basis-script.sh create_bridge br-2_3 10.10.30.1 255.255.255.0 10.10.30.10 10.10.30.80

#       create bridge between 2. and 4. VM
./basis-script.sh create_bridge br-2_4 10.10.40.1 255.255.255.0 10.10.40.10 10.10.40.80

#       create bridge between 3. and 4. VM
./basis-script.sh create_bridge br-3_4 10.10.50.1 255.255.255.0 10.10.50.10 10.10.50.80


for i in {0..9}
do
./basis-script.sh add_a_dhcp_static_host_entry_to_the_network ${BRIDGE[i]} ${MAC[i]} ${IP[i]}

if [ $i -lt 2 ]
then
 VM_number=1
elif [ $i -lt 5 ]
then
 VM_number=2
elif [ ${i} -lt 8 ]
then
 VM_number=3
else
 VM_number=4
fi
./basis-script.sh attach_interface_to_the_bridge VM${VM_number} ${BRIDGE[i]} ${MAC[i]}
done

#add routes
#./basis-script.sh add_route VM1 7 10.10.20.0 255.255.255.0 ${VM2_1_IP}
#./basis-script.sh add_route VM3 7 10.10.10.0 255.255.255.0 ${VM2_3_Is

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
a=i+1
./basis-script.sh destroy_VM VM${a}
fi
./basis-script.sh delete_bridge ${bridge[i]}
done
;;

esac
