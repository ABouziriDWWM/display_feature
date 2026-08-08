# language: fr

Fonctionnalité: Accès par nom propre (pas IP) + HTTPS local + PWA installable sur réseau local offline (meilleur scénario unique retenu)
    Et le contexte suivant s'applique.
    """
  Afin de remplacer une adresse IP locale illisible par un nom compréhensible, d'activer HTTPS local, d'installer la PWA et de garder tout le service fonctionnel — même SANS connexion Internet
  En tant que gérant et exploitant
  Je veux déployer cette fonctionnalité en moins d'une heure, sans Raspberry Pi, sans serveur dédié, sans matériel supplémentaire, et avec le minimum de réglages sur chaque appareil

    """
  Scénario: [MEILLEUR SCÉNARIO UNIQUE — Faisabilité minimale, de bout en bout] Nom propre + HTTPS + PWA 100% local, SANS matériel supplémentaire
    Étant donné l'environnement suivant (hypothèses minimales déjà présentes dans 99 % des cafés).
    """
    - Un PC caisse Windows avec WAMP installé et l'application qui marche en http://localhost/
    - Une box Internet / routeur allumée (même SANS abonnement Internet pour l'étape test)
    - Au moins 1 téléphone Android 12+ OU iPhone sur le WiFi du café
    - Aucun Raspberry Pi, aucun serveur dédié, aucun logiciel payant
    """
    Quand j'exécute les étapes suivantes (durée totale ~45 à 60 min).
    """
    1. Installer Bonjour Print Services sur le PC caisse (active le nom .local via mDNS)       → 5 min
    2. (Optionnel seulement si Android < 12:) dans la box → IP fixe DHCP + DNS local "caisse.cafe.local" → 10 min
    3. Installer mkcert, générer certificat wildcard et configurer SSL dans Apache WAMP       → 15 min
    4. Déployer le fichier rootCA.pem de mkcert sur TOUS les téléphones + PC du service (1 fois au déploiement) → 15 min
    5. Ajouter dans le projet le manifest.json + le service-worker.js de la PWA                → 10 min
    """
    Alors je vérifie le scénario de bout en bout depuis un téléphone du service connecté au WiFi du café.
    """
    Ouverture de l'URL :
      https://caisse-centrale.local    (ou https://caisse.cafe.local si étape 2 a été activée pour Android ancien)

    Résultats attendus :
    - Le cadenas VERT s'affiche : HTTPS est valide, PAS d'erreur de certificat
    - La page de login de l'application se charge correctement (HTML / CSS / JS intègres)
    - Le navigateur propose d'"Installer l'application" (Chrome/Edge desktop) ou bien "Ajouter à l'écran d'accueil" (mobile)
    - Après installation, une icône "Caisse Café" apparaît sur l'écran d'accueil du téléphone ou dans le menu Démarrer du PC
    - Quand je lance l'appli via cette icône, elle s'ouvre en PLEIN ÉCRAN, sans barre d'adresse (mode standalone attendu par la PWA)
    - Si je coupe INTERNET sur la box (par exemple je débranche la fibre), mais que je garde le WiFi allumé :
        → https://caisse-centrale.local continue de FONCTIONNER : on reste en réseau local entre les appareils
        → La PWA reste ouverte et les pages/assets statiques se chargent via le service worker
        → Les actions métier (ajout article, marquer À servir, marquer Servi, paiement espèces) continuent d'être enregistrées et passent automatiquement par la file d'attente IndexedDB de la capacité "hors_ligne_synchronisation" ; elles seront rejouées dans l'ordre dès que le serveur local WAMP sera joignable à nouveau

    Conclusion : faisabilité validée.
    Le chemin minimal retenu — mDNS .local via Bonjour + certificat wildcard mkcert + déploiement de la CA racine sur appareils + manifest/service-worker PWA — permet d'obtenir :
      - Un nom propre lisible (pas d'IP à retenir)
      - HTTPS valide (cadenas vert) partout
      - Une application installable (PWA) sur mobile et PC
      - Un fonctionnement 100 % local, hors-ligne vis-à-vis d'Internet
      - Le tout pour environ 45 à 60 minutes, sans matériel supplémentaire, sans toucher au routeur dans le cas général (iPhone / Android 12+).
    """
