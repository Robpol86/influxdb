.. _install:

==========================
Installing this Repository
==========================

To get started with this Docker Compose configuration in this repository we need to give it a home on the server. I just 
clone this repo somewhere on the server and run ``sudo docker-compose up -d``. Docker will auto-start the containers on 
boot afterwards (based on the ``restart: always`` setting in the yaml file).

Since I installed docker-compose using ``curl`` instead of ``dnf`` into ``/usr/local`` I needed to update my sudoers
file since it doesn't include that directory in the ``PATH`` environment variable. I fixed that with:

1. ``sudo visudo``
2. Append ``:/usr/local/bin:/usr/local/sbin`` to the ``Defaults secure_path`` line.

Clone
=====

Clone this repo locally (or fork it and clone that repo) to your Docker host. I put mine in ``/opt/influxdb``:

.. code-block:: bash

    sudo mkdir /opt/influxdb
    sudo git clone https://github.com/Robpol86/influxdb.git /opt/influxdb

Next you'll probably want to glance over the various configuration files in this repo. They work for me but you may have 
a slightly different setup. Look at configs such as 
`docker-compose.yml <https://github.com/Robpol86/influxdb/blob/master/docker-compose.yml>`_.

Start Containers
================

Once everything in docker-compose.yml looks good go ahead and start the containers:

.. code-block:: bash

    cd /opt/influxdb; sudo docker-compose up -d
    sudo firewall-cmd --permanent --add-port=8086/tcp
    sudo firewall-cmd --permanent --add-port=3000/tcp
    sudo systemctl restart firewalld.service

Verify everything works by running ``sudo docker ps``. You should see "influxdb" and "grafana" in the NAMES column.
