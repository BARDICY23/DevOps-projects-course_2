#!/bin/bash
sudo apt update -y
sudo apt install memcached -y
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/memcached.conf
sudo systemctl restart memcached
sudo systemctl enable memcached
sudo systemctl status memcached

