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
    Quand l'utilisateur clique sur "Installer l'application" + accepte la modale Chrome
    Alors la popup d'installation PWA doit être installable
    Et alors je constate qu'une icône "Caisse Café" est ajoutée au bureau et au menu Démarrer.
    Et alors je constate que l'application s'ouvre dans une fenêtre standalone sans barre d'adresse.
    Et alors je constate que la taille fenêtre est mémorisée (width/height).

  Scénario: [Desktop PWA] Lancement automatique de l'app caisse après démarrage
  Et le contexte suivant s'applique.
  """
    Je peux ajouter le raccourci PWA "Caisse Café" dans le dossier shell:startup de Windows
  """
    Alors je constate que l'application se lance automatiquement à l'ouverture de session du poste caisse.

  Scénario: [Desktop PWA] Icône barre des tâches + badge
    Quand je décide d'ouvrir l'app PWA.
    Alors je constate qu'elle apparaît dans la barre des tâches Windows comme toute application native.
    Et alors je constate qu'un badge peut être affiché (ex: nombre de tables "À servir" en attente).

  Scénario: [Option Electron] Packaging .exe avec Electron (alternative lourde)
  Et le contexte suivant s'applique.
  """
    Si un besoin de features natives est avéré:
      - Accès direct imprimantes USB / ESC/POS sans navigateur
      - Accès direct au dossier Documents pour exports locaux
  """
    Alors je constate que le frontend web est encapsulé dans un conteneur Electron.
    Et alors je constate qu'un serveur PHP local (WAMP embarqué ou serveur PHP interne) est lancé au démarrage.
    Et alors je constate que l'Electron main window charge http://localhost:<port>.

  Scénario: [Option Tauri] Packaging ultra-léger (alternative moderne Rust)
  Et le contexte suivant s'applique.
  """
    Si on préfère un binaire < 10Mo au lieu de ~150Mo
  """
    Alors je constate qu'on utilise Tauri avec backend Rust.
    Et alors je constate que le frontend web chargé est le même que pour la PWA.
    Et alors je constate que l'app dispose d'APIs natives (système de fichiers, imprimantes...) via Rust <-> pont JS.

  Scénario: [Cohérence UX] Les 3 options (PWA / Electron / Tauri) utilisent le même front
  Et le contexte suivant s'applique.
  """
    La partie PHP backend + Vanilla JS frontend est strictement identique
    Seule change la couche de "packaging"
  """
    Alors je constate qu'il y a 1 seule base de code à maintenir.
