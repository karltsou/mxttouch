#!/bin/bash

# atmel mxt-app wrapper
#
# karl.tsou@atmel.com

MXTSYSFS="/sys/bus/i2c/drivers/atmel_mxt_ts"
ADDRESS="004b"
NOW=$(date +"%S%M%H%d%b%Y")

# pin fault test
function mxt-pinfault()
{
echo "mxt-app: running test pin fault"

IFS=' '
t25_array=( $(mxt-app -d i2c-dev:${bus}-${address} -R -T25) )

for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14
do
  byte[$i]=${t25_array[$i]}
done

# dump t25 configuration
#for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14
#do
#  echo 0x${byte[$i]}
#done

# hex format
signal=(96)
byte[0]="03"
byte[1]="12"
byte[14]=${signal[0]}

mxt-app -d i2c-dev:${bus}-${address} -W -T25 \
${byte[0]}${byte[1]}${byte[2]}${byte[3]}${byte[4]}${byte[5]}${byte[6]}${byte[7]}\
${byte[8]}${byte[9]}${byte[10]}${byte[11]}${byte[12]}${byte[13]}${byte[14]}

# test complete
IFS=' '
t5_array=( $(mxt-app -d i2c-dev:${bus}-${address} -R -T5) )

for i in 0 1 2 3 4 5 6 7 8 9
do
  echo 0x${t5_array[$i]}
done

result_code=${t5_array[1]}
result_seqnum=${t5_array[2]}
# echo "pin fault result - 0x${result}"

if [ "$result_code" == "FE" ] ; then
	echo "pin fault - pass"
elif [ "$result_code" == "12" ] ; then
	echo "pin fault - fail"
else
	echo "pin fault - unknow"
fi
}

# T2 die revision checked
function mxt-rev()
{
echo "mxt-app: die revision"
	
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

if [ "$rev" == "2" ] ; then
	echo "Rev C"
elif [ "$rev" == "3" ] ; then
	echo "Rev D"
else
	echo "Rev not found"
fi
}

# main routine
function mxt-main()
{
if [ -d $MXTSYSFS ] ; then
  echo "mxt-app: atmel_mxt_ts was created"

  IFS='-'
  array=( $(ls $MXTSYSFS | grep $ADDRESS) )
  bus=${array[0]}
  address=${array[1]}

  #echo "mxt-app i2c ${bus}-${address}"

  if [ -e "/dev/i2c-${bus}" ] ; then
    echo "mxt-app: use i2c-${bus} as an interface"
  else
    echo "mxt-app: cannot find i2c-${bus}"
  fi
else
  echo "mxt-app: atmel_mxt_ts doesn't exist"
fi
}

echo "mxt-app: shell start"
mxt-main
mxt-pinfault
