# language: fr

Fonctionnalité: PWA installable et mode hors-ligne (manifest + service worker)
    Et le contexte suivant s'applique.
    """
  Afin d'utiliser l'application caisse comme une app native sur téléphone et PC, et continuer à travailler pendant une coupure réseau
  En tant que gérant, serveur
  Je veux installer l'application sur mon appareil, la lancer en plein écran, et que les pages/assets essentiels soient disponibles sans Internet

    """
  Scénario: [Installabilité] manifest.json est bien lié dans le <head> des pages
    Étant donné une page gérant tables.php ou une page serveur commandes.php
    Alors le <head> contient un lien vers manifest.json
    Et les meta tags theme-color / apple-touch-icon sont présents
    Et le manifest déclare name="Caisse Café", short_name, start_url, display="standalone", theme_color, background_color, icônes multiples

  Scénario: [Installabilité] Service Worker enregistré au chargement
    Quand je charge la page pour la première fois
    Alors le navigateur enregistre sw.js
    Et le Service Worker devient contrôleur de la page
    Et dans Chrome/Edge le bouton "Installer l'application" apparaît dans la barre d'adresse

  Scénario: [Installabilité] Installation de l'app depuis Chrome/Edge sur PC
    Étant donné que l'application est servie en HTTPS et que le SW est enregistré
    Quand je clique sur "Installer Caisse Café"
    Alors l'application est ajoutée au menu Démarrer / Bureau
    Et je peux la lancer comme une app classique (fenêtre standalone, pas d'onglet)

  Scénario: [Installabilité] Installation sur Android via Chrome
    Quand je visite l'app depuis un Android avec Chrome
    Et que HTTPS + SW + manifest sont OK
    Alors une bannière "Ajouter à l'écran d'accueil" est proposée
    Et une icône apparaît sur l'écran d'accueil du téléphone
    Et l'app s'ouvre en plein écran sans chrome navigateur

  Scénario: [Offline] Premier chargement avec réseau OK, puis hors ligne
    Étant donné que j'ai déjà chargé l'application une fois avec le réseau
    Et que le Service Worker a mis en cache les assets essentiels (HTML/CSS/JS/manifest)
    Quand je coupe le réseau et que je rafraîchis
    Alors les pages principales (login, gérant/tables, serveur/commandes) continuent de s'afficher
    Et le layout + styles sont corrects (pas d'erreur 404 sur CSS/JS)

  Scénario: [Offline] API GET mises en cache (hors-ligne lecture)
    Étant donné que j'ai déjà chargé la liste des tables / produits une fois
    Et que le réseau est coupé
    Quand je consulte à nouveau la liste des tables
    Alors les données précédentes sont lues depuis le cache (stratégie network-first fallback cache)
    Et un petit badge indique "Mode hors-ligne — données potentiellement périmées"

  Scénario: [Offline] API POST: tentatives de paiement hors ligne mises en file d'attente
  Et le contexte suivant s'applique.
  """
    Si le réseau est coupé au moment d'un paiement
  """
    Alors l'utilisateur est prévenu "Paiement en attente — rejoué automatiquement au retour réseau"
    Et l'action est ajoutée à la queue IndexedDB (via BackgroundSync si dispo)
    Et au retour réseau, les paiements sont rejoués dans l'ordre

  Scénario: [Manifest] Icônes multiples et splash screen
  Et le contexte suivant s'applique.
  Étant donné le contexte suivant :
  """
    Le manifest.json contient au minimum:
  """
  Étant donné les données tabulaires suivantes :
      | tailles      | usage                              |
      | 192x192      | icône Android + badge              |
      | 512x512      | icône d'installation + splash      |
    Et le theme_color est conforme au design tokens (couleur primaire du café)

  Scénario: [Compatibilité] localhost est considéré comme secure context pour le dev
  Et le contexte suivant s'applique.
  """
    Pendant le développement, l'application tourne en http://localhost ou en HTTPS local via mkcert
  """
    Et dans les 2 cas: manifest + SW fonctionnent
    Et l'installabilité fonctionne (localhost est secure context)
