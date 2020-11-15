sudo iptables -I INPUT -s 18.200.1.21/32 -j DROP
sudo iptables -I INPUT -s 54.154.165.163/32 -j DROP
sudo iptables -I INPUT -s 63.32.207.43/32 -j DROP
sudo iptables -I INPUT -s 54.187.241.135/32 -j DROP
sudo iptables -I INPUT -s 63.32.147.35/32 -j DROP
sudo iptables -I INPUT -s 52.37.61.85/32 -j DROP
sudo iptables -L INPUT -v
