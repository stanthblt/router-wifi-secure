# Routeur Portable WiFi Sécurisé avec Raspberry Pi 🌐📡

Bienvenue sur la page du projet de Routeur Portable WiFi Sécurisé utilisant Raspberry Pi 4. Ce projet vise à créer un point d'accès WiFi portable, sécurisé grâce à l'usage d'un VPN 🌐 et d'un portail captif pour la gestion des connexions 🔐. Idéal pour sécuriser vos connexions dans des environnements où la sécurité du réseau est une préoccupation, ce routeur est parfait pour les voyages 🚀, le travail à distance 🏡, ou tout simplement pour améliorer la sécurité de votre réseau domestique.

## Caractéristiques Principales 🌟

-   **Portable et Léger** 💼: Facile à transporter et à configurer où que vous soyez.
-   **Sans Mot de Passe WiFi** 🔓: Accès au réseau via un portail captif, augmentant la sécurité.
-   **Connexion Sécurisée** 🔒: Trafic Internet chiffré grâce à l'utilisation d'un VPN.
-   **Flexible** 🔄: Fonctionne avec une connexion Ethernet ou WiFi comme source d'Internet.
-   **Open Source** 📂: Construit avec des logiciels libres et ouverts.

## Matériel Requis 📦

-   Raspberry Pi 4
-   Carte SD de 64GB (recommandée Raspberry Pi OS Lite 64GB) 💾
-   Source d'alimentation pour Raspberry Pi 🔌
-   Câble Ethernet (optionnel, pour une connexion directe à un modem ou routeur) 🌐

## Logiciels Utilisés 💻

-   **Raspberry Pi OS Lite** 🖥️: Système d'exploitation léger et efficace pour Raspberry Pi.
-   **RaspAP** 📶: Permet de configurer facilement le Raspberry Pi comme un point d'accès WiFi.
-   **VPN** 🛡️: Pour sécuriser et chiffrer votre connexion Internet.
-   **Nodogsplash** 🚪: Gère le portail captif, offrant une couche de sécurité supplémentaire.
-   **Scripts personnalisés** 📜: Scripts .sh pour la gestion des identifiants et mots de passe, avec chiffrement.

## Configuration 🛠️

### 1. Installation du Raspberry Pi OS 💽

Commencez par télécharger et installer Raspberry Pi OS Lite sur votre carte SD. Utilisez le logiciel de gravure de votre choix pour écrire l'image sur la carte.

### 2. Configuration de RaspAP 📶

