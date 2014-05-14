
#! /bin/bash

# atmel mxt-app wrapper
#
# karl.tsou@atmel.com

MXTSYSFS="/sys/bus/i2c/drivers/atmel_mxt_ts"
ADDRESS="004a"

function mxt-rev()
{
	echo "mxt-app: silicon revision"
	
	IFS=' '
	t6_array=( $(mxt-app -R -T6) )

	for i in 0 1 2 3 4 5 6 
	do
	  byte[$i]=${t6_array[$i]}
	done
	
	# print T6 byte array
	#for i in 0 1 2 3 4 5 6 
	#do
	#  echo 0x${byte[$i]}
	#done

	# T6 object config byte 5 = 128 (0x80) for reading revision from T37 
	byte[5]="80"

	# T6 object re-config 
	mxt-app -W -T6 ${byte[0]}${byte[1]}${byte[2]}${byte[3]}${byte[4]}${byte[5]}${byte[6]}

	# T37
	IFS=' '
	t37_array=( $(mxt-app -R -T37) )
	
	# T37 dump first two bytes are length and page
	# Therefore fist byte zero start from byte 2
	# For instant byte 19 = 19 + 2 = 21
	hexval=${t37_array[21]}
	decval=$( echo $((16#${hexval})) )
	# echo "Decimal T37[19] " = $decval

	rev=$( echo $((decval >> 4)) )
	# echo $rev

	if [  $rev = "2" ]
	then
		echo "Rev C"
	elif [ $rev = "3" ]
	then
		echo "Rev D"
	else
		echo "Rev not found"
	fi
}

echo "mxt-app: shell"
mxt-rev
