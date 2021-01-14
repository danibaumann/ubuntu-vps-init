# Ubuntu initializer for DigitalOcean or Hetzner VPS

## Details

This small script does the following tasks:

- adds a new sudo user to your VM
- updates your system with the latest packages
- installs docker.io
- installs docker-compose
- changes the ssh port to the one you select
- adds the port to the ufw firewall
- enables the uf firewall
- add your user to the ssh config as allowed user
- reboots the machine

## Guide

Just run the following commands after you connected the as root via ssh key

```
curl -L "https://raw.githubusercontent.com/danibaumann/ubuntu-vps-init/main/setup.sh" -o setup.sh
sudo chmod +x setup.sh
sudo ./setup.sh
```

You will get prompted for the docker-compose version, a username, password and a new SSH Port

## License

MIT License

Copyright &copy; 2021 - Baumann Solutions https://basol.ch
