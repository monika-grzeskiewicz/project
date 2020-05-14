

for i in {0..9}
do

#i=$(( $i%3 ))

a=$(($i+1))
a=$(($a%2))

if [ $a -eq 0 ]
then
echo "o tu"
VM_nr=$(( $VM_nr + 1 ))
echo $VM_nr
echo "o tu koniec"

fi

done




