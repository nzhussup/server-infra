sudo /usr/local/bin/k3s-uninstall.sh

sudo reboot

sudo ufw reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default allow routed
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable

sudo ufw status verbose

curl -sfL https://get.k3s.io | sh -s - \
  --disable traefik

