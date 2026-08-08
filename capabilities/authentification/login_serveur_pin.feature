# language: fr

Fonctionnalité: Connexion serveur par identifiant + PIN éphémère
    Et le contexte suivant s'applique.
    """
  Afin de prendre des commandes et encaisser pour le service
  En tant que serveur
  Je veux me connecter rapidement via mon identifiant et un PIN à durée de vie limitée

    """
  Scénario: [PIN valide] Serveur se connecte avec un PIN éphémère valide
    Étant donné un compte serveur "Sofia" actif
    Et un PIN éphémère valide "147258" généré pour Sofia
    Quand je me connecte avec identifiant "Sofia" et PIN "147258"
    Alors je suis connecté avec le rôle "SERVEUR"
    Et je suis redirigé vers la page commandes du serveur

  Scénario: [PIN invalide] Serveur utilise un PIN incorrect
    Étant donné un PIN éphémère valide "147258" pour Sofia
    Quand je me connecte avec identifiant "Sofia" et PIN "000000"
    Alors je dois voir l'erreur "PIN invalide ou expiré"

  Scénario: [PIN expiré] Serveur utilise un PIN dont la durée est dépassée
    Étant donné un PIN "999999" créé il y a plus de 15 minutes pour Sofia
    Quand je me connecte avec identifiant "Sofia" et PIN "999999"
    Alors je dois voir l'erreur "PIN invalide ou expiré"

  Scénario: [PIN global gérant] Un serveur peut se connecter via le PIN global d'un gérant
    Étant donné un serveur "Sofia" actif sans PIN éphémère en cours
    Et un PIN global gérant "888888" valide
    Quand je me connecte avec identifiant "Sofia" et PIN global "888888"
    Alors je suis connecté avec le rôle "SERVEUR"

  Scénario: [Identifiant introuvable] Connexion avec identifiant inconnu
    Quand je me connecte avec identifiant "Personne" et PIN "1234"
    Alors je dois voir l'erreur "Utilisateur introuvable"

  Scénario: [Format PIN] PIN non numérique rejeté
    Quand je me connecte avec identifiant "Sofia" et PIN "ABCD"
    Alors je dois voir une erreur de format de PIN

  Scénario: [Redirection de rôle] Un gérant connecté via l'onglet serveur est redirigé
    Étant donné un compte gérant "Ami"
    Et un PIN éphémère généré pour "Ami" (ou accès PIN global)
    Quand je me connecte par l'onglet serveur
    Alors je suis redirigé automatiquement vers l'interface gérant

  Scénario: [Déconnexion] Bouton de déconnexion termine la session
    Étant donné une session serveur active pour Sofia
    Quand je clique sur "Déconnexion"
    Alors la session PHP est détruite
    Et je reviens sur la page de login avec raison "logged_out"
