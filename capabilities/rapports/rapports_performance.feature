# language: fr

Fonctionnalité: Rapports, performances et historiques
    Et le contexte suivant s'applique.
    """
  Afin de suivre l'activité du café et les performances du service
  En tant que gérant
  Je veux consulter les rapports journaliers, par période et par serveur

    """
  Scénario: [Performance serveur] Rapport performance par serveur sur une journée
    Étant donné une date du "2026-03-20"
    Et Sofia a encaissé 1200€ sur 45 commandes
    Et David a encaissé 900€ sur 30 commandes
    Quand je consulte le rapport "Performance serveurs" du 2026-03-20
    Alors j'obtiens.
      | serveur | commandes_payees | chiffre_affaires |
      | Sofia   | 45               | 1200.00          |
      | David   | 30               | 900.00           |
    Et le total CA global de la journée s'affiche en haut du rapport

  Scénario: [Historique ventes] Synthèse par produit sur une période
    Quand je demande le rapport "Top produits" sur 7 jours glissants
    Alors les produits sont triés par chiffre d'affaires décroissant

  Et le contexte suivant s'applique.
  """
    Avec: nom produit, quantité totale vendue, CA HT, CA TTC

  """
  Scénario: [Filtrage dates] Rapports avec plage "from" et "to"
    Quand je sélectionne du "2026-03-01" au "2026-03-31"
    Alors le rapport ne prend en compte que les paiements payés entre ces dates (paid_at)

  Scénario: [Export] Export Excel des rapports de fermeture de caisse
  Et le contexte suivant s'applique.
  """
    À chaque fermeture de caisse (shift fermé)
  """
    Alors un fichier .xlsx est généré dans le dossier exports
    Et contient: paiements détaillés, totaux par méthode, mouvements de caisse, performance serveurs

  Scénario: [Dashboard] Vue d'ensemble du jour (dashboard gérant)
    Quand j'arrive sur le dashboard gérant
    Alors j'affiche.
  Et le contexte suivant s'applique.
  """
    - Nombre de tables en cours / libres / à servir / servies
    - CA encaissé depuis ouverture
    - Nombre de commandes payées
    - Top 5 produits du moment
  """
