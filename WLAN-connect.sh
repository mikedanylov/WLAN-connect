#!/bin/bash

IP=$DeviceIP
NAME="WLAN_NAME"
PASSPHRASE="WLAN_PASS"
SLEEP="sleep 10"
echo $IP
echo $NAME
echo $PASSPHRASE

# enable wifi
ssh root@$IP "/usr/lib/connman/tools/connmanctl enable wifi"
$SLEEP

# grep wlan ap
HASH=$(ssh root@$IP "/usr/lib/connman/tools/connmanctl services | grep $NAME")
HASH=$(echo $HASH | sed 's/^ *//')
echo "HASH: $HASH"

IFS=' ' read -ra ARRAY <<< "$HASH"
HASH="${ARRAY[1]}"
echo "HASH: $HASH"

cat << EOF > /tmp/"$HASH"
[$HASH]
Name=$NAME
SSID=4a6f6c6c614775657374 # shouldn't be hardcoded but extracted from $HASH
Frequency=2472
Favorite=true
AutoConnect=true
IPv4.method=dhcp
IPv6.method=auto
IPv6.privacy=prefered
Passphrase=$PASSPHRASE
EOF
cat /tmp/"$HASH"

# create dir for JollaGuest settings
ssh root@$IP "mkdir -pv /var/lib/connman/\"$HASH\""
# copy config file to device
scp /tmp/"$HASH" root@$IP:"/var/lib/connman/\"$HASH\"/settings"
ssh root@$IP "chmod -R 700 /var/lib/connman/\"$HASH\""
# remove temp config file
rm -f /tmp/"$HASH"

# RESTART WLAN
# disable wifi
ssh root@$IP "/usr/lib/connman/tools/connmanctl disable wifi"
$SLEEP
# enable wifi
ssh root@$IP "/usr/lib/connman/tools/connmanctl enable wifi"
$SLEEP