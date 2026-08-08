# language: fr

Fonctionnalité: Application bureau / desktop (PWA installable + option Electron/Tauri)
    Et le contexte suivant s'applique.
    """
  Afin d'utiliser la caisse comme une application native sur le poste caisse Windows du café
  En tant que gérant ou caissier
  Je veux pouvoir lancer la caisse depuis une icône du bureau, dans une fenêtre dédiée, et éventuellement embarquer le serveur local

    """
  Scénario: [Desktop PWA] Chrome/Edge installent l'app sur Windows
    Étant donné Chrome ou Edge sur Windows 10/11
    Et HTTPS + manifest + service worker sont présents
    Quand je clique sur "Installer Caisse Café" dans le menu du navigateur
    Alors une icône "Caisse Café" est ajoutée au bureau et au menu Démarrer
    Et l'application s'ouvre dans une fenêtre standalone sans barre d'adresse
    Et la taille fenêtre est mémorisée (width/height)

  Scénario: [Desktop PWA] Lancement automatique de l'app caisse après démarrage
  Et le contexte suivant s'applique.
  """
    Je peux ajouter le raccourci PWA "Caisse Café" dans le dossier shell:startup de Windows
  """
    Et l'application se lance automatiquement à l'ouverture de session du poste caisse

  Scénario: [Desktop PWA] Icône barre des tâches + badge
    Quand l'app PWA est ouverte
    Alors elle apparaît dans la barre des tâches Windows comme toute application native
    Et un badge peut être affiché (ex: nombre de tables "À servir" en attente)

  Scénario: [Option Electron] Packaging .exe avec Electron (alternative lourde)
  Et le contexte suivant s'applique.
  """
    Si un besoin de features natives est avéré:
      - Accès direct imprimantes USB / ESC/POS sans navigateur
      - Accès direct au dossier Documents pour exports locaux
  """
    Alors le frontend web est encapsulé dans un conteneur Electron
    Et un serveur PHP local (WAMP embarqué ou serveur PHP interne) est lancé au démarrage
    Et l'Electron main window charge http://localhost:<port>

  Scénario: [Option Tauri] Packaging ultra-léger (alternative moderne Rust)
  Et le contexte suivant s'applique.
  """
    Si on préfère un binaire < 10Mo au lieu de ~150Mo
  """
    Alors on utilise Tauri avec backend Rust
    Et le frontend web chargé est le même que pour la PWA
    Et l'app dispose d'APIs natives (système de fichiers, imprimantes...) via Rust <-> pont JS

  Scénario: [Cohérence UX] Les 3 options (PWA / Electron / Tauri) utilisent le même front
  Et le contexte suivant s'applique.
  """
    La partie PHP backend + Vanilla JS frontend est strictement identique
    Seule change la couche de "packaging"
  """
    Donc 1 seule base de code à maintenir
