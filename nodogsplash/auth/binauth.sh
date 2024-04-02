#!/bin/sh

# BinAuth script for NoDogSplash authentication with MySQL database

# MySQL database credentials
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

        # Hasher le mot de passe fourni
        PASSWORD_HASH=$(echo -n "$PASSWORD" | sha256sum | awk '{print $1}')

        # Exécute la commande MySQL pour vérifier les identifiants
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
