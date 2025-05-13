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

if [ ! -f /etc/fstab.bak ]; then
    cp /etc/fstab /etc/fstab.bak
    chmod 644 /etc/fstab.bak
fi
if [ ! -f /etc/sysctl.conf.bak ]; then
    cp /etc/sysctl.conf /etc/sysctl.conf.bak
    chmod 644 /etc/sysctl.conf.bak
fi

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
        [[ "$swap_size" =~ ^[0-9]+$ ]] && [ "$swap_size" -ge 250 ] && [ "$swap_size" -le 9000 ] && break
        echo "Invalid size. Please try again."
    done

    while true; do
        echo "Default is 60, press ENTER to skip changing"
        read -e -i 60 -p "Enter new swappiness value (1-100): " swappiness
        [[ "$swappiness" =~ ^[0-9]+$ ]] && [ "$swappiness" -ge 1 ] && [ "$swappiness" -le 100 ] && break
        echo "Invalid value."
    done

    while true; do
        echo "Default is 100, press ENTER to skip changing"
        read -e -i 100 -p "Enter new vfs_cache_pressure value (1-200): " vfs_cache_pressure
        [[ "$vfs_cache_pressure" =~ ^[0-9]+$ ]] && [ "$vfs_cache_pressure" -ge 1 ] && [ "$vfs_cache_pressure" -le 200 ] && break
        echo "Invalid value."
    done

    if ! fallocate -l ${swap_size}M /swapfile; then
        echo "fallocate failed, using dd..."
        dd if=/dev/zero of=/swapfile bs=1M count=${swap_size}
    fi

    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo -e "vm.swappiness=$swappiness\nvm.vfs_cache_pressure=$vfs_cache_pressure" >> /etc/sysctl.conf
    sysctl vm.swappiness=$swappiness
    sysctl vm.vfs_cache_pressure=$vfs_cache_pressure
    sysctl -p

    echo "SWAP has been enabled."
    pause
    ;;
  2)
    clear
    echo "You chose: Update SWAP"

    if ! swapon --summary | grep -q '^/'; then
        echo "No active swap found. Script stopped."
        pause
        continue
    fi

    while true; do
        echo "If you want to set to 3GB enter 3000"
        read -p "Enter new swap size in Mb (250-9000): " swap_size
        [[ "$swap_size" =~ ^[0-9]+$ ]] && [ "$swap_size" -ge 250 ] && [ "$swap_size" -le 9000 ] && break
        echo "Invalid size. Please try again."
    done

    while true; do
        echo "Default is 60, press ENTER to skip changing"
        read -e -i 60 -p "Enter new swappiness value (1-100): " swappiness
        [[ "$swappiness" =~ ^[0-9]+$ ]] && [ "$swappiness" -ge 1 ] && [ "$swappiness" -le 100 ] && break
        echo "Invalid value."
    done

    while true; do
        echo "Default is 100, press ENTER to skip changing"
        read -e -i 100 -p "Enter new vfs_cache_pressure value (1-200): " vfs_cache_pressure
        [[ "$vfs_cache_pressure" =~ ^[0-9]+$ ]] && [ "$vfs_cache_pressure" -ge 1 ] && [ "$vfs_cache_pressure" -le 200 ] && break
        echo "Invalid value."
    done

    swapoff /swapfile

    if ! fallocate -l ${swap_size}M /swapfile; then
        echo "fallocate failed, using dd..."
        dd if=/dev/zero of=/swapfile bs=1M count=${swap_size}
    fi

    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab

    sed -i '/^vm.swappiness/d' /etc/sysctl.conf
    sed -i '/^vm.vfs_cache_pressure/d' /etc/sysctl.conf
    echo "vm.swappiness=$swappiness" >> /etc/sysctl.conf
    echo "vm.vfs_cache_pressure=$vfs_cache_pressure" >> /etc/sysctl.conf
    sysctl -p

    echo "Swap successfully updated."
    pause
    ;;
  3)
    clear
    echo "You chose: Disable SWAP"

    if swapon --summary | grep -q '^/swapfile'; then
        echo "Disabling swap..."
        swapoff /swapfile
    else
        echo "Swapfile is not active or not found."
        pause
        continue
    fi

    if [ -f /swapfile ]; then
        echo "Removing swap file..."
        rm -f /swapfile
    fi

    if grep -q '/swapfile' /etc/fstab; then
        echo "Removing entry from /etc/fstab..."
        sed -i '/\/swapfile/d' /etc/fstab
    fi

    if [ -f /etc/sysctl.conf.bak ]; then
        echo "Restoring sysctl configuration..."
        cp /etc/sysctl.conf.bak /etc/sysctl.conf
        chmod 644 /etc/sysctl.conf
        sysctl -p
    fi

    echo "Swap disabled."
    pause
    ;;
  0)
    echo "Exiting program."
    exit 0
    ;;
  *)
    echo "Unknown choice."
    pause
    ;;
esac
done
