# language: fr

Fonctionnalité: WebSocket temps réel multi-appareils
    Et le contexte suivant s'applique.
    """
  Afin que gérant, tous les serveurs et l'écran cuisine soient synchronisés sans rafraîchir manuellement
  En tant que multi-utilisateurs (gérant, serveur, éventuellement affichage cuisine)
  Je veux qu'un événement produit sur un appareil soit instantanément répercuté sur tous les autres appareils du même café

    """
  Scénario: [Connexion WS] Tous les clients se connectent au serveur WS sur le réseau local
  Et le contexte suivant s'applique.
  """
    Au chargement de l'application, chaque client (gérant, serveur) ouvre une connexion WebSocket
    vers ws://192.168.1.20:3000 (ou wss://ws.caisse.cafe si HTTPS local)
  """
    Et envoie son cafe_id + rôle + device_serial dans un message "hello"

  Et le contexte suivant s'applique.
  """
    Le serveur WS l'ajoute à la room du café correspondant

  """
  Scénario: [Broadcast] Ajout d'article répercuté sur tous les postes
  Et le contexte suivant s'applique.
  """
    Sur l'appareil du serveur Sofia (poste A), Sofia ajoute 1 "Coca" sur la table T4
  """
    Alors l'API PHP POST crée l'item et publie un événement ORDER_ITEM_CHANGED vers le serveur WS
    Et le serveur WS broadcast l'événement sur la room du café

  Et le contexte suivant s'applique.
  """
    Résultat sur les autres appareils:
      - Le poste gérant voit apparaître la ligne Coca dans T4 (ardoise Dernière ardoise si ouverte)
      - Le 2e serveur (David) voit l'ardoise T4 se mettre à jour automatiquement (s'il la visualise)
      - Toutes les cartes tables montrent T4 avec badge à jour

  """
  Scénario: [Broadcast] Statut table A_SERVIR → tous les postes voient immédiatement
    Quand Sofia clique sur "À servir" sur T4
    Alors l'événement TABLE_STATUS_CHANGED est publié
    Et sur le gérant, T4 passe immédiatement en badge "À servir"
    Et le bouton "Servir" du gérant devient activé pour T4

  Scénario: [Broadcast] Gérant clique Servir → ligne verte disparaît sur serveurs
    Quand le gérant clique sur "Servir" sur T4
    Alors l'événement TABLE_STATUS_CHANGED(SERVIT) + ORDER_UPDATED est broadcast
    Et sur tous les postes.

  Et le contexte suivant s'applique.
  """
      - T4 passe badge "Servit"
      - Les lignes vertes de l'ardoise redeviennent normales (to_serve=0)
      - Les boutons paiement (cash/CB) côté serveur deviennent activables

  """
  Scénario: [Broadcast] Paiement encaissé → table devient PAYE partout
    Quand un paiement est validé (événement PAYMENT)
    Alors la table passe PAYE sur TOUS les postes
    Et l'ardoise correspondante affiche "Payée" + bouton Imprimer activé

  Scénario: [Rooms] 2 cafés différents ne se voient pas (multi-tenancy)

  Et le contexte suivant s'applique.
  """
    Café "Le Central" (cafe_id=1) et café "Le Relais" (cafe_id=2)
    Chaque client est dans sa room dédiée: cafe_1 et cafe_2
    Un événement émis depuis cafe_1 n'est JAMAIS reçu par cafe_2

  """
  Scénario: [Reconnexion WS] Reconnexion automatique en cas de coupure réseau
  Et le contexte suivant s'applique.
  """
    Si la connexion WS coupe pendant 30 secondes (Wi-Fi instable)
  """
    Alors le client reconnecte automatiquement sans intervention utilisateur
    Et il renvoie son hello + rattrape les événements manqués via un numéro de séquence
    Et les données affichées sont cohérentes à nouveau

  Scénario: [Fallbacks] Si le WS n'est pas joignable, on retombe sur le polling 10s existant
  Et le contexte suivant s'applique.
  """
    Si le serveur WebSocket n'est pas démarré ou le port fermé
  """
    Alors l'application continue de fonctionner grâce au setInterval de refresh 10s
    Et l'utilisateur voit un badge "Temps réel indisponible" (jaune) mais peut travailler

  Scénario: [Transports] API PHP publie les événements vers serveur WS via HTTP POST ou Redis/fichier
  Et le contexte suivant s'applique.
  """
    Depuis les contrôleurs PHP (TableController markAServir/markServi, OrderController addItem/pay, etc.)
    Une publication simple est envoyée:
      - soit un fichier de notification append-only (pickle/JSON line) lu par un process Node en watch
      - soit un POST interne de PHP vers Node sur http://localhost:3000/publish
      - soit Redis Pub/Sub (si Redis installé)
    Le serveur Node/Ws relaie ensuite à tous les clients connectés
  """
