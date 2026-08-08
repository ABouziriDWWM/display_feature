# language: fr

Fonctionnalité: Gestion CRUD des tables (par libellé et zone)
    Et le contexte suivant s'applique.
    """
  Afin d'organiser le plan du café
  En tant que gérant
  Je veux pouvoir créer, consulter, supprimer des tables et les grouper par zone

    """
  Scénario: [Création] Gérant crée une table avec libellé et zone
    Étant donné une session gérant active
    Quand je crée une table avec libellé "T12" et zone "Terrasse"
    Alors la table "T12" apparaît dans la zone "Terrasse"
    Et le statut initial de la table est "Libre"

  Scénario: [Création] Libellé vide interdit
    Quand je crée une table avec un libellé vide
    Alors une erreur "Libellé requis" s'affiche
    Et aucune nouvelle table n'est créée

  Scénario: [Création] Zone par défaut "zone 0" quand aucune zone n'est saisie
    Quand je crée une table "B3" sans saisir de zone
    Alors la table "B3" est placée dans la zone "zone 0"

  Scénario: [Consultation] Les tables sont groupées par zone, triées alphabétiquement
    Étant donné les tables suivantes existent.
      | libelle | zone       |
      | T1      | Salon      |
      | T2      | Salon      |
      | T10     | Terrasse   |
      | B1      | zone 0     |
    Quand j'affiche la liste des tables
    Alors les en-têtes de zone apparaissent dans l'ordre: "Salon", "Terrasse", "zone 0"
    Et chaque zone contient ses tables respectives

  Scénario: [Suppression] Suppression d'une table LIBRE (sans ardoise)
    Étant donné une table "X99" au statut "LIBRE"
    Quand je saisis "X99" dans le champ libellé et clique sur "Supprimer"
    Alors la table "X99" est supprimée définitivement
    Et un message "Table supprimée" s'affiche

  Scénario: [Suppression] Échec de suppression si la table n'est pas LIBRE
    Étant donné une table "T7" occupée (ardoise en cours, non payée)
    Quand je tente de supprimer "T7"
    Alors je vois l'indicateur "Ardoise non payée"
    Et le bouton Supprimer est désactivé
    Et la table "T7" n'est pas supprimée

  Scénario: [Suppression] Suppression forcée d'une table libre via vrai booléen
    Étant donné une table "Z9" au statut LIBRE sans commande associée
    Quand je demande la suppression forcée de Z9
    Alors la table Z9 est supprimée immédiatement

  Scénario: [Intégrité] Impossible de supprimer une table ayant un historique de commandes ouvertes
    Étant donné une table "H5" avec une commande ouverte
    Quand je tente de la supprimer
    Alors une erreur "Ardoise non payée — suppression impossible" est renvoyée
    Et la table H5 reste en base

  Scénario: [Recherche par libellé] Indicateur de suppression se met à jour à la saisie
    Quand je saisis un libellé qui correspond à une table occupée
    Alors l'indicateur rouge "Ardoise non payée" apparaît automatiquement
    Et le bouton Supprimer devient désactivé
