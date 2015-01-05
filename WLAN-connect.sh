#!/bin/bash

#DEVICEID=$(echo -e "SELECT parent_id FROM resources WHERE value like '\0045$ROBOT\0045'" |psql dister_worker -t )
#DeviceIP=$(psql dister_worker -t -c "SELECT value FROM resources WHERE id='$DEVICEID'" |grep -o "192.168.[0-9].15")

#IP=$DeviceIP
IP=192.168.2.15
NAME="JollaGuest"
PASSPHRASE=Welcome\ Guest
SLEEP="sleep 10"
echo $IP
echo $NAME
echo $PASSPHRASE

# enable wifi
ssh root@$IP "/usr/lib/connman/tools/connmanctl enable wifi"
$SLEEP

# grep wlan ap
HASH=$(ssh root@$IP "/usr/lib/connman/tools/connmanctl services | grep $NAME")
#HASH=$(echo $HASH | sed 's/^ *//')
echo "HASH: $HASH"

# create config file in /tmp
# CONFIG=$(echo $HASH | sed 's/^ *//')
# CONFIG="$CONFIG.config"
# echo -ne "CONFIG: $CONFIG\n"

cat << EOF > /tmp/wifi_5056a8014dc6_4a6f6c6c614775657374_managed_psk
[wifi_5056a8014dc6_4a6f6c6c614775657374_managed_psk]
Name=$NAME
SSID=4a6f6c6c614775657374
Frequency=2472
Favorite=true
AutoConnect=true
IPv4.method=dhcp
IPv6.method=auto
IPv6.privacy=prefered
Passphrase=$PASSPHRASE
EOF

# create dir for JollaGuest settings
ssh root@$IP "mkdir -pv /var/lib/connman/wifi_5056a8014dc6_4a6f6c6c614775657374_managed_psk"
# copy config file to device
scp /tmp/wifi_5056a8014dc6_4a6f6c6c614775657374_managed_psk root@$IP:"/var/lib/connman/wifi_5056a8014dc6_4a6f6c6c614775657374_managed_psk/settings"
# remove temp config file
rm -f /tmp/wifi_5056a8014dc6_4a6f6c6c614775657374_managed_psk
