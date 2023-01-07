# extra-ram-swap
Add extra ram linux and windows

# Automatic install

# Manual install
```sudo swapon --show```<br />
```free -h```<br />

```sudo fallocate -l 1G /swapfile```<br />
```sudo chmod 600 /swapfile```<br />
```sudo mkswap /swapfile```<br />
```sudo swapon /swapfile```<br />
```sudo cp /etc/fstab /etc/fstab.bak```<br />
```echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab```<br />
```sudo nano /etc/sysctl.conf```<br />
add (vm.swappiness=10)<br />
```sudo nano /etc/sysctl.conf```<br />
add (vm.vfs_cache_pressure=50)<br />
```sudo reboot```<br />

```sudo swapon --show```<br />
```free -h```<br />

