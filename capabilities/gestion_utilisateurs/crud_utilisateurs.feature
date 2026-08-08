# language: fr

Fonctionnalité: Gestion des utilisateurs (gérants et serveurs)
    Et le contexte suivant s'applique.
    """
  Afin de gérer le personnel du café
  En tant que gérant
  Je veux créer, modifier, activer/désactiver et supprimer des comptes utilisateurs

    """
  Scénario: [Création] Créer un compte serveur
    Étant donné une session gérant active
    Quand je crée un utilisateur.
      | name   | email              | role    | password   |
      | Sofia  | sofia@cafe.fr      | SERVEUR | Serveur123 |
    Alors le compte Sofia apparaît dans la liste
    Et Sofia peut se connecter via PIN éphémère (ou mot de passe selon mode)

  Scénario: [Création] Créer un compte gérant
    Quand je crée un utilisateur.
      | name   | email              | role   | password   |
      | Laura  | laura@cafe.fr      | GERANT | Laura12345 |
    Alors Laura apparaît dans la liste avec rôle GERANT
    Et elle peut se connecter par email/mot de passe depuis un appareil autorisé

  Scénario: [Mot de passe] Mot de passe stocké haché (jamais en clair)
    Quand je crée un utilisateur avec un mot de passe
    Alors password_hash est haché via l'algorithme de SecurityService
    Et je ne peux plus retrouver le mot de passe en clair dans la base

  Scénario: [Désactivation] Désactiver un compte (ex: départ)
    Étant donné Sofia active
    Quand je passe active=0 sur Sofia
    Alors Sofia ne peut plus se connecter
    Et une tentative renvoie "Identifiants invalides" ou équivalent

  Scénario: [Liste] Table utilisateurs affichant nom, email, rôle, actif
  Et le contexte suivant s'applique.
  """
    La page Utilisateurs du gérant liste tous les comptes
    Avec: nom, email, rôle (badge), actif (switch/icône), boutons Éditer/Supprimer
  """
    Et on peut filtrer / trier par nom ou rôle

  Scénario: [Unicité] Email ou identifiant non dupliqué
    Quand je crée un utilisateur avec un email déjà existant
    Alors la création est rejetée avec erreur "Email déjà utilisé"
  Et le contexte suivant s'applique.
  """
    Aucun doublon d'email n'existe dans la table users
  """
