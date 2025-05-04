#!/bin/bash

# Mengecek apakah swap aktif
if ! swapon --summary | grep -q '^/'; then
    echo "Tidak ada swap yang aktif. Skrip dihentikan."
    exit 0
fi

# Meminta input dari pengguna untuk ukuran swap
while true; do
    read -p "Masukkan ukuran swap baru dalam Mb (misalnya 3000 untuk 3GB): " swap_size
    if [[ "$swap_size" =~ ^[0-9]+$ ]] && [ "$swap_size" -ge 250 ] && [ "$swap_size" -le 9000 ]; then
        break
    else
        echo "Ukuran swap harus berupa angka antara 250 dan 9000. Silakan coba lagi."
    fi
done

while true; do
    read -e -i 60 -p "Masukkan nilai swappiness baru (1-100;default:60): " swappiness
    if [[ "$swappiness" =~ ^[0-9]+$ ]] && [ "$swappiness" -ge 1 ] && [ "$swappiness" -le 100 ]; then
        break
    else
        echo "Nilai swappiness harus berupa angka antara 1 dan 100. Silakan coba lagi."
    fi
done

while true; do
    read -e -i 100 -p "Masukkan nilai vfs_cache_pressure baru (1-1000;default:100): " vfs_cache_pressure
    if [[ "$vfs_cache_pressure" =~ ^[0-9]+$ ]] && [ "$vfs_cache_pressure" -ge 1 ] && [ "$vfs_cache_pressure" -le 1000 ]; then
        break
    else
        echo "Nilai vfs_cache_pressure harus berupa angka antara 1 dan 1000. Silakan coba lagi."
    fi
done

# Mematikan swap yang ada
sudo swapoff /swapfile

# Mengubah ukuran swap
sudo fallocate -l ${swap_size}M /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Memperbarui /etc/fstab jika perlu
if ! grep -q '/swapfile' /etc/fstab; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# Memperbarui sysctl.conf
sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
sudo sed -i "/^vm.swappiness/d" /etc/sysctl.conf
sudo sed -i "/^vm.vfs_cache_pressure/d" /etc/sysctl.conf
echo "vm.swappiness=$swappiness" | sudo tee -a /etc/sysctl.conf
echo "vm.vfs_cache_pressure=$vfs_cache_pressure" | sudo tee -a /etc/sysctl.conf

# Menerapkan pengaturan baru
sudo sysctl -p

echo "Swap, swappiness, dan vfs_cache_pressure telah diperbarui."
