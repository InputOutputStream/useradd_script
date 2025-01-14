#!/bin/bash

# Vérification des arguments
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <username> <comment> <default_shell> <validity_days>"
    exit 1
fi

USERNAME="$1"
COMMENT="$2"
SHELL="$3"
EXP_DAYS="$4"
PASS="inf3611"
QUOTA=$((2 * 1048576)) # 2 Go en blocs de 1 Ko

# Création de l'utilisateur avec les paramètres de base
sudo useradd -m -c "$COMMENT" -s "$SHELL" -e $(date -d "+$EXP_DAYS days" +%Y-%m-%d) "$USERNAME"

# Définition du mot de passe par défaut
echo "$USERNAME:$PASS" | sudo chpasswd

# Forcer le changement de mot de passe à la première connexion
sudo chage -d 0 "$USERNAME"

# Limiter le quota disque à 2 Go
echo "Configuration du quota disque..."
if ! command -v setquota >/dev/null 2>&1; then
    echo "Le paquet quota n'est pas installé. Installation..."
    sudo apt update && sudo apt install -y quota
fi

# Identifier le système de fichiers principal
FILESYSTEM=$(df --output=target / | tail -1)
sudo setquota -u "$USERNAME" $QUOTA $QUOTA 0 0 "$FILESYSTEM"

# Configurer les horaires autorisés (8h à 18h)
echo "Configuration des horaires autorisés (8h à 18h)..."
sudo tee -a /etc/security/time.conf >/dev/null <<EOF
login;*;$USERNAME;Al0800-1800
EOF

# Fin
echo "Utilisateur $USERNAME créé avec succès."
echo "Mot de passe par défaut : $PASS"
echo "Durée de validité du compte : $EXP_DAYS jours"
echo "Quota : 2 Go"
echo "Plage horaire : 8h à 18h"
