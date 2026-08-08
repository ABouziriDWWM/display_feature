# language: fr

Fonctionnalité: Contrôle d'appareil autorisé pour le gérant
    Et le contexte suivant s'applique.
    """
  Afin d'éviter qu'un compte gérant ne soit utilisé depuis n'importe quel poste
  En tant que propriétaire du café
  Je veux que la connexion gérant ne soit autorisée que depuis les appareils déclarés autorisés

    """
  Scénario: [Appareil autorisé] Gérant se connecte depuis un appareil enregistré
    Étant donné un appareil avec device_serial "CAISSE-PRINCIPALE-001" marqué autorisé
    Quand le gérant se connecte depuis cet appareil
    Alors la connexion est acceptée
    Et l'appareil reçoit le rôle gérant

  Scénario: [Appareil non autorisé] Gérant bloqué depuis un appareil inconnu
    Étant donné un appareil avec device_serial "TELEPHONE-INCONNU" non autorisé
    Quand le gérant tente de se connecter depuis cet appareil
    Alors la connexion échoue avec "Appareil non autorisé pour le gérant"
    Et il est redirigé vers login avec reason=bad_device

  Scénario: [Première autorisation] Demande d'autorisation pour un nouvel appareil
    Quand le gérant tente de se connecter depuis un nouvel appareil "NEW-LAPTOP-01"
    Alors l'appareil est ajouté à la liste des appareils en attente
    Et une interface secret permet de valider l'appareil
    Et après validation, l'appareil peut se connecter en tant que gérant

  Scénario: [Journaux de tentatives] Tentative depuis appareil interdit est loguée
    Étant donné un appareil "SUSPICIOUS-123" qui tente de se connecter en gérant
    Quand la tentative échoue pour non autorisation
    Alors une trace est ajoutée dans le journal des tentatives d'appareil

  Scénario: [Serveur non concerné] Le contrôle d'appareil ne s'applique pas aux serveurs
    Étant donné un appareil non autorisé pour le gérant
    Quand un serveur utilise ce même appareil pour se connecter par PIN
    Alors la connexion serveur est autorisée normalement
  Et le contexte suivant s'applique.
  """
    Aucune vérification d'autorisation appareil n'est effectuée
  """
