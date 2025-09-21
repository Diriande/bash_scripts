# Script de Validation des Variables d'Environnement

Ce script bash permet de valider et synchroniser les variables d'environnement avec un fichier JSON.

## Fonctionnalités

- ✅ Lecture et parsing d'un fichier JSON
- ✅ Extraction des paires nom/valeur
- ✅ Vérification de concordance avec les variables d'environnement
- ✅ Affichage de warnings pour les variables incorrectes
- ✅ Surcharge automatique des variables incorrectes
- ✅ Architecture modulaire avec fonctions séparées
- ✅ Appel conditionnel (exécution directe uniquement)

## Prérequis

- Bash (RHEL 9 / CentOS/RHEL/WSL)
- `jq` pour le parsing JSON

### Installation de jq

**RHEL 9 (cible principale):**
```bash
sudo dnf install jq
```

**CentOS/RHEL 8 / Rocky Linux 8 / AlmaLinux 8:**
```bash
sudo dnf install jq
```

**CentOS/RHEL 7:**
```bash
sudo yum install epel-release
sudo yum install jq
```

## Utilisation

### Syntaxe
```bash
./env_validator.sh [fichier_json]
```

### Exemples

1. **Utilisation avec fichier par défaut (config.json):**
```bash
./env_validator.sh
```

2. **Utilisation avec un fichier spécifique:**
```bash
./env_validator.sh mon_config.json
```

3. **Afficher l'aide:**
```bash
./env_validator.sh --help
```

## Format du fichier JSON

Le fichier JSON doit contenir des paires clé-valeur :

```json
{
  "DATABASE_URL": "postgresql://user:password@localhost:5432/mydb",
  "API_KEY": "abc123def456",
  "DEBUG_MODE": "true",
  "PORT": "8080",
  "LOG_LEVEL": "info",
  "CACHE_TTL": "3600"
}
```

## Fonctions du script

1. **`read_json_file()`** - Lit et parse le fichier JSON
2. **`check_environment_variables()`** - Vérifie la concordance
3. **`show_warnings()`** - Affiche les warnings
4. **`override_incorrect_variables()`** - Surcharge les variables
5. **`validate_and_sync_environment()`** - Fonction globale d'orchestration
6. **`main()`** - Point d'entrée principal

## Exemple de sortie

```
=== Début de la validation et synchronisation des variables d'environnement ===

Lecture du fichier JSON: config.json
  Variable JSON trouvée: DATABASE_URL = postgresql://user:password@localhost:5432/mydb
  Variable JSON trouvée: API_KEY = abc123def456
  Variable JSON trouvée: DEBUG_MODE = true
  Variable JSON trouvée: PORT = 8080
  Variable JSON trouvée: LOG_LEVEL = info
  Variable JSON trouvée: CACHE_TTL = 3600
Total de variables JSON trouvées: 6

Vérification des variables d'environnement...
  Variable 'DATABASE_URL' non définie dans l'environnement
  Variable 'API_KEY' non définie dans l'environnement
  ✓ 'DEBUG_MODE' correspond
  Discordance détectée pour 'PORT':
    JSON: 8080
    ENV:  3000
  Variable 'LOG_LEVEL' non définie dans l'environnement
  Variable 'CACHE_TTL' non définie dans l'environnement
Vérification terminée. Discordances trouvées: 5

=== WARNINGS - Variables incorrectes ===
⚠️  Variable: DATABASE_URL
   Valeur JSON: postgresql://user:password@localhost:5432/mydb
   Valeur ENV:  (non définie)

⚠️  Variable: API_KEY
   Valeur JSON: abc123def456
   Valeur ENV:  (non définie)

⚠️  Variable: PORT
   Valeur JSON: 8080
   Valeur ENV:  3000

⚠️  Variable: LOG_LEVEL
   Valeur JSON: info
   Valeur ENV:  (non définie)

⚠️  Variable: CACHE_TTL
   Valeur JSON: 3600
   Valeur ENV:  (non définie)

Total de variables à corriger: 5

=== Surcharge des variables incorrectes ===
✓ Variable 'DATABASE_URL' surchargée:
   Ancienne valeur: (non définie)
   Nouvelle valeur: postgresql://user:password@localhost:5432/mydb

✓ Variable 'API_KEY' surchargée:
   Ancienne valeur: (non définie)
   Nouvelle valeur: abc123def456

✓ Variable 'PORT' surchargée:
   Ancienne valeur: 3000
   Nouvelle valeur: 8080

✓ Variable 'LOG_LEVEL' surchargée:
   Ancienne valeur: (non définie)
   Nouvelle valeur: info

✓ Variable 'CACHE_TTL' surchargée:
   Ancienne valeur: (non définie)
   Nouvelle valeur: 3600

Total de variables surchargées: 5

=== Validation et synchronisation terminées ===
```

