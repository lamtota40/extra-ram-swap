#!/bin/bash

sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo bash -c "echo -e 'vm.swappiness=10\nvm.vfs_cache_pressure=50' >> /etc/sysctl.conf"
sudo sysctl vm.swappiness=10
sudo sysctl vm.vfs_cache_pressure=50

echo "Make swap ram Finished"
