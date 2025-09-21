#!/bin/bash

# Script de test unitaire pour les fonctions du script env_validator.sh
# Usage: ./test-functions.sh

# Couleurs pour les tests
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Compteurs de tests
TESTS_PASSED=0
TESTS_FAILED=0

# Fonction pour exécuter un test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${YELLOW}Test: $test_name${NC}"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✓ PASSED: $test_name${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED: $test_name${NC}"
        ((TESTS_FAILED++))
    fi
    echo ""
}

# Source du script principal pour accéder aux fonctions
source env_validator.sh

echo -e "${GREEN}=== Tests unitaires pour env_validator.sh ===${NC}"
echo ""

# Test 1: Fonction read_json_file avec fichier valide
run_test "read_json_file avec fichier valide" "
    # Créer un fichier JSON temporaire
    echo '{\"TEST_VAR\": \"test_value\"}' > /tmp/test.json
    read_json_file /tmp/test.json
    [[ \${#json_vars[@]} -eq 1 ]]
    [[ \"\${json_vars[TEST_VAR]}\" == \"test_value\" ]]
"

# Test 2: Fonction read_json_file avec fichier manquant
run_test "read_json_file avec fichier manquant" "
    read_json_file /tmp/missing.json
    [[ \$? -ne 0 ]]
"

# Test 3: Fonction read_json_file avec JSON vide
run_test "read_json_file avec JSON vide" "
    echo '{}' > /tmp/empty.json
    read_json_file /tmp/empty.json
    [[ \${#json_vars[@]} -eq 0 ]]
"

# Test 4: Fonction check_environment_variables
run_test "check_environment_variables" "
    # Préparer les données de test
    json_vars[TEST_VAR1]='value1'
    json_vars[TEST_VAR2]='value2'
    export TEST_VAR1='value1'
    export TEST_VAR2='different_value'
    
    check_environment_variables
    [[ \${#mismatched_vars[@]} -eq 1 ]]
    [[ \"\${mismatched_vars[TEST_VAR2]}\" == \"value2\" ]]
"

# Test 5: Fonction show_warnings
run_test "show_warnings" "
    mismatched_vars[WARNING_VAR]='warning_value'
    show_warnings
    [[ \$? -eq 0 ]]
"

# Test 6: Fonction override_incorrect_variables
run_test "override_incorrect_variables" "
    mismatched_vars[OVERRIDE_VAR]='new_value'
    export OVERRIDE_VAR='old_value'
    
    override_incorrect_variables
    [[ \"\$OVERRIDE_VAR\" == \"new_value\" ]]
"

# Test 7: Fonction validate_and_sync_environment
run_test "validate_and_sync_environment" "
    echo '{\"SYNC_VAR\": \"sync_value\"}' > /tmp/sync.json
    validate_and_sync_environment /tmp/sync.json
    [[ \$? -eq 0 ]]
"

# Test 8: Test de l'aide
run_test "Affichage de l'aide" "
    ./env_validator.sh --help | grep -q 'Usage:'
"

# Test 9: Test avec fichier par défaut
run_test "Test avec fichier par défaut" "
    # Créer config.json s'il n'existe pas
    if [[ ! -f config.json ]]; then
        echo '{\"DEFAULT_VAR\": \"default_value\"}' > config.json
    fi
    ./env_validator.sh
    [[ \$? -eq 0 ]]
"

# Test 10: Test de non-exécution lors du sourcing
run_test "Non-exécution lors du sourcing" "
    # Le script ne devrait pas s'exécuter quand sourcé
    source env_validator.sh
    echo 'Script sourcé avec succès'
    [[ \$? -eq 0 ]]
"

# Nettoyage
cleanup() {
    rm -f /tmp/test.json /tmp/empty.json /tmp/sync.json
    unset json_vars
    unset env_vars
    unset mismatched_vars
}

# Résumé des tests
echo -e "${GREEN}=== Résumé des tests ===${NC}"
echo -e "${GREEN}Tests réussis: $TESTS_PASSED${NC}"
echo -e "${RED}Tests échoués: $TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}🎉 Tous les tests sont passés !${NC}"
    cleanup
    exit 0
else
    echo -e "${RED}❌ Certains tests ont échoué.${NC}"
    cleanup
    exit 1
fi
