#!/bin/bash

# Script de validation et synchronisation des variables d'environnement
# Usage: ./env_validator.sh [fichier_json]

# Couleurs pour les messages
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Variables globales
declare -A json_vars
declare -A env_vars
declare -A mismatched_vars

# Fonction pour lire et parser le fichier JSON
read_json_file() {
    local json_file="$1"
    
    if [[ ! -f "$json_file" ]]; then
        echo -e "${RED}Erreur: Le fichier JSON '$json_file' n'existe pas.${NC}"
        return 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Erreur: 'jq' n'est pas installé. Veuillez l'installer pour parser le JSON.${NC}"
        echo "Installation: sudo apt-get install jq (Ubuntu/Debian) ou brew install jq (macOS)"
        return 1
    fi
    
    echo -e "${GREEN}Lecture du fichier JSON: $json_file${NC}"
    
    # Parser le JSON et extraire les paires clé-valeur
    while IFS='=' read -r key value; do
        if [[ -n "$key" && -n "$value" ]]; then
            # Nettoyer les clés et valeurs (supprimer les espaces et guillemets)
            key=$(echo "$key" | sed 's/^[[:space:]]*"//;s/"[[:space:]]*$//')
            value=$(echo "$value" | sed 's/^[[:space:]]*"//;s/"[[:space:]]*$//')
            json_vars["$key"]="$value"
            echo "  Variable JSON trouvée: $key = $value"
        fi
    done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' "$json_file")
    
    echo -e "${GREEN}Total de variables JSON trouvées: ${#json_vars[@]}${NC}"
    return 0
}

# Fonction pour vérifier la concordance avec les variables d'environnement
check_environment_variables() {
    echo -e "${GREEN}Vérification des variables d'environnement...${NC}"
    
    local mismatch_count=0
    
    for var_name in "${!json_vars[@]}"; do
        local json_value="${json_vars[$var_name]}"
        local env_value="${!var_name}"
        
        if [[ -n "$env_value" ]]; then
            env_vars["$var_name"]="$env_value"
            
            if [[ "$json_value" != "$env_value" ]]; then
                mismatched_vars["$var_name"]="$json_value"
                ((mismatch_count++))
                echo -e "${YELLOW}  Discordance détectée pour '$var_name':${NC}"
                echo -e "    JSON: $json_value"
                echo -e "    ENV:  $env_value"
            else
                echo -e "  ✓ '$var_name' correspond"
            fi
        else
            echo -e "${YELLOW}  Variable '$var_name' non définie dans l'environnement${NC}"
            mismatched_vars["$var_name"]="$json_value"
            ((mismatch_count++))
        fi
    done
    
    echo -e "${GREEN}Vérification terminée. Discordances trouvées: $mismatch_count${NC}"
    return 0
}

# Fonction pour afficher les warnings des variables incorrectes
show_warnings() {
    if [[ ${#mismatched_vars[@]} -eq 0 ]]; then
        echo -e "${GREEN}Aucune variable incorrecte trouvée.${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}=== WARNINGS - Variables incorrectes ===${NC}"
    
    for var_name in "${!mismatched_vars[@]}"; do
        local json_value="${mismatched_vars[$var_name]}"
        local env_value="${!var_name}"
        
        echo -e "${YELLOW}⚠️  Variable: $var_name${NC}"
        echo -e "   Valeur JSON: $json_value"
        if [[ -n "$env_value" ]]; then
            echo -e "   Valeur ENV:  $env_value"
        else
            echo -e "   Valeur ENV:  (non définie)"
        fi
        echo ""
    done
    
    echo -e "${YELLOW}Total de variables à corriger: ${#mismatched_vars[@]}${NC}"
    return 0
}

# Fonction pour surcharger les variables incorrectes
override_incorrect_variables() {
    if [[ ${#mismatched_vars[@]} -eq 0 ]]; then
        echo -e "${GREEN}Aucune variable à surcharger.${NC}"
        return 0
    fi
    
    echo -e "${GREEN}=== Surcharge des variables incorrectes ===${NC}"
    
    for var_name in "${!mismatched_vars[@]}"; do
        local json_value="${mismatched_vars[$var_name]}"
        local old_value="${!var_name}"
        
        # Exporter la nouvelle valeur
        export "$var_name"="$json_value"
        
        echo -e "${GREEN}✓ Variable '$var_name' surchargée:${NC}"
        if [[ -n "$old_value" ]]; then
            echo -e "   Ancienne valeur: $old_value"
        else
            echo -e "   Ancienne valeur: (non définie)"
        fi
        echo -e "   Nouvelle valeur: $json_value"
        echo ""
    done
    
    echo -e "${GREEN}Total de variables surchargées: ${#mismatched_vars[@]}${NC}"
    return 0
}

# Fonction globale qui orchestre toutes les étapes
validate_and_sync_environment() {
    local json_file="$1"
    
    echo -e "${GREEN}=== Début de la validation et synchronisation des variables d'environnement ===${NC}"
    echo ""
    
    # Étape 1: Lire le fichier JSON
    if ! read_json_file "$json_file"; then
        return 1
    fi
    echo ""
    
    # Étape 2: Vérifier les variables d'environnement
    check_environment_variables
    echo ""
    
    # Étape 3: Afficher les warnings
    show_warnings
    echo ""
    
    # Étape 4: Surcharger les variables incorrectes
    override_incorrect_variables
    echo ""
    
    echo -e "${GREEN}=== Validation et synchronisation terminées ===${NC}"
    return 0
}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [fichier_json]"
    echo ""
    echo "Ce script valide et synchronise les variables d'environnement avec un fichier JSON."
    echo ""
    echo "Arguments:"
    echo "  fichier_json    Chemin vers le fichier JSON contenant les variables (optionnel)"
    echo "                  Par défaut: 'config.json'"
    echo ""
    echo "Exemple:"
    echo "  $0 config.json"
    echo "  $0"
    echo ""
    echo "Le script:"
    echo "  1. Lit le fichier JSON et extrait les paires nom/valeur"
    echo "  2. Compare avec les variables d'environnement actuelles"
    echo "  3. Affiche des warnings pour les variables incorrectes"
    echo "  4. Surcharge les variables incorrectes avec les valeurs du JSON"
}

# Fonction principale
main() {
    local json_file="${1:-config.json}"
    
    # Vérifier si l'utilisateur demande de l'aide
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        return 0
    fi
    
    # Exécuter la validation et synchronisation
    validate_and_sync_environment "$json_file"
}

# Vérifier si le script est exécuté directement (pas sourcé)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
