# Tests pour env_validator.sh

Ce dossier contient tous les fichiers de test pour le script `env_validator.sh`.

## Structure

```
TEST/
├── README.md                   # Ce fichier
├── test-functions.sh          # Tests unitaires des fonctions
├── test-config.json           # Configuration de test
└── scenarios/
    ├── test-empty.json        # JSON vide
    ├── test-single.json       # Une seule variable
    ├── test-complex.json      # Scénario complexe
    └── test-invalid.json      # JSON invalide
```

## Tests unitaires

### test-functions.sh

Script de test unitaire qui teste toutes les fonctions du script principal :

```bash
# Rendre exécutable et lancer
chmod +x test-functions.sh
./test-functions.sh
```

**Tests inclus :**
- Lecture de fichier JSON valide
- Gestion des fichiers manquants
- Gestion des JSON vides
- Vérification des variables d'environnement
- Affichage des warnings
- Surcharge des variables
- Fonction globale d'orchestration
- Test de l'aide
- Test de non-exécution lors du sourcing

## Scénarios de test

### test-empty.json
```json
{}
```
Test avec un objet JSON vide.

### test-single.json
```json
{
  "SINGLE_VAR": "single_value"
}
```
Test avec une seule variable.

### test-complex.json
```json
{
  "DATABASE_URL": "postgresql://test:test@localhost:5432/testdb",
  "API_KEY": "test123",
  "DEBUG_MODE": "true",
  "PORT": "9000",
  "LOG_LEVEL": "debug",
  "CACHE_TTL": "7200",
  "NEW_VAR": "new_value",
  "SPECIAL_CHARS": "value with spaces and @#$%",
  "NUMERIC_VALUE": "12345",
  "BOOLEAN_VALUE": "false"
}
```
Test avec un scénario complexe incluant différents types de valeurs.

### test-invalid.json
```json
{
  "invalid": json,
  "missing_quote": "value
}
```
Test avec un JSON invalide (doit échouer).

## Configuration de test

### test-config.json
```json
{
  "TEST_DATABASE_URL": "postgresql://test:test@localhost:5432/testdb",
  "TEST_API_KEY": "test_api_key_123",
  "TEST_DEBUG_MODE": "true",
  "TEST_PORT": "3001",
  "TEST_LOG_LEVEL": "debug",
  "TEST_CACHE_TTL": "1800",
  "TEST_NEW_FEATURE": "enabled",
  "TEST_TIMEOUT": "30"
}
```
Configuration de test avec des variables préfixées par `TEST_`.

## Utilisation

### Tests locaux
```bash
# Tests unitaires complets
./TEST/test-functions.sh

# Test avec scénario spécifique
./env_validator.sh TEST/scenarios/test-complex.json

# Test avec configuration de test
./env_validator.sh TEST/test-config.json
```

### Tests GitHub Actions

Les tests sont automatiquement exécutés via GitHub Actions sur :
- CentOS 7
- CentOS 8 / Rocky Linux
- Différents scénarios de test
- Tests de performance
- Gestion d'erreurs

## Résultats attendus

- **Tests unitaires** : Tous les tests doivent passer (10/10)
- **JSON valide** : Le script doit s'exécuter sans erreur
- **JSON invalide** : Le script doit échouer avec un code d'erreur
- **Fichier manquant** : Le script doit afficher une erreur et échouer
- **Variables discordantes** : Le script doit détecter et surcharger les variables

## Dépendances

- `bash` (CentOS/RHEL)
- `jq` pour le parsing JSON
- Variables d'environnement pour les tests de discordance
