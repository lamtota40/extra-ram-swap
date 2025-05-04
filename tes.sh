ram_usage=$(($(awk '{print $2}' <<< "$raminfo") - $(awk '{print $4}' <<< "$raminfo")))
ram_total=$(awk '{print $2}' <<< "$raminfo")
swap_usage=$(awk '{print $3}' <<< "$swapinfo")
swap_total=$(awk '{print $2}' <<< "$swapinfo")
if [ "$swap_usage" -eq "0" ]; then
swap_percent="0";
else
swap_percent=$(($swap_usage * 100 / $swap_total));
fi
echo -e "RAM       :Usage = "$ram_usage" Mb ($(($ram_usage * 100 / $ram_total))%) | Total = "$ram_total" Mb"
echo -e "SWAP RAM  :Usage = "$swap_usage" Mb ("$swap_percent"%) | Total = "$swap_total" Mb"
