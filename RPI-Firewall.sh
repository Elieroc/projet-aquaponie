#!/bin/bash

# Ce script a pour but de configurer automatiquement
# le pare-feu.
# Il interdit les communications sur tous les ports sauf :
# - Le 3443 pour ssh et le sftp
# - Le 80 pour le site web
# - Le 9669 pour PhpMyAdmin
# - Le 433 pour le site web
# - Le 53 pours les DNS
# - ICMP pour autoriser le ping

# Il a été créé par Élie Rocamora, un élève de Terminale STI2D dans le cadre d'un projet
# v1 : 31/03/2021
# Retrouvez mes autres projets :
# https://github.com/Elieroc/

function installation {

  echo "Installation..."
  cp RPI-Firewall.sh /etc/init.d/RPI-Firewall
  chmod +x /etc/init.d/RPI-Firewall
  update-rc.d RPI-Firewall defaults

}

function init {

# On flush
iptables -F

}

function stop {

echo "Coupure du pare-feu"

# Politics
iptables -P OUTPUT ACCEPT
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT

}

function main {

echo "Démarrage du pare-feu"

# Politics
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP

# Connection establish
iptables -A INPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# SSH
iptables -A INPUT -p tcp --dport 3443 -j ACCEPT

# HTTP
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT

#HTTPS
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 443 -j ACCEPT

# PhpMyAdmin
iptables -A INPUT -p tcp --dport 9669 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 9669 -j ACCEPT

#DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

#Ping
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT

}

# Si aucun paramètre n'est indiqué, on démarre le pare-feu
if [[ $1 == "on" || $1 == "start" || -z $1 ]]; then
  init
  main
fi
if [ $1 == "off" ]; then
  init
  stop
elif [ $1 == "install" ]; then
  installation
fi
