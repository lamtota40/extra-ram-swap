#!/bin/bash

# Make sure to run as root
if (( $EUID != 0 )); then
    echo "Please run as root"
    echo "You can Try command 'su root' or 'sudo -i' or 'sudo -'"
    exit 1
fi

# Pause function
pause() {
  read -p "Press Enter to return to the menu..."
}

# Function to display swap and RAM info
display_info() {
  raminfo=$(free -m | grep Mem)
  swapinfo=$(free -m | grep Swap)
  ram_usage=$(( $(awk '{print $2}' <<< "$raminfo") - $(awk '{print $7}' <<< "$raminfo") ))
  ram_total=$(awk '{print $2}' <<< "$raminfo")
  swap_usage=$(awk '{print $3}' <<< "$swapinfo")
  swap_total=$(awk '{print $2}' <<< "$swapinfo")
  if [ "$swap_total" -eq 0 ]; then
    swap_percent=0
    swap_status="DISABLE"
  else
    swap_percent=$((swap_usage * 100 / swap_total))
    swap_status="ENABLE"
  fi
}

# Main menu
while true; do
clear
display_info
echo "===================================================="
echo "             SWAP RAM MENU"
echo "===================================================="
echo "SWAP STATUS : $swap_status"
echo "SWAP RAM    : Usage = ${swap_usage} Mb (${swap_percent}%) | Total = ${swap_total} Mb"
echo "RAM         : Usage = ${ram_usage} Mb ($((ram_usage * 100 / ram_total))%) | Total = ${ram_total} Mb"
echo ""
echo "1. Enable SWAP"
echo "2. Update SWAP"
echo "3. Disable SWAP"
echo "0. Exit Program"
echo "===================================================="
read -p "Enter your choice number: " choice

case $choice in
  1)
    clear
    echo "You chose: Enable SWAP"

    if swapon --summary | grep -q '^/'; then
        echo "SWAP is already ENABLED. Please choose UPDATE or DISABLE."
        pause
        continue
    fi

    while true; do
        echo "If you want to set to 3GB enter 3000"
        read -p "Enter new SWAP size in Mb (250-9000): " swap_size