## Notes importantes

- Le script ne s'exécute que s'il est lancé directement (pas sourcé)
- Les variables sont exportées dans l'environnement du processus courant
- Le script utilise des couleurs pour une meilleure lisibilité
- Tous les messages d'erreur sont affichés en rouge
- Les warnings sont affichés en jaune
- Les succès sont affichés en vert

## Exécution sous WSL

Pour exécuter le script sous WSL depuis Windows :

```bash
# Dans WSL (CentOS/RHEL)
chmod +x env_validator.sh
./env_validator.sh
```

Le script est optimisé pour RHEL 9 (cible principale) et fonctionne parfaitement sous WSL avec une distribution RHEL/CentOS.

## Tests

### Tests automatisés avec GitHub Actions

Le projet inclut un workflow GitHub Actions complet qui teste le script sur différentes versions de CentOS/RHEL :

- **RHEL 9 (cible principale)** : Tests complets et scénarios avancés
- **Tests de performance** : Avec des fichiers JSON volumineux
- **Tests d'erreur** : Gestion des cas d'échec
- **Tests alternatifs** : Sur Ubuntu pour compatibilité maximale

### Tests locaux

#### Test unitaire des fonctions
```bash
# Rendre le script de test exécutable
chmod +x TEST/test-functions.sh

# Exécuter tous les tests unitaires
./TEST/test-functions.sh
```

#### Tests manuels avec différents scénarios
```bash
# Test avec JSON vide
./env_validator.sh TEST/scenarios/test-empty.json

# Test avec une seule variable
./env_validator.sh TEST/scenarios/test-single.json

# Test avec scénario complexe
./env_validator.sh TEST/scenarios/test-complex.json

# Test avec JSON invalide (doit échouer)
./env_validator.sh TEST/scenarios/test-invalid.json
```

### Scénarios de test inclus

1. **Fichier JSON valide** - Test de base avec `config.json`
2. **Fichier JSON manquant** - Vérification de la gestion d'erreur
3. **JSON invalide** - Test de robustesse
4. **JSON vide** - Test avec objet vide
5. **Variables discordantes** - Test de détection des différences
6. **Variables manquantes** - Test de variables non définies
7. **Surcharge de variables** - Test de remplacement
8. **Performance** - Test avec 100+ variables
9. **Gestion d'erreurs** - Test sans `jq` installé
10. **Sourcing** - Vérification que le script ne s'exécute pas quand sourcé

### Exécution des tests

```bash
# Tests complets (nécessite jq)
./TEST/test-functions.sh

# Test spécifique
./env_validator.sh TEST/scenarios/test-complex.json

# Test d'aide
./env_validator.sh --help
```

### Structure des tests

```
TEST/
├── test-functions.sh          # Tests unitaires des fonctions
├── test-config.json           # Configuration de test
└── scenarios/
    ├── test-empty.json        # JSON vide
    ├── test-single.json       # Une seule variable
    ├── test-complex.json      # Scénario complexe
    └── test-invalid.json      # JSON invalide
```
