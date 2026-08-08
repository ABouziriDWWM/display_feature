# language: fr

Fonctionnalité: Méthodes de paiement et journalisation
    Et le contexte suivant s'applique.
    """
  Afin d'assurer la traçabilité financière
  En tant que gérant
  Je veux que chaque paiement soit journalisé avec sa méthode, son montant et l'utilisateur qui a encaissé

    """
  Scénario: [Journal] Chaque paiement crée une ligne payments avec order_id + method + paid_at
    Quand un paiement est validé (cash/card/mixed)
    Alors une ligne est insérée dans la table payments
  Et le contexte suivant s'applique.
  """
    Avec order_id, method, amount, paid_at (NOW()), nom de l'agent (si colonne nom)
  """
    Et le cafe_id (si colonne cafe_id)

  Scénario: [Cohérence] Paiement impossible si commande introuvable
    Quand j'essaie de payer un order_id qui n'existe pas
    Alors je reçois "Commande introuvable"
    Et aucun paiement n'est enregistré

  Scénario: [Synthèse] Mouvements de caisse liés aux paiements

  Et le contexte suivant s'applique.
  """
    Chaque paiement CASH ajoute un mouvement de caisse entrant "encaissement"
    Chaque paiement CARD ajoute un mouvement de caisse "CB"
    Chaque paiement MIXED ajoute 2 mouvements fractionnés selon espèce/CB

  """
  Scénario: [Rapprochement] Rapport de fin de journée somme par méthode
  Et le contexte suivant s'applique.
  """
    À la fermeture de caisse, le rapport indique:
    - Total espèces
    - Total CB
    - Total MIXED (détaillé espèce vs CB)
    - Grand total correspondant à la somme des paiements enregistrés
  """
