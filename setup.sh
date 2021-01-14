#!/bin/bash

echo Tell me the username for the user I should create.
read -p 'Username: ' username
read -sp 'Password: ' passwd
echo

adduser username --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "username:passwd" | sudo chpasswd
usermod -aG sudo username
echo "Finished creating a new user"

echo "will update ssh config"
sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i -e '/^PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i -e '/^#MaxAuthTries/s/^.*$/MaxAuthTries 2/' /etc/ssh/sshd_config
sed -i -e '/^#MaxAuthTries/s/^.*$/MaxAuthTries 2/' /etc/ssh/sshd_config
sed -i -e '$aAllowUsers username' /etc/ssh/sshd_config
sed -i -e '/^#Port/s/^.*$/Port 777/' /etc/ssh/sshd_config
systemctl restart sshd
echo "finished updating and restarting ssh"

apt update && apt upgrade -y
echo "finished upgrading the server"

apt install docker.io -y
echo "installed docker.io"

usermod -aG docker username
echo "added username to docker group"

curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo "installed docker-compose"

ufw allow 777
ufw enable -y
echo "enabled ufw and allowed 777"

mkdir /home/username/.ssh
cp /root/.ssh/authorized_keys /home/username/.ssh/authorized_keys
chown -R username:username /home/username/.ssh
echo "added authorized keys to username"

echo "will reboot"
reboot