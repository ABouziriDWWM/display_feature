# language: fr

Fonctionnalité: Cycle de vie d'une commande / ardoise
    Et le contexte suivant s'applique.
    """
  Afin de matérialiser la consommation d'une table et son encaissement
  En tant que serveur
  Je veux créer une commande quand j'occupe une table, puis la clôturer par un paiement

    """
  Scénario: [Création] Création d'une commande à l'occupation d'une table
    Étant donné une table "T3" LIBRE
    Et un serveur "Sofia" connecté
    Quand Sofia sélectionne T3 et crée une commande
    Alors une nouvelle commande est créée pour T3, attribuée à Sofia
    Et la commande est en statut initial "OCCUPEE" (ou "OUVERT" selon schéma)
    Et T3 passe en statut "OCCUPEE"

  Scénario: [Récupération] Commande ouverte d'une table
    Étant donné une commande ouverte pour la table T3
    Quand je consulte l'ardoise de T3
    Alors la commande ouverte est chargée (pas une dernière payée)
    Et l'ardoise affiche "Non payé"

  Scénario: [Récupération] Dernière commande PAYE si aucune ouverte
    Étant donné une table T3 sans commande ouverte (dernière PAYE)
    Quand je consulte la dernière ardoise de T3
    Alors la dernière commande PAYE de T3 est affichée
    Et le bouton "Imprimer / PDF" est activé

  Scénario: [Fermeture] Paiement clôture la commande en PAYE
    Étant donné une commande ouverte avec des articles
    Quand j'effectue un paiement (quel que soit le moyen)
    Alors la commande passe en statut "PAYE"
    Et sa date closed_at est renseignée
    Et la table liée passe en statut "PAYE"

  Scénario: [Contrainte] Impossible d'ajouter un article sur une commande PAYE ou ANNULEE
    Étant donné une commande #42 en statut "PAYE"
    Quand j'essaie d'ajouter un article sur la commande #42
    Alors une erreur "Commande clôturée" est renvoyée
    Et aucun article n'est ajouté

  Scénario: [Contrainte] Impossible de payer une commande à 0 €
    Étant donné une commande sans article (total = 0)
    Quand je tente d'encaisser
    Alors je dois voir "Montant invalide"
    Et la commande reste ouverte

  Scénario: [Multi-articles] Total recalculé à chaque ajout/suppression d'article
    Étant donné une commande ouverte sur T3
    Quand j'ajoute "Café" à 1.5€
    Et j'ajoute "Formule midi" à 18.0€
    Et je supprime l'article "Café"
    Alors le total affiché de la commande est recalculé à 18.0€ HT (avant TVA)
    Et le montant TTC correspond (TVA applicable)