Commencez par installer un OS  [Linux supporté](https://raspap.com/#distros). Par exemple si vous utilisé,  [Raspberry Pi OS (64-bit) Lite](https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-64-bit). Mettez à jour votre système d'exploitation à sa dernière version, y compris le noyau et le micrologiciel, puis redémarrez l'ordinateur :

```bash
 sudo apt-get update
 sudo apt-get full-upgrade
 sudo reboot    
```

Définir le pays du WiFi dans la section `raspi-config`  **Localisation Options**:

```bash
   sudo raspi-config           
```

Lancer l'installateur rapide de RaspAP

```bash
   curl -sL https://install.raspap.com | bash            
```

Ensuite rendez-vous sur la page de configuration de raspap, il faut donc que vous trouviez l'adresse ip de votre raspberry pi.

**Accès à la page de configuration par défaut  :**
-   **Username:**  admin
-   **Password:**  secret

**Configuration WiFi par défaut :**

-   **SSID:**  raspi-webgui
-   **Password:**  ChangeMe

### 3. Configuration du VPN 🔐

Configurez votre service VPN de choix sur le Raspberry Pi pour sécuriser toute la connexion Internet passant par le routeur.

### 4. Installation et Configuration de Nodogsplash 🚪

## Installing the software

Commencez par mettre à jour votre OS avec les dernières informations sur les paquets :

```bash
sudo apt-get update
``` 

Avec notre gestionnaire de paquets à jour, installez une dépendance requise par nodogsplash :

```bash
sudo apt-get install libmicrohttpd-dev
``` 

Ensuite, clonez le dépôt GitHub nodogsplash dans votre répertoire personnel :

```bash
cd ~/ 
git clone https://github.com/nodogsplash/nodogsplash.git
```

Nous pouvons maintenant lancer l'installateur nodogsplash à partir des sources :

```bash
cd nodogsplash
make
sudo make install
```

Pour la configuration nous avons souhaitez pouvoir mettre un système d'authentification avec username et mot de passe voici la configuration
```bash
#

# Nodogsplash Configuration File

#

GatewayInterface wlan0


FirewallRuleSet authenticated-users {

FirewallRule allow all
}

FirewallRuleSet preauthenticated-users {

FirewallRule allow tcp port 53

FirewallRule allow udp port 53
}

FirewallRuleSet users-to-router {

FirewallRule allow udp port 53

FirewallRule allow tcp port 53

FirewallRule allow udp port 67

FirewallRule allow tcp port 22

FirewallRule allow tcp port 80

FirewallRule allow tcp port 443

}

GatewayAddress 10.3.141.1

MaxClients 250

PreAuthIdleTimeout 30

BinAuth /etc/nodogsplash/auth/binauth.sh
```

Nous allons nous occuper d'installer MariaDB pour pouvoir stocker les usernames ainsi que le hash des passwords :

```bash
sudo  apt  install mariadb-server
```

Une fois les fichiers téléchargé il va falloir installer MariaDB, pour plus de sécurité, nous avons répondu Y pour chaque question posé lors de l'installation

```
sudo mysql_secure_installation
```

Maintenant que nous avons installer la base de donnée il faut y accéder, pour cela nous allons rentrer cette ligne dans le terminal
```bash
sudo mysql -u root -p
```
Une fois connecté nous allons créer la base de donnée puis créer un nouvel utilisateur pour y accéder
```bash
CREATE DATABASE raspap;
``` 
```bash
CREATE  TABLE login ( username VARCHAR(255) NOT  NULL, password VARCHAR(255) NOT  NULL, PRIMARY KEY (username) );
```
```bash
GRANT ALL PRIVILEGES ON raspap.* TO 'raspap'@'localhost' IDENTIFIED BY 'votre_mot_de_passe';
FLUSH PRIVILEGES;
```
```bash
EXIT;
```


### 5. Scripts Personnalisés 📜

Déployez les scripts .sh personnalisés pour gérer l'authentification des utilisateurs. Ces scripts doivent gérer de manière sécurisée les identifiants et mots de passe, avec un système de chiffrement efficace.

```bash
#!/bin/sh

# BinAuth script for NoDogSplash authentication with MySQL database

DB_USER="raspap"
DB_PASS="votre_mot_de_passe"
DB_NAME="raspap"
DB_HOST="localhost"

METHOD="$1"
CLIENTMAC="$2"

case "$METHOD" in
    auth_client)
        USERNAME="$3"
        PASSWORD="$4"

        PASSWORD_HASH=$(echo -n "$PASSWORD" | sha256sum | awk '{print $1}')

        SQL_RESULT=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -h"$DB_HOST" -se "SELECT COUNT(*) FROM login WHERE username='$USERNAME' AND password='$PASSWORD_HASH';")

        if [ "$SQL_RESULT" -eq 1 ]; then
            # Authentication successful
            echo "3600 0 0"  # 1-hour session, 1024 KBit/s upload limit, 512 KBit/s download limit
            exit 0
        else
            # Authentication failed
            exit 1
        fi
        ;;
    client_auth|client_deauth|idle_deauth|timeout_deauth|ndsctl_auth|ndsctl_deauth|shutdown_deauth)
        INGOING_BYTES="$3"
        OUTGOING_BYTES="$4"
        SESSION_START="$5"
        SESSION_END="$6"
        # client_auth: Client authenticated via this script.
        # client_deauth: Client deauthenticated by the client via splash page.
        # idle_deauth: Client was deauthenticated because of inactivity.
        # timeout_deauth: Client was deauthenticated because the session timed out.
        # ndsctl_auth: Client was authenticated by the ndsctl tool.
        # ndsctl_deauth: Client was deauthenticated by the ndsctl tool.
        # shutdown_deauth: Client was deauthenticated by Nodogsplash terminating.
        ;;
esac
```

## Utilisation 👤

Après la configuration, connectez votre Raspberry Pi à une source d'Internet via Ethernet ou WiFi. Les utilisateurs pourront se connecter au réseau WiFi sans mot de passe, mais seront redirigés vers un portail captif pour l'authentification. Toute la connexion Internet sera sécurisée via le VPN configuré.

## Sécurité 🔒

Le projet met un point d'honneur sur la sécurité. En utilisant un portail captif, un VPN, et un chiffrement des données d'authentification, ce routeur portable offre une solution sécurisée pour accéder à Internet, même sur des réseaux publics non sécurisés.

## Contributeur 🤝

[@nicoocaa](https://github.com/nicoocaa)
[@stanthblt](https://github.com/stanthblt)
