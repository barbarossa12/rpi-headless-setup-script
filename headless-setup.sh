#!/bin/bash
: '
Bash script to generate the wpa supplicant file and
a user for the raspberry pi when setting up in headless mode.
'

# wifi configuration section
# get the ssid, do not permit an empty ssid
while true; do
    read -p "Enter the SSID: " SSID

    if [[ -z "$SSID" ]]; then
        echo "SSID cannot be empty"
    else
        break
    fi
done

# get the wifi-password
# do not permit an empty password
while true; do
    read -sp "Enter the WiFi password: " WIFI_PASSWORD
    echo
    if [[ -z "$WIFI_PASSWORD" ]]; then
        echo "WiFi password cannot be empty"
    else
        break
    fi
done

# get the country code
# do not permit an empty country code
while true; do
    read -p "Enter the country code: " COUNTRY

    if [[ -z "$COUNTRY" ]]; then
        echo "conutry code cannot be empty"
    else
        break
    fi
done

cat <<EOF > ./wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=$COUNTRY

network={
    scan_ssid=1
    ssid="$SSID"
    psk="$WIFI_PASSWORD"
    key_mgmt=WPA-PSK
}
EOF

echo "LOG: wpa_supplicant configuration created for SSID: $SSID"


# user creation section
while true; do
    read -p "Enter the username: " USERNAME

    if [[ -z "$USERNAME" ]]; then
        echo "$USERNAME cannot be empty"
    else
        break
    fi
done

while true; do
    read -sp "Enter the password: " PASSWORD
    echo
    if [[ -z "$PASSWORD" ]]; then
        echo "$PASSWORD cannot be empty"
    else
        break
    fi
done

PASSWORD_HASH=$(echo "$PASSWORD" | openssl passwd -6 -stdin)

if [[ -z "$PASSWORD_HASH" ]]; then
    echo "ERROR: Failed to generate hashed password."
    exit 1
fi

USERCONF_FILE="$USERNAME:$PASSWORD_HASH"
echo $USERCONF_FILE > userconf

echo "LOG: userconf file created for user: $USERNAME"
echo "LOG: put wpa_supplicant file and user conf in /boot of sdcard"

