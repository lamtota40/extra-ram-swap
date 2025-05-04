#!/bin/bash

# Menonaktifkan swap
if swapon --summary | grep -q '^/swapfile'; then
    echo "Menonaktifkan swap..."
    sudo swapoff /swapfile
fi

# Menghapus file swap
if [ -f /swapfile ]; then
    echo "Menghapus file swap..."
    sudo rm -f /swapfile
fi

# Menghapus entri swapfile dari /etc/fstab
if grep -q '/swapfile' /etc/fstab; then
    echo "Menghapus entri /swapfile dari /etc/fstab..."
    sudo sed -i '/\/swapfile/d' /etc/fstab
fi

# Mengembalikan sysctl.conf dari backup
if [ -f /etc/sysctl.conf.bak ]; then
    echo "Mengembalikan sysctl.conf dari backup..."
    sudo cp /etc/sysctl.conf.bak /etc/sysctl.conf
    sudo sysctl -p
else
    echo "Backup sysctl.conf tidak ditemukan. Tidak ada perubahan pada pengaturan sysctl."
fi

echo "Swap telah dinonaktifkan dan sistem dikembalikan seperti semula."
