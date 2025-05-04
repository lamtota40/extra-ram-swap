#!/bin/bash

echo "==================================="
echo "how many add swap RAM ?"
echo "example if input 2 Gb input "2000" Mb"
read -p "input (Mb):" size
     until [[ -z "$size" || "$size" =~ ^[0-9]$ ]]; do
	echo "$size: invalid input."
	read -p "input (Mb):" size
     done

sudo fallocate -l $size /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo bash -c "echo -e 'vm.swappiness=60\nvm.vfs_cache_pressure=100' >> /etc/sysctl.conf"
sudo sysctl vm.swappiness=60
sudo sysctl vm.vfs_cache_pressure=100

echo "Make swap ram Finished"
