#!/bin/bash

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Silakan jalankan script ini sebagai root atau dengan sudo."
  exit 1
fi

# Fungsi pause
pause() {
  read -p "Tekan Enter untuk kembali ke menu..."
}

# Fungsi menampilkan info swap dan RAM
tampilkan_info() {
  raminfo=$(free -m | grep Mem)
  swapinfo=$(free -m | grep Swap)
  ram_usage=$(( $(awk '{print $2}' <<< "$raminfo") - $(awk '{print $7}' <<< "$raminfo") ))
  ram_total=$(awk '{print $2}' <<< "$raminfo")
  swap_usage=$(awk '{print $3}' <<< "$swapinfo")
  swap_total=$(awk '{print $2}' <<< "$swapinfo")
  if [ "$swap_total" -eq 0 ]; then
    swap_percent=0
    swap_status="Disable"
  else
    swap_percent=$((swap_usage * 100 / swap_total))
    swap_status="Enable"
  fi
}

# Menu utama
while true; do
clear
tampilkan_info
echo "========================================"
echo "             MENU SWAP RAM"
echo "========================================"
echo "STATUS SWAP : $swap_status"
echo "SWAP RAM    : Usage = ${swap_usage} Mb (${swap_percent}%) | Total = ${swap_total} Mb"
echo "RAM         : Usage = ${ram_usage} Mb ($((ram_usage * 100 / ram_total))%) | Total = ${ram_total} Mb"
echo ""
echo "1. Enable SWAP"
echo "2. Update SWAP"
echo "3. Disable SWAP"
echo "0. Exit Program"
echo "========================================"
read -p "Masukan input Angka pilihanmu : " pilihan

case $pilihan in
  1)
    clear
    echo "Kamu memilih: Enable SWAP"

    if swapon --summary | grep -q '^/'; then
        echo "Status SWAP saat ini ENABLE. Silakan pilih UPDATE atau DISABLE."
        pause
        continue
    fi

    while true; do
        read -p "Masukkan ukuran swap baru dalam Mb (250-9000): " swap_size
        [[ "$swap_size" =~ ^[0-9]+$ ]] && [ "$swap_size" -ge 250 ] && [ "$swap_size" -le 9000 ] && break
        echo "Ukuran tidak valid. Silakan coba lagi."
    done

    while true; do
        read -e -i 60 -p "Masukkan nilai swappiness baru (1-100): " swappiness
        [[ "$swappiness" =~ ^[0-9]+$ ]] && [ "$swappiness" -ge 1 ] && [ "$swappiness" -le 100 ] && break
        echo "Nilai tidak valid."
    done

    while true; do
        read -e -i 100 -p "Masukkan nilai vfs_cache_pressure baru (1-1000): " vfs_cache_pressure
        [[ "$vfs_cache_pressure" =~ ^[0-9]+$ ]] && [ "$vfs_cache_pressure" -ge 1 ] && [ "$vfs_cache_pressure" -le 1000 ] && break
        echo "Nilai tidak valid."
    done

    if ! fallocate -l ${swap_size}M /swapfile; then
        echo "fallocate gagal, menggunakan dd..."
        dd if=/dev/zero of=/swapfile bs=1M count=${swap_size}
    fi

    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    cp /etc/fstab /etc/fstab.bak
    cp /etc/sysctl.conf /etc/sysctl.conf.bak
    chmod 644 /etc/sysctl.conf.bak

    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo -e "vm.swappiness=$swappiness\nvm.vfs_cache_pressure=$vfs_cache_pressure" >> /etc/sysctl.conf
    sysctl vm.swappiness=$swappiness
    sysctl vm.vfs_cache_pressure=$vfs_cache_pressure
    sysctl -p

    echo "SWAP telah diaktifkan."
    pause
    ;;
  2)
    clear
    echo "Kamu memilih: Update SWAP"

    if !
