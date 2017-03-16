.. _raspberrypi:

=====================
Raspberry Pi Watchdog
=====================

What if my server hangs or goes down when I'm not directly using it? All of this monitoring software I'm setting up
won't notify me when my server is unresponsive. My solution to this problem is a dedicated `Raspberry Pi`_ with a
`cellular connection`_ on a `UPS`_. However these instructions should work on any Linux computer with a network
connection of any type.

.. _Raspberry Pi: https://www.raspberrypi.org/products/
.. _cellular connection: https://robpol86.com/raspberry_pi_project_fi.html
.. _UPS: https://www.amazon.com/APC-Back-UPS-Battery-Protector-BE425M/dp/B01HDC236Q/

Preparing the Pi
================

Before setting up the cellular modem (we don't want these apt-get commands run over cellular which is very slow) I'll
install required software and configure the system. I'm running these commands on a `newly installed`_ Raspbian system.

.. _newly installed: https://gist.github.com/Robpol86/3d4730818816f866452e

Configure Telegraf
------------------

My server will SSH into the Raspberry Pi and manually run Telegraf with an SSH tunnel opened back to my InfluxDB
database. For this to work I need to setup Telegraf on the Pi but not have the daemon run.

.. code-block:: bash

    sudo tee /etc/apt/sources.list.d/influx.list <<< 'deb https://repos.influxdata.com/debian jessie stable'
    curl -sL https://repos.influxdata.com/influxdb.key |sudo apt-key add -
    sudo apt-get update
    sudo apt-get install telegraf
    sudo systemctl disable telegraf.service
    url=https://raw.githubusercontent.com/Robpol86/influxdb/master/etc/telegraf_rpi.conf
    curl -s $url |sudo tee /etc/telegraf/telegraf.conf
    telegraf -test

If the final test command works you're set.

Hardening the Pi
----------------

Before exposing the Pi to Tor it's a good idea to lock it down. Remember to **enable the SSH server** on the Pi. Edit
``/etc/ssh/sshd_config``:

.. code-block:: apacheconf

    PasswordAuthentication no
    PermitRootLogin no

Generate SSH keys and run:

.. code-block:: bash

    mkdir -m0700 .ssh; (umask 0077; cat >> .ssh/authorized_keys)
    sudo service ssh restart
    sudo sed -i 's/NOPASSWD: //g' /etc/sudoers.d/010_pi-nopasswd

Configure Cellular Modem
========================

I then setup my modem following this guide: https://robpol86.com/raspberry_pi_project_fi.html

Install and Configure Tor
=========================

Since my Pi will be on a cellular connection my server won't be able to SSH into it (can't open ports). I also don't
want my Pi SSHing into my server since if I end up relocating the Pi outside of my home it can get stolen and the crook
will have SSH access to my server.

The solution is to put the Raspberry Pi's SSH server behind a `Tor hidden service`_. My server will periodically SSH
into my Raspberry Pi to collect some metrics (and alert me if the Pi is unavailable) and the Raspberry Pi will have a
cron job that sends out an email if my server hasn't logged in for a while.

First install Tor:

.. code-block:: bash

    sudo apt-get install tor
    sudo mkdir -m0700 /var/lib/tor/sshd/; sudo chown debian-tor.debian-tor $_

Add this to ``/etc/tor/torrc``:

.. code-block:: apacheconf

    HiddenServiceDir /var/lib/tor/sshd/
    HiddenServicePort 22 127.0.0.1:22
    HiddenServiceAuthorizeClient stealth Docker

Start the service:

.. code-block:: bash

    sudo systemctl start tor
    sudo systemctl enable tor
    sudo cat /var/lib/tor/sshd/hostname  # Write down the output.

If you don't have a ``hostname`` file in that directory try running ``sudo systemctl restart tor`` and tail
``/var/log/tor/log`` for any errors.

.. _Tor hidden service: https://www.torproject.org/docs/tor-hidden-service.html

Verifying
---------

If you want to verify SSH is working over cellular and Tor you can install Tor on a client machine (I used a Fedora VM)
and attempt to SSH in:

.. code-block:: bash

    sudo dnf install tor socat
    # Add this to /etc/tor/torrc:
    # HidServAuth gv3x4yxk7lcizd6q.onion hNm5BgqGrjz+a2Pdjri7mB # client: Docker
    sudo systemctl start tor
    ssh -oProxyCommand='socat - SOCKS4A:localhost:%h:%p,socksport=9050' pi@gv3x4yxk7lcizd6q.onion

References
==========

* http://gk2.sk/running-ssh-on-a-raspberry-pi-as-a-hidden-service-with-tor/
