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

My server will SSH into the Raspberry Pi with an SSH tunnel opened back to my InfluxDB database. It will try to maintain
this connection indefinitely. For this to work I need to setup Telegraf on the Pi first.

.. code-block:: bash

    sudo tee /etc/apt/sources.list.d/influx.list <<< 'deb https://repos.influxdata.com/debian jessie stable'
    curl -sL https://repos.influxdata.com/influxdb.key |sudo apt-key add -
    sudo apt-get update
    sudo apt-get install telegraf
    url=https://raw.githubusercontent.com/Robpol86/influxdb/master/etc/telegraf_rpi.conf
    curl -s $url |sudo tee /etc/telegraf/telegraf.conf
    sudo chmod 0600 /etc/telegraf/telegraf.conf; sudo chown telegraf $_
    url=https://raw.githubusercontent.com/Robpol86/influxdb/master/bin/cpu_temp.awk
    curl -s $url |sudo tee /usr/local/bin/cpu_temp
    sudo chmod +x /usr/local/bin/cpu_temp
    telegraf -test
    sudo systemctl start telegraf.service

Hardening the Pi
----------------

Before exposing the Pi to Tor it's a good idea to lock it down. Remember to **enable the SSH server** on the Pi. Edit
``/etc/ssh/sshd_config``:

.. code-block:: apacheconf

    PasswordAuthentication no
    PermitRootLogin no

Generate SSH keys for the ``pi`` user (for maintenance, not for Server, that's later) and run:

.. code-block:: bash

    mkdir -m0700 .ssh; (umask 0077; cat >> .ssh/authorized_keys)  # Run as pi user.
    sudo service ssh restart
    sudo sed -i 's/NOPASSWD: //g' /etc/sudoers.d/010_pi-nopasswd
    sudo useradd -mp $(openssl rand -base64 20) server; sudo -i -u $_ mkdir -m0700 .ssh
    sudo -i -u server bash -c 'umask 0077; touch .ssh/authorized_keys'

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
    HiddenServiceAuthorizeClient stealth Server

Start the service:

.. code-block:: bash

    sudo systemctl start tor
    sudo systemctl enable tor
    sudo cat /var/lib/tor/sshd/hostname  # Write down the output.
    ssh-keyscan -t ecdsa-sha2-nistp256 localhost  # Write down output.

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
    # HidServAuth gv3x4yxk7lcizd6q.onion hNm5BgqGrjz+a2Pdjri7mB # client: Server
    sudo systemctl start tor
    ssh -oProxyCommand='socat - SOCKS4A:localhost:%h:%p,socksport=9050' pi@gv3x4yxk7lcizd6q.onion

Update Container Config
=======================

Finally it's time to tell the ``pimon`` container the onion addresses, SSH key, and host key to use. The container
should be currently running since earlier in the :ref:`Start Containers` section all containers were started.

.. describe:: /storage/Local/raspberrypi/torrc

    Use the output of the ``cat /var/lib/tor/sshd/hostname`` command from the Raspberry Pi.

    .. code-block:: bash

        sudo touch /storage/Local/raspberrypi/torrc; sudo chmod 0600 $_
        sudo tee $_ <<< 'HidServAuth REPLACE_ME.onion ALSO_REPLACE_ME # client: Server'

.. describe:: /storage/Local/raspberrypi/id_rsa

    .. code-block:: bash

        cd /storage/Local/raspberrypi
        sudo ssh-keygen -t rsa -b 4096 -C "$HOSTNAME" -N "" -f id_rsa
        cat id_rsa.pub

    Append this public key to the ``/home/server/.ssh/authorized_keys`` file on the Raspberry Pi.

.. describe:: /storage/Local/raspberrypi/config

    Use the hostname specified in the output of the ``cat /var/lib/tor/sshd/hostname`` command from the Raspberry Pi.

    .. code-block:: text

        Host raspberrypi
          HostName REPLACE_ME.onion

.. describe:: /storage/Local/raspberrypi/known_hosts

    Use the value from the ``ssh-keyscan`` command run on the Raspberry Pi. **Don't forget** to replace ``localhost``
    with the onion hostname used in the other files.

    .. code-block:: text

        REPLACE_ME.onion ecdsa-sha2-nistp256 AAAAE2...HY0NcRAX37Yk2oie7l8kcY77EhqQ=

Then restart the ``pimon`` container and look at the logs:

.. code-block:: bash

    sudo docker restart pimon
    sudo docker logs pimon --follow

References
==========

* http://gk2.sk/running-ssh-on-a-raspberry-pi-as-a-hidden-service-with-tor/
