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

### Install Latest Docker and Compose

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
url="https://github.com/docker/compose/releases/download/$version/docker-compose-Linux-$(uname -m)"
sudo curl -L $url -o /usr/local/bin/docker-compose; sudo chmod +x $_
```

You'll also want to create directories for bind-mounts used by the Docker Compose containers. I ran:

```bash
sudo mkdir /storage/Local/influxdb
```

Lastly I ran into a race condition with NetworkManager during boot on my system. It seems like Docker tried to start my
containers before DHCP has finished running and erroring out. I was getting this error:
`Failed to start container 06551c8e77474b48a137ae7b1ad7b13a4416d0e17d: open /etc/resolv.conf: no such file or directory`

I fixed this by:

1. Running `sudo systemctl edit --full docker.service`
2. Adding `Wants=network-online.target` to the Unit section.
3. Replacing `network.target` with `network-online.target` in the Unit.After setting.

### SSL Certificate

Since we're configuring InfluxDB with SSL certificates it is expected that you already place your SSL certs in `/etc` on
the Docker host:

1. Cat your SSL private key and certificate and place it in: `/etc/HOSTNAME.DOMAIN.net.pem`
2. Make sure it's `chmod 0400` and `chown root:root`.

## Installation

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
sudo firewall-cmd --permanent --add-port=8086/tcp
sudo systemctl restart firewalld.service
```

## Initial Configuration

If you've just created the bind-mount directories you'll need to do some initial configuration of InfluxDB and friends.

### InfluxDB

1. Run the influx CLI in the container: `sudo docker exec -it influxdb influx -ssl -unsafeSsl`
2. Then create users and databases (substitute `robpol86`, etc):

```sql
CREATE USER robpol86 WITH PASSWORD 'REPLACE_ME' WITH ALL PRIVILEGES
AUTH
CREATE DATABASE telegraf
CREATE USER telegraf_filesrv WITH PASSWORD 'REPLACE_ME'
GRANT WRITE ON telegraf TO telegraf_filesrv
```

## Telegraf on Docker Host

To get some data in InfluxDB we'll install Telegraf to collect metrics from the Docker host itself. It'll need to run
outside Docker in order to collect all available metrics.

```bash
sudo dnf install https://dl.influxdata.com/telegraf/releases/telegraf-1.2.1.x86_64.rpm
f=cpu:disk:diskio:dns_query:docker:hddtemp:ipmi_sensor:mem:net:netstat:ping:processes:swap:system
telegraf -sample-config -input-filter $f -output-filter influxdb |sudo tee /etc/telegraf/telegraf.conf
sudo chown telegraf /etc/telegraf/telegraf.conf
sudo chmod 640 /etc/telegraf/telegraf.conf
```

Then make changes to the configuration file as you see fit. You can compare your changes against my 
[telegraf.conf](etc/telegraf.conf) file. Then test your changes by seeing what Telegraf will be transmitting. Run
`sudo telegraf -test` and make sure it exits 0.
