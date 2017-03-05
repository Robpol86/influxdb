# InfluxDB

> This repository is currently a work in progress.

## Pre-requisites

Before we get started you'll need to have a Linux system setup with docker-compose. This guide was written with Fedora
Server 25 in mind but any system that can run docker-compose should work fine.

You can just run `sudo dnf install docker-engine docker-compose`, however that won't get you the "real" Docker and it
won't be the latest.

On Fedora you can run the following commands for the latest Docker:

```bash
sudo dnf -y remove docker docker-common container-selinux docker-selinux
sudo dnf config-manager --add-repo https://docs.docker.com/engine/installation/linux/repo_files/fedora/docker.repo
sudo dnf makecache fast
sudo dnf install docker-engine
sudo systemctl start docker
sudo systemctl enable docker.service
sudo docker run hello-world
```

And for the latest Docker Compose:
```bash
version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest |jq --raw-output .name)
url="https://github.com/docker/compose/releases/download/$version/docker-compose-$(uname -s)-$(uname -m)"
sudo curl -L $url -o /usr/local/bin/docker-compose; sudo chmod +x $_
```
