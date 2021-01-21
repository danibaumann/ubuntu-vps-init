#!/bin/bash

echo Please tell me some details for this setup.
read -p 'docker-compose Version: (e.g. "1.27.4") ' dcversion
read -p 'new SSH Port: ' sshport
read -p 'Username: ' username
read -sp 'Password: ' passwd
echo

adduser ${username} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "${username}:${passwd}" | sudo chpasswd
usermod -aG sudo ${username}
echo "Finished creating a new user"

echo "will update ssh config"
sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i -e '/^PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i -e '/^#MaxAuthTries/s/^.*$/MaxAuthTries 2/' /etc/ssh/sshd_config
sed -i -e '/^#MaxAuthTries/s/^.*$/MaxAuthTries 2/' /etc/ssh/sshd_config
sed -i -e '$aAllowUsers '${username}'' /etc/ssh/sshd_config
sed -i -e '/^#Port/s/^.*$/Port '${sshport}'/' /etc/ssh/sshd_config
## if the config has an alternativ port
sed -i -e '/^Port/s/^.*$/Port '${sshport}'/' /etc/ssh/sshd_config
systemctl restart sshd
echo "finished updating and restarting ssh"

apt update && apt upgrade -y
echo "finished upgrading the server"

apt install docker.io -y
systemctl enable docker
echo "installed docker.io"

usermod -aG docker ${username}
echo "added ${username} to docker group"

curl -sL "https://github.com/docker/compose/releases/download/${dcversion}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo "installed docker-compose"

ufw allow $sshport

## Adjust to your provate subnet
sudo ufw allow from 10.114.0.0/20 to any port 22,2376,2377,7946 proto tcp
sudo ufw allow from 10.114.0.0/20 to any port 7946,4789 proto udp

echo "y" | sudo ufw enable
echo "enabled ufw and allowed ${sshport}"

mkdir /home/${username}/.ssh
cp /root/.ssh/authorized_keys /home/${username}/.ssh/authorized_keys
chown -R ${username}:${username} /home/${username}/.ssh
echo "added authorized keys to ${username}"

echo "will reboot"
reboot