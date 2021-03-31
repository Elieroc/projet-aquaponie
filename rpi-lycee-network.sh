#!/bin/bash

# Ce script a été réalisé dans le but d'automatiser
# la connexion des raspberry pi au réseau du Lycée Jean-Baylet
# car la configuration manuelle est plutôt fastifieuse :)

# Il a été créé par Élie Rocamora, un élève de Terminale STI2D dans le cadre d'un projet
# v1 : 30/03/2021
# Retrouvez mes autres projets :
# https://github.com/Elieroc/

# Ce script prend 3 paramètres :
# 1) L'ip que vous souhaitez utiliser sous ce format :
# 	10.1.102.12X où le "X" est à remplacer par le numéro de
# 	votre groupe.
# 2) Votre utilisateur MAGRET (pour le proxy)
# 3) Votre mot de passe MAGRET (pour le proxy)


echo "Network Configurator for Raspberry Pi"
echo "Scripted by Élie Rocamora"
sleep 1
echo ""


function aide {

echo "Bienvenue sur la page d'aide !"
echo ""
echo "Vous devez être root et saisir 3 arguments :"
echo "Le premier argument doit être une addresse IP (valide)"
echo "Le deuxième argument doit être l'utilisateur MAGRET"
echo "Le troisème argument doit être le mot de passe MAGRET"
echo ""
echo "Attention : Ce script va redémarrer votre Raspberry Pi à la fin de son execution !"

}

# Ici on vérifie si des arguments sont absents ou si
# l'utilisateur demande de l'aide
if [[ $1 == "--help" || -z $1  || -z $2 || -z $3 ]];
then
aide
exit
fi


# Sinon on démarre
echo "Démarrage de la configuration..."
sleep 0.5
echo "Votre IP : $1"
echo "Votre utilisateur Magret : $2"
echo "Votre mot de passe Magret : $3"
echo "Pas d'inquiétude, vos identifiants seront bien gardés :)"
echo ""

echo "Ajout des informations dans /etc/dhcpcd.conf"
sleep 1
echo "# Lycée Jean-Baylet" >> /etc/dhcpcd.conf
echo "interface eth0" >> /etc/dhcpcd.conf
echo "static ip_address=$1/8" >> /etc/dhcpcd.conf
echo "static routers=10.255.7.62" >> /etc/dhcpcd.conf
echo "static domain_name_servers=10.255.7.61" >> /etc/dhcpcd.conf
echo ""

echo "Création du fichier de configuration du proxy"
sleep 1
touch /etc/apt/apt.conf.d/proxy
echo ""

echo "Configuration du proxy"
sleep 1
echo "Acquire::http::Proxy \"http://$2:$3@10.255.7.60:3128\";" > /etc/apt/apt.conf.d/proxy
echo ""

echo "Modification des droits d'accès"
sleep 1
chmod o-r /etc/apt/apt.conf.d/proxy
echo ""

echo "Ajout des exports dans /etc/environment"
sleep 1
echo "export http_proxy=\"http://$2:$3@10.255.7.60:3128/\"" > /etc/environment
echo "export https_proxy=\"http://$2:$3@10.255.7.60:3128/\"" >> /etc/environment
echo "export ftp_proxy=\"http://$2:$3@10.255.7.60:3128/\"" >> /etc/environment
echo 'export no_proxy="127.0.0.1, localhost"' >> /etc/environment
echo ""

echo "Modification des droits d'accès"
sleep 1
chmod o-r /etc/environment
echo ""

echo "Configuration du DNS"
sleep 1
rm /etc/resolve.conf
echo "nameserver 10.255.7.61" > /etc/resolve2.conf
echo ""

echo "Redémarrage du système dans 5 secondes !"
sleep 5
reboot
