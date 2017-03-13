# InfluxDB, Grafana, Kapacitor, Raspberry Pi

> This repository is currently a work in progress.

This is the [docker-compose](https://docs.docker.com/compose/) stack I use for my home network's monitoring. It contains
the following containers:

* [InfluxDB](https://docs.influxdata.com/influxdb/) to store all of the metrics (the central piece of the setup).
* [Grafana](http://grafana.org/) to show pretty graphs of all the metrics
* [Kapacitor](https://docs.influxdata.com/kapacitor/) to email alerts when things break.
* [Raspberry Pi](https://robpol86.com/raspberry_pi_project_fi.html) or other Linux system for external monitoring.

I also use the following services:

* [SparkPost](https://www.sparkpost.com/pricing/) free tier for sending alerts emails.
* [Tor](https://www.torproject.org/) for our external Linux system to get around NAT/Firewalls.

## Instructions

[Visit the documentation](https://robpol86.github.io/influxdb) for instructions on how to use this repository for your
own metrics/graphing setup at home. I've documented everything I need to get up and running on my server in case I ever
need to replace it from scratch.
