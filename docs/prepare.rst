.. _prepare:

====================
Preparing the Server
====================

I'm running **Fedora Server 25** on `my server <https://robpol86.com/my_awesome_server.html>`_. Before getting started I
had to prepare my server by installing Docker and other software.

SSL Certificate
===============

In addition to my home server I also have a `home root CA <https://robpol86.com/root_certificate_authority.html>`_ to
generate SSL certificates for HTTP services running on my home network. Things such as IPMI web interfaces, my WiFi
access point administration page, etc.

SSL is implemented by an `NGINX reverse proxy <https://github.com/Robpol86/influxdb/blob/master/etc/nginx.conf>`_. All
exposed ports in my `Compose file <https://github.com/Robpol86/influxdb/blob/master/docker-compose.yml>`_ are routed
through the NGINX container which terminates SSL. This way Grafana/Influxdb/etc talk to each other in clear text
internally allowing me to use convenient hostnames such as "localhost" or "influxdb" and not the fully qualified name of
my server which is required by the SSL certificate.

If you don't want to use SSL certificates (not really necessary for a home network, I just like having it) you should be
fine tweaking your docker-compose.yaml file to have Grafana/Influxdb/etc expose ports and remove the nginx section.

Since I'll be using an SSL certificate I need to install it (along with the corresponding private key) on my server
outside of Docker. I put it in ``/etc``:

1. SCP ``filesrv.rob86.net.cert.pem`` and ``filesrv.rob86.net.key.pem`` to home directory.
2. ``cat *.key.pem *.cert.pem > filesrv.rob86.net.pem``
3. ``for f in *.pem; do sudo sh -c "umask 0277 && cp $HOME/$f /etc/$f"; done``
4. ``sudo chmod 444 /etc/filesrv.rob86.net.cert.pem``
5. ``rm ~/*.pem``

The above was just a fancy way of putting the three files in ``/etc`` with ``chmod 400``. The cert-only file can be read
by everyone so I chmodded it to 444 afterwards.

Make sure your root CA file
`is also installed <https://robpol86.com/root_certificate_authority.html#finally-generate-the-pair>`_ using
``update-ca-trust``.

Docker and Compose
==================

There are two ways to install Docker and Docker Compose on Fedora. You can just ``dnf`` install the versions shipped by
the OS but this isn't the "real" Docker (that's what I was told when I interviewed there :P). It's also not the latest,
which is what I want. I installed Docker with these commands:

.. code-block:: bash

    sudo dnf -y remove docker docker-common container-selinux docker-selinux
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf makecache fast
    sudo dnf install docker-ce
    sudo systemctl start docker
    sudo systemctl enable docker.service
    sudo docker run hello-world

And I ran these commands to install Compose:

.. code-block:: bash

    version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest |jq --raw-output .name)
    url="https://github.com/docker/compose/releases/download/$version/docker-compose-Linux-$(uname -m)"
    sudo curl -L $url -o /usr/local/bin/docker-compose; sudo chmod +x $_

/etc/resolv.conf Fix
--------------------

I ran into a problem on my server during reboot: the containers wouldn't auto-start on boot but would if I manually
started them. I was seeing this error:

``Failed to start container 06551c8e77474b48a: open /etc/resolv.conf: no such file or directory``

Turns out there was a race condition between NetworkManager waiting for DHCP and Docker starting the containers. Docker
was too fast and tried to start containers before NetworkManager created the ``/etc/resolv.conf`` symlink. I fixed this
by:

1. Running ``sudo systemctl edit --full docker.service``
2. Adding ``Wants=network-online.target`` to the Unit section.
3. Replacing ``network.target`` with ``network-online.target`` in the Unit.After setting.
