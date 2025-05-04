#!/bin/bash

# Ambil informasi RAM dan SWAP
raminfo=$(free -m | grep Mem)
swapinfo=$(free -m | grep Swap)

# Hitung penggunaan RAM
ram_usage=$(( $(awk '{print $2}' <<< "$raminfo") - $(awk '{print $7}' <<< "$raminfo") ))
ram_total=$(awk '{print $2}' <<< "$raminfo")

# Hitung penggunaan SWAP
swap_usage=$(awk '{print $3}' <<< "$swapinfo")
swap_total=$(awk '{print $2}' <<< "$swapinfo")

# Hitung persentase SWAP
if [ "$swap_total" -eq 0 ]; then
    swap_percent=0
else
    swap_percent=$((swap_usage * 100 / swap_total))
fi

# Tentukan status SWAP (Enable/Disable)
if [ "$swap_total" -eq 0 ]; then
    swap_status="Disable"
else
    swap_status="Enable"
fi

# Tampilkan menu
clear
echo "========================================"
echo "             MENU SWAP RAM"
echo "========================================"
echo "Status    : $swap_status"
echo "Swap RAM  : Usage = ${swap_usage} Mb (${swap_percent}%) | Total = ${swap_total} Mb"
echo "RAM       : Usage = ${ram_usage} Mb ($((ram_usage * 100 / ram_total))%) | Total = ${ram_total} Mb"
echo ""
echo "1. Enable SWAP"
echo "2. Update SWAP"
echo "3. Disable SWAP"
echo "0. Exit Program
echo "========================================"
read -p "Masukan input Angka pilihanmu : " pilihan

case $pilihan in
    1)
        echo "Kamu memilih: Enable SWAP"
        ;;
    2)
        echo "Kamu memilih: Update SWAP"
        ;;
    3)
        echo "Kamu memilih: Disable SWAP"
        ;;
    *)
        echo "Pilihan tidak dikenal"
        ;;
esac
