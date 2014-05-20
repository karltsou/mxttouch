
#! /bin/bash

# atmel mxt-app wrapper
#
# karl.tsou@atmel.com

MXTSYSFS="/sys/bus/i2c/drivers/atmel_mxt_ts"
ADDRESS="004a"
LOCAL_BIN="/usr/local/bin"

function mxt-install()
{
	echo "mxt-app: install mxt-app"
	if [ ! -d $LOCAL_BIN ] ; then
	  sudo mkdir -p $LOCAL_BIN
	fi

	sudo cp mxt-app $LOCAL_BIN
}

function mxt-rev()
{
	echo "mxt-app: silicon revision"
	
	IFS=' '
	t6_array=( $(mxt-app -d i2c-dev:${bus}-${address} -R -T6) )

	for ((i=0; i<=6; i++))
	do
	  byte[$i]=${t6_array[$i]}
	done

	# print T6 byte array
	#for ((i=0; i<=6; i++))
	#do
	#  echo 0x${byte[$i]}
	#done

	# T6 object config byte 5 = 128 (0x80) for reading revision from T37
	byte[5]="80"

	# T6 object re-config
	mxt-app -d i2c-dev:${bus}-${address} -W -T6 ${byte[0]}${byte[1]}${byte[2]}${byte[3]}${byte[4]}${byte[5]}${byte[6]}

	IFS=' '
	t37_array=( $(mxt-app -d i2c-dev:${bus}-${address} -R -T37) )

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

if [ -d $MXTSYSFS ] ; then
	echo "mxt-app: sysfs create"

	if [ -e $MXTSYSFS/enable ] ; then
	    echo "mxt-app: sysfs was enabled"
	else
	    echo "mxt-app: sysfs was disabled"
	fi

	IFS='-'
	array=( $(ls $MXTSYSFS | grep $ADDRESS) )
	bus=${array[0]}
	address=${array[1]}
	
	#echo "mxt-app i2c ${bus}-${address}"

	if [ -e "/dev/i2c-${bus}" ] ; then
	    echo "mxt-app: use i2c-${bus} as an interface"
	    sudo chown chronos /dev/i2c-${bus}
	else
	    echo "mxt-app: cannot find i2c-${bus}"
	    exit 1
	fi

	if [ ! -e $LOCAL_BIN/mxt-app ] ; then
	  mxt-install
	  sudo chmod 777     $LOCAL_BIN/mxt-app
	  sudo chown chronos $LOCAL_BIN/mxt-app
	  sudo chgrp chronos $LOCAL_BIN/mxt-app
	fi
else
	echo "mxt-app: sysfs doesn't exist"
fi
