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
    CREATE USER telegraf_nmc WITH PASSWORD 'REPLACE_ME'
    GRANT ALL TO telegraf_nmc
    CREATE USER telegraf_filesrv WITH PASSWORD 'REPLACE_ME'
    GRANT ALL TO telegraf_filesrv
    CREATE USER telegraf_bosco WITH PASSWORD 'REPLACE_ME'
    GRANT WRITE ON telegraf TO telegraf_bosco
    CREATE USER grafana WITH PASSWORD 'REPLACE_ME'
    GRANT READ ON telegraf TO grafana

.. note::

    **TODO**: Use ``GRANT WRITE ON telegraf TO telegraf_filesrv`` once
    https://github.com/influxdata/telegraf/issues/2496 is fixed.

Grafana
=======

.. image:: _static/grafana_email.png
    :target: _images/grafana_email.png

.. describe:: .secrets/grafana.ini

    Go to SparkPost and create a new API key with permissions **Send via SMTP** and **Templates: Read-only**. Then edit
    this file with the following contents (replace ``$API_KEY``, no need for quotes):

    .. code-block:: ini

        [smtp]
        password = $API_KEY

    Then restart the container:

    .. code-block:: bash

        sudo docker restart grafana

1. Browse to https://filesrv.rob86.net:3000/profile (your Docker host's hostname).
2. Login with admin/admin.
3. Change the password, put your real email, and set any other settings desired.
4. Browse to https://filesrv.rob86.net:3000/org and set name to "Home".
5. Browse to https://filesrv.rob86.net:3000/datasources/new and set:

    * Name: **telegraf**; Default: **✓**; Type: **InfluxDB**
    * Url: **http://influxdb:8086**; Access: **proxy**
    * Database: **telegraf**; User: **grafana**; Password: **REPLACE_ME**

6. Browse to https://filesrv.rob86.net:3000/alerting/notification/new and send all alerts to your email address.
7. Import dashboard JSONs from: https://github.com/Robpol86/influxdb/tree/master/grafana

Cronitor
========

What if my server hangs or goes down when I'm not directly using it? All of this monitoring software I'm setting up
won't notify me when my server is unresponsive. Luckily there's a service out there with a free tier that solves this
problem: `Cronitor <https://cronitor.io>`_

.. describe:: .secrets/cronitor

    Go to your Cronitor dashboard and find your "Unique Ping URL". Get the **URL ID** from the url (e.g. ``aBc123`` in
    ``https://cronitor.link/aBc123/{ENDPOINT}``) and its **auth_key**. Then edit this file adding those two strings in
    their own lines (file will consist of just two lines):

    .. code-block:: text

        aBc123
        1a329a5f1456789a1bc1d08764c2f3ae

    Then restart the container:

    .. code-block:: bash

        sudo docker restart cronitor

NMC
===

Metrics are collected from my `UPS`_ through its `NMC`_ using SNMP. This container is just a Telegraf container with the
`SNMP input plugin <https://github.com/influxdata/telegraf/tree/master/plugins/inputs/snmp>`_ configured for the NMC.

.. describe:: .secrets/nmc

    Edit this file adding the InfluxDB ``telegraf_nmc`` user password for the first line and the SNMPv1 community string
    for the second line (file will consist of just two lines):

    .. code-block:: text

        telegraf_nmc_password_here
        snmp_community_string_here

    Then restart the container:

    .. code-block:: bash

        sudo docker restart nmc

.. _UPS: http://www.apc.com/shop/us/en/products/APC-Smart-UPS-1500VA-LCD-RM-2U-120V/P-SMT1500RM2U
.. _NMC: http://www.apc.com/shop/us/en/products/UPS-Network-Management-Card-2-with-Environmental-Monitoring/P-AP9631
.. _SNMP input plugin: https://github.com/influxdata/telegraf/tree/master/plugins/inputs/snmp
