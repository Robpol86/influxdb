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

.. include:: ../README.rst
    :start-after: clone-section-start
    :end-before: clone-section-end

Start Containers
================

.. include:: ../README.rst
    :start-after: up-section-start
    :end-before: up-section-end
