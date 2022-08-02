#!/bin/bash

echo Please tell me some details for this setup.
read -p 'docker-compose Version: (e.g. "2.9.0) ' dcversion
read -p 'new SSH Port: ' sshport
read -p 'Username: ' username
read -sp 'Password: ' passwd
echo
read -p 'Do you want to enable Docker Swarm? (y/n): ' -n 1 swarmMode
echo
if [[ $swarmMode =~ ^[Yy]$ ]]
then
  read -p 'Please enter your private network of your docker nodes. e.g. 10.114.0.0/20: ' dockerSubnet
fi
# read -p ''

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
## if the config already has an alternativ port
sed -i -e '/^Port/s/^.*$/Port '${sshport}'/' /etc/ssh/sshd_config
systemctl restart sshd
echo "finished updating and restarting ssh"

apt -qq update && apt -qq upgrade -y
echo "finished upgrading the server"


apt remove docker docker-engine docker.io containerd runc
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update -y
apt install docker-ce -y
systemctl enable docker
echo "installed docker.io"

usermod -aG docker ${username}
echo "added ${username} to docker group"

mdkir -p /home/${username}/.docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v${dcversion}/docker-compose-linux-x86_64 -o /home/${username}/.docker/cli-plugins/docker-compose
chmod +x /home/${username}/.docker/cli-plugins/docker-compose
chown -R ${username}:${username} /home/${username}/.docker
echo "installed docker-compose"

ufw allow $sshport

## Adjust to your provate subnet
if [[ $swarmMode =~ ^[Yy]$ ]]
then
sudo ufw allow from ${dockerSubnet} to any port 22,2376,2377,7946 proto tcp
sudo ufw allow from ${dockerSubnet} to any port 7946,4789 proto udp
fi

echo "y" | sudo ufw enable
echo "enabled ufw and allowed ${sshport}"

mkdir /home/${username}/.ssh
cp /${USER}/.ssh/authorized_keys /home/${username}/.ssh/authorized_keys
chown -R ${username}:${username} /home/${username}/.ssh
echo "added authorized keys from ${USER} to ${username}"

echo "Please consider rebooting the system and connect to ssh via port ${sshport} and username ${username}"
