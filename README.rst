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

Documentation
=============

`Visit the documentation <https://robpol86.github.io/influxdb>`_ for instructions on how to use this repository for your
own metrics/graphing setup at home. I've documented everything I need to get up and running on my server in case I ever
need to replace it from scratch.

Quick Start
===========

.. clone-section-start

Clone this repo locally (or fork it and clone that repo) to your Docker host (I put mine in ``/opt/influxdb``):

.. code-block:: bash

    sudo mkdir /opt/influxdb; cd $_
    sudo git clone https://github.com/Robpol86/influxdb.git .

Next you'll want to glance over the various configuration files in this repo. They work for me but you may have a
different setup. Start with `docker-compose.yml <https://github.com/Robpol86/influxdb/blob/master/docker-compose.yml>`_
and look at other configuration files in this repository.

.. clone-section-end
.. up-section-start

Once everything in docker-compose.yml looks good go ahead and start the containers:

.. code-block:: bash

    cd /opt/influxdb; sudo docker-compose up -d
    sudo firewall-cmd --permanent --add-port=8086/tcp
    sudo firewall-cmd --permanent --add-port=3000/tcp
    sudo systemctl restart firewalld.service

Verify everything works by running ``sudo docker ps``. You should see "influxdb" and "grafana" in the NAMES column.

.. up-section-end
