# language: fr

Fonctionnalité: Connexion gérant par email/mot de passe
    Et le contexte suivant s'applique.
    """
  Afin d'accéder aux fonctions d'administration du café
  En tant que gérant
  Je veux pouvoir me connecter avec mon email et mon mot de passe et être dirigé vers l'interface gérant

    """
  Scénario: [Login réussi] Gérant se connecte avec des identifiants valides
    Étant donné un compte gérant actif avec email "gerant@cafe.fr" et mot de passe "AdminPass123"
    Quand je me connecte avec l'email "gerant@cafe.fr" et le mot de passe "AdminPass123"
    Alors je dois être connecté avec le rôle "GERANT"
    Et je dois être redirigé vers le tableau de bord gérant

  Scénario: [Login échoué] Gérant utilise un mauvais mot de passe
    Étant donné un compte gérant actif avec email "gerant@cafe.fr" et mot de passe "AdminPass123"
    Quand je me connecte avec l'email "gerant@cafe.fr" et le mot de passe "MauvaisPass"
    Alors je dois voir un message d'erreur "Identifiants invalides"
    Et je ne dois pas être redirigé hors de la page de login

  Scénario: [Login échoué] Email inconnu
    Quand je me connecte avec l'email "inconnu@cafe.fr" et le mot de passe "AdminPass123"
    Alors je dois voir un message d'erreur "Identifiants invalides"

  Scénario: [Compte inactif] Gérant avec compte désactivé ne peut pas se connecter
    Étant donné un compte gérant inactif avec email "ancien@cafe.fr"
    Quand je me connecte avec l'email "ancien@cafe.fr" et le mot de passe "AncienPass"
    Alors je dois voir un message d'erreur "Identifiants invalides"

  Scénario: [Redirection de rôle] Un serveur qui passe par l'onglet gérant est détecté
    Étant donné un compte serveur "Sofia" (role SERVEUR)
    Quand je me connecte via l'onglet gérant avec identifiant serveur / mot de passe
    Alors le système refuse la connexion avec "Compte gérant requis"
    Et aucune session gérant n'est ouverte

  Scénario: [Champs vides] Impossible de se connecter sans identifiants
    Quand je valide le formulaire gérant sans email ni mot de passe
    Alors je dois voir un message "Identifiants requis"

  Scénario: [CSRF] Après login réussi, un jeton CSRF est récupéré
    Quand je me connecte en gérant avec succès
    Alors un jeton CSRF est stocké pour la session
    Et les requêtes suivantes utilisent ce jeton
