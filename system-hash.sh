#!/bin/bash

date=`date --iso`
hash_path="/root"

# Check the hash folder exists or not
if [ -d $hash_path ]
then
	:
else
	mkdir -p $hash_path
fi

function do_the_hash() {

# We should check if we already have the hash file or not
if [ -e $hash_path/system-hash* ]
then
	echo "Hash file exists. Please use --check instead."
else
	# Super user should run this script
	id=`id -u`
	if [ $id -eq 0 ]
	then
		echo "# System UUID" > $hash_path/system-hash-check
		dmidecode -t 1 | grep UUID | awk '{print $2}' >> $hash_path/system-hash-check
		echo "# Base Board Serial" >> $hash_path/system-hash-check
		dmidecode -t 2 | grep Serial | awk '{print $3}' >> $hash_path/system-hash-check
		echo "# CPU ID" >> $hash_path/system-hash-check
		dmidecode -t 4 | grep ID | sed 's/.*ID://;s/ //g' >> $hash_path/system-hash-check
		echo "# eth0 MAC" >> $hash_path/system-hash-check
		ifconfig | grep eth0 | awk '{print $NF}' | sed 's/://g' >> $hash_path/system-hash-check
		echo "# / File System UUID" >> $hash_path/system-hash-check
		blkid | grep "$(df -h / | sed -n 2p | cut -d" " -f1):" | grep -o "UUID=\"[^\"]*\" " | sed "s/UUID=\"//;s/\"//" >> $hash_path/system-hash-check
		md5sum $hash_path/system-hash-check | awk '{print $1}' > $hash_path/system-hash.hash
	else
		echo "Error! You are not root user."
		exit 0
	fi
fi
}

# --check function goes here
function check_the_hash() {

	echo "# System UUID" > /tmp/system-hash-check
        dmidecode -t 1 | grep UUID | awk '{print $2}' >> /tmp/system-hash-check
        echo "# Base Board Serial" >> /tmp/system-hash-check
        dmidecode -t 2 | grep Serial | awk '{print $3}' >> /tmp/system-hash-check
        echo "# CPU ID" >> /tmp/system-hash-check
        dmidecode -t 4 | grep ID | sed 's/.*ID://;s/ //g' >> /tmp/system-hash-check
        echo  "# eth0 MAC" >> /tmp/system-hash-check
        ifconfig | grep eth0 | awk '{print $NF}' | sed 's/://g' >> /tmp/system-hash-check
        echo "# / File System UUID" >> /tmp/system-hash-check
        blkid | grep "$(df -h / | sed -n 2p | cut -d" " -f1):" | grep -o "UUID=\"[^\"]*\" " | sed "s/UUID=\"//;s/\"//" >> /tmp/system-hash-check
	# Generating the temp MD%
	md5sum /tmp/system-hash-check | awk '{print $1}' >> /tmp/system-hash-temp.hash

	tmp_md5sum=`cat /tmp/system-hash-temp.hash`
	original_md5sum=`cat $hash_path/system-hash.hash`

	echo ""
	echo -e "Current Hash: \t" $tmp_md5sum
	echo -e "Original Hash: \t" $original_md5sum
	echo ""

	# Compairing the hashes
	if [ "$tmp_md5sum" == "$original_md5sum" ]
	then
		echo "----------------------"
		echo "System integrity is ok"
		echo "----------------------"
		echo ""
	else
		echo "-------------------------------------"
		echo "Integrity failed. System was modified"
		echo "-------------------------------------"
		echo ""
	fi

	rm /tmp/system-hash*
}

case $1 in
	"--gen" )
		do_the_hash;;
	"--check" )
		check_the_hash;;
	*)
		echo "Use --gen or --check";;
esac
