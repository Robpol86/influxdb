# InfluxDB, Chronograf, Kapacitor, Raspberry Pi

> This repository is currently a work in progress.

This is the [docker-compose](https://docs.docker.com/compose/) stack I use for my home network's monitoring. It contains
the following containers:
* [InfluxDB](https://docs.influxdata.com/influxdb/) to store all of the metrics (the central piece of the setup).
* [Chronograf](https://docs.influxdata.com/chronograf/) to show pretty graphs (like [Grafana](http://grafana.org/)).
* [Kapacitor](https://docs.influxdata.com/kapacitor/) to email alerts when things break.
* [Raspberry Pi](https://robpol86.com/raspberry_pi_project_fi.html) or other Linux system for external monitoring.

We'll also be using the following services:
* [SparkPost](https://www.sparkpost.com/pricing/) free tier for sending alerts emails.
* [Tor](https://www.torproject.org/) for our external Linux system to get around NAT/Firewalls.

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

## Installation & Configuration

Clone this repo locally (or fork it and clone that repo) to your Docker host. I put mine in `/opt/influxdb`:
```bash
sudo mkdir /opt/influxdb
sudo git clone https://github.com/Robpol86/influxdb.git /opt/influxdb
```

Next you'll probably want to glance over the various configuration files in this repo. They work for me but you may
have a slightly different setup. Look at configs such as [docker-compose.yml](docker-compose.yml).

Once you're done you can start everything up:
```bash
cd /opt/influxdb; sudo docker-compose up -d
```
