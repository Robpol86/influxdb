==========================================
InfluxDB, Grafana, Kapacitor, Raspberry Pi
==========================================

.. image:: https://img.shields.io/travis/Robpol86/influxdb/master.svg?style=flat-square&label=Travis%20CI
    :target: https://travis-ci.org/Robpol86/influxdb
    :alt: Build Status

.. summary-section-start

This is the `docker-compose <https://docs.docker.com/compose>`_ stack I use for my home network's monitoring. It
contains the following containers:

* `InfluxDB <https://docs.influxdata.com/influxdb>`_ to store all of the metrics (the central piece of the setup).
* `Grafana <http://grafana.org>`_ to show pretty graphs of all the metrics
* `Kapacitor <https://docs.influxdata.com/kapacitor>`_ to email alerts when things break.
* `Raspberry Pi <https://robpol86.com/raspberry_pi_project_fi.html>`_ or other Linux system for external monitoring.

I also use the following services:

* `SparkPost <https://www.sparkpost.com/pricing>`_ free tier for sending alerts emails.
* `Tor <https://www.torproject.org>`_ for our external Linux system to get around NAT/Firewalls.

.. summary-section-end

`Visit the documentation <https://robpol86.github.io/influxdb>`_ for instructions on how to use this repository for your
own metrics/graphing setup at home. I've documented everything I need to get up and running on my server in case I ever
need to replace it from scratch.
