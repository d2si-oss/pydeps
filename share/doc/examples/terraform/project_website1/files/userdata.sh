#!/bin/bash

# mise a jour des paquets 
yum -y update
yum -y upgrade

# installation du service web
yum -y install nginx

# demarrage du service web car il n'est pas démarré automatiquement
service nginx start