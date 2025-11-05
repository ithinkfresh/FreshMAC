#!/bin/bash

# Find the Wi-Fi interface (usually en0 or en1)
wifi_interface=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')

if [ -z "$wifi_interface" ]; then
  echo "Wi-Fi interface not found."
  exit 1
fi

echo "Wi-Fi interface detected: $wifi_interface"

# Prompt user for the new MAC address
read -p "Enter the MAC address to spoof (format xx:xx:xx:xx:xx:xx): " new_mac

# Validate MAC address format (simple regex)
if [[ ! "$new_mac" =~ ^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$ ]]; then
  echo "Invalid MAC address format."
  exit 1
fi

echo "Disconnecting Wi-Fi..."
sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -z

echo "Changing MAC address to $new_mac..."
sudo ifconfig $wifi_interface ether $new_mac

if [ $? -ne 0 ]; then
  echo "Failed to change MAC address."
  exit 1
fi

echo "New MAC address set. Verifying..."

current_mac=$(ifconfig $wifi_interface | awk '/ether/{print $2}')

echo "Current MAC address on $wifi_interface: $current_mac"
echo "Done. Reconnect to your Wi-Fi network manually."

