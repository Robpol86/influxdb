# InfluxDB, Chronograf, Kapacitor, Raspberry Pi

> This repository is currently a work in progress.

This is the [docker-compose](https://docs.docker.com/compose/) stack I use for my home network's monitoring. It contains
the following containers:

* [InfluxDB](https://docs.influxdata.com/influxdb/) to store all of the metrics (the central piece of the setup).
* [Chronograf](https://docs.influxdata.com/chronograf/) to show pretty graphs (like [Grafana](http://grafana.org/)).
* [Kapacitor](https://docs.influxdata.com/kapacitor/) to email alerts when things break.
* [Raspberry Pi](https://robpol86.com/raspberry_pi_project_fi.html) or other Linux system for external monitoring.

I also use the following services:

* [SparkPost](https://www.sparkpost.com/pricing/) free tier for sending alerts emails.
* [Tor](https://www.torproject.org/) for our external Linux system to get around NAT/Firewalls.

There's more information and instructions available on
[this repo's wiki](https://github.com/Robpol86/influxdb/wiki). I've documented everything I need to get up and running
on my server in case I ever need to replace it from scratch.
