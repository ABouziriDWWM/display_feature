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
    Alors je constate que le <head> contient un lien vers manifest.json.
    Et alors je constate que les meta tags theme-color / apple-touch-icon sont présents.
    Et alors je constate que le manifest déclare name="Caisse Café", short_name, start_url, display="standalone", theme_color, background_color, icônes multiples.

  Scénario: [Installabilité] Service Worker enregistré au chargement
    Quand je décide de charger la page pour la première fois.
    Alors je constate que le navigateur enregistre sw.js.
    Et alors je constate que le Service Worker devient contrôleur de la page.
    Et alors je constate que dans Chrome/Edge le bouton "Installer l'application" apparaît dans la barre d'adresse.

  Scénario: [Installabilité] Installation de l'app depuis Chrome/Edge sur PC
    Étant donné que l'application est servie en HTTPS et que le SW est enregistré
    Quand l'utilisateur clique sur "Installer l'application" + accepte la modale Chrome
    Alors la popup d'installation PWA (Chrome/Edge) doit être installable et s'ajouter au menu Démarrer
    Et PWA doit être installable

  Scénario: [Installabilité] Installation sur Android via Chrome
    Quand je décide de visiter l'app depuis un Android avec Chrome.
    Et que HTTPS + SW + manifest sont OK
    Alors je constate qu'une bannière "Ajouter à l'écran d'accueil" est proposée.
    Et alors je constate qu'une icône apparaît sur l'écran d'accueil du téléphone.
    Et alors je constate que l'app s'ouvre en plein écran sans chrome navigateur.

  Scénario: [Offline] Premier chargement avec réseau OK, puis hors ligne
    Étant donné que j'ai déjà chargé l'application une fois avec le réseau
    Et que le Service Worker a mis en cache les assets essentiels (HTML/CSS/JS/manifest)
    Quand je décide de couper le réseau et de rafraîchir la page.
    Alors je constate que les pages principales (login, gérant/tables, serveur/commandes) continuent de s'afficher.
    Et alors je constate que le layout + styles sont corrects (pas d'erreur 404 sur CSS/JS).

  Scénario: [Offline] API GET mises en cache (hors-ligne lecture)
    Étant donné que j'ai déjà chargé la liste des tables / produits une fois
    Et que le réseau est coupé
    Quand je décide de consulter à nouveau la liste des tables.
    Alors je constate que les données précédentes sont lues depuis le cache (stratégie network-first fallback cache).
    Et alors je constate qu'un petit badge indique "Mode hors-ligne — données potentiellement périmées".

  Scénario: [Offline] API POST: tentatives de paiement hors ligne mises en file d'attente
  Et le contexte suivant s'applique.
  """
    Si le réseau est coupé au moment d'un paiement
  """
    Alors je constate que l'utilisateur est prévenu "Paiement en attente — rejoué automatiquement au retour réseau".
    Et alors je constate que l'action est ajoutée à la queue IndexedDB (via BackgroundSync si dispo).
    Et alors je constate qu'au retour réseau, les paiements sont rejoués dans l'ordre.

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
    Alors je constate que dans les 2 cas: manifest + SW fonctionnent.
    Et alors je constate que l'installabilité fonctionne (localhost est secure context).
