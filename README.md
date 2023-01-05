# extra-ram-swap
Add extra ram linux and windows

sudo swapon --show
free -h

sudo fallocate -l 1G /swapfile
ls -lh /swapfile (-rw-r--r--)
sudo chmod 600 /swapfile
ls -lh /swapfile (-rw-------)
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
# cat /proc/sys/vm/swappiness (output 60)
sudo sysctl vm.swappiness=10
sudo nano /etc/sysctl.conf
# add (vm.swappiness=10)
# cat /proc/sys/vm/vfs_cache_pressure (output 100)
sudo sysctl vm.vfs_cache_pressure=50
sudo nano /etc/sysctl.conf
# add (vm.vfs_cache_pressure=50)

sudo swapon --show
free -h
