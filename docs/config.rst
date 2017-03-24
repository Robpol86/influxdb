.. _config:

=====================
Initial Configuration
=====================

Now that the Docker Compose containers are running I need to do some initial configuration such as create users and
databases in the Docker containers.

InfluxDB
========

1. Run the influx CLI in the container: ``sudo docker exec -it influxdb influx``
2. Then create users and databases (substitute ``robpol86``, etc):

.. code-block:: sql

    CREATE USER robpol86 WITH PASSWORD 'REPLACE_ME' WITH ALL PRIVILEGES
    AUTH
    CREATE DATABASE telegraf
    CREATE USER telegraf_filesrv WITH PASSWORD 'REPLACE_ME'
    GRANT ALL TO telegraf_filesrv
    CREATE USER telegraf_raspberrypi WITH PASSWORD 'REPLACE_ME'
    GRANT ALL TO telegraf_raspberrypi
    CREATE USER grafana WITH PASSWORD 'REPLACE_ME'
    GRANT READ ON telegraf TO grafana

.. note::

    **TODO**: Use ``GRANT WRITE ON telegraf TO telegraf_filesrv`` once
    https://github.com/influxdata/telegraf/issues/2496 is fixed.

Grafana
=======

1. Browse to https://filesrv.rob86.net:3000/profile (your Docker host's hostname).
2. Login with admin/admin.
3. Change the password, put your real email, and set any other settings desired.
4. Browse to https://filesrv.rob86.net:3000/org and set name to "Home".
5. Browse to https://filesrv.rob86.net:3000/datasources/new and set:

  * Name: **telegraf**; Default: **✓**; Type: **InfluxDB**
  * Url: **http://influxdb:8086**; Access: **proxy**
  * Database: **telegraf**; User: **grafana**; Password: **REPLACE_ME**

.. describe:: .secrets/grafana.ini

    Go to SparkPost and create a new API key with permissions **Send via SMTP** and **Templates: Read-only**. Then edit
    this file with the following contents (replace ``$API_KEY``, no need for quotes):

    .. code-block:: ini

        [smtp]
        password = $API_KEY

    Then restart the container:

    .. code-block:: bash

        sudo docker restart grafana

PiMon
=====

.. describe:: .secrets/pimon

    Create an SSH key pair to be used to SSH into the Raspberry Pi from the PiMon docker container:

    .. code-block:: bash

        sudo ssh-keygen -t rsa -b 4096 -C "$HOSTNAME" -N "" -f .secrets/pimon
