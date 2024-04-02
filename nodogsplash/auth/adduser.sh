#!/bin/bash

# Informations de connexion à la base de données MySQL
DB_USER="raspap"
DB_PASS="votre_mot_de_passe"
DB_NAME="raspap"
DB_HOST="localhost"

read -p "Enter username: " USERNAME
read -sp "Enter password: " PASSWORD
echo

# Utilisation de SHA-256 pour le hashage
PASSWORD_HASH=$(echo -n $PASSWORD | sha256sum | awk '{print $1}')

# Vérification si l'utilisateur existe déjà
EXISTS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -h"$DB_HOST" -se "SELECT EXISTS(SELECT 1 FROM login WHERE username='$USERNAME');")

if [ "$EXISTS" -eq 1 ]; then
    # Mise à jour de l'utilisateur existant
    mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -h"$DB_HOST" -se "UPDATE login SET password='$PASSWORD_HASH' WHERE username='$USERNAME';"
    echo "Updated $USERNAME in the database."
else
    # Ajout d'un nouvel utilisateur
    mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -h"$DB_HOST" -se "INSERT INTO login (username, password) VALUES ('$USERNAME', '$PASSWORD_HASH');"
    echo "Added $USERNAME to the database."
fi
