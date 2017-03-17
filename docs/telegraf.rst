.. _telegraf:

======================
Telegraf on the Server
======================

To get some data in InfluxDB we'll install Telegraf to collect metrics from the Docker host itself. It'll need to run 
outside of Docker in order to collect all available metrics.

Install Telegraf
================

.. code-block:: bash

    sudo dnf install https://dl.influxdata.com/telegraf/releases/telegraf-1.2.1.x86_64.rpm
    url=https://raw.githubusercontent.com/Robpol86/influxdb/master/etc/telegraf.conf
    curl -s $url |sudo tee /etc/telegraf/telegraf.conf
    sudo chown telegraf /etc/telegraf/telegraf.conf
    sudo chmod 640 /etc/telegraf/telegraf.conf

At the time of this writing the ipmitool plugin in the latest Telegraf release was missing the "run local" feature. I 
had to compile the latest master and replace ``/usr/bin/telegraf``.

Dependencies
============

Install software that Telegraf will be using. Rather than run Telegraf as root, the best idea I could come up with was 
to grant the telegraf user access to ``/dev/ipmi0`` in order for it to collect those metrics.

.. code-block:: bash

    sudo dnf install ipmitool hddtemp
    sudo tee /etc/modules-load.d/ipmi_devintf.conf <<< ipmi_devintf
    sudo tee /etc/udev/rules.d/40-ipmi.rules <<< 'KERNEL=="ipmi0", GROUP="telegraf", MODE="0660"'
    sudo systemctl restart systemd-modules-load
    sudo ipmitool sdr  # Should list temperatures and more.
    hddtemp  # Should list temperatures of all drives.
    sudo vim /etc/sysconfig/hddtemp  # Add "-u F" for fahrenheit.
    sudo systemctl start hddtemp.service
    sudo systemctl enable hddtemp.service

Tweak and Verify
================

Now make changes to the configuration (e.g. set username/password/etc). Test your changes by seeing what Telegraf will 
be transmitting by running ``sudo telegraf -test`` and making sure it exits 0. Once that works try manually running 
Telegraf with ``sudo telegraf`` and make sure it's able to send data to the database.

Once everything looks good enable the service:

.. code-block:: bash

    sudo systemctl start telegraf.service
    sudo systemctl enable telegraf.service

Wait a few minutes and then verify data is being collected:

.. code-block:: bash

    sudo docker exec -it influxdb influx -database telegraf

.. code-block:: sql

    AUTH
    SHOW SERIES
    SELECT * FROM hddtemp WHERE time > now() - 10m

getsockopt: Connection Refused Fix
==================================

Another boot-time race condition. Telegraf starts before the InfluxDB docker container. To get rid of these annoying 
errors I did the following:

1. Run ``sudo systemctl edit --full telegraf.service``
2. Add ``Wants=docker.service`` to the Unit section.
3. Append ``docker.service`` to the end of the Unit.After setting.
