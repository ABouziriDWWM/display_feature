# language: fr

Fonctionnalité: Ouverture, fermeture de caisse et mouvements
    Et le contexte suivant s'applique.
    """
  Afin de garantir la cohérence financière d'une journée de service
  En tant que gérant
  Je veux ouvrir une caisse, enregistrer les dépôts/retraits et la fermer avec un rapport final

    """
  Scénario: [Ouverture] Ouverture d'une caisse en début de journée
    Étant donné une caisse fermée
    Et un solde d'ouverture saisi de 300.00€ (fonds de caisse)
    Quand je valide l'ouverture du shift
    Alors un nouveau shift est créé (statut ouvert)

  Et le contexte suivant s'applique.
  """
    Avec utilisateur gérant, opened_at, start_amount

  """
  Scénario: [Mouvement] Ajout d'un dépôt pendant le shift
    Étant donné un shift ouvert
    Quand j'ajoute un mouvement "DEPOT" de 50€
    Alors un cash_movement est enregistré DEPOT +50€
    Et le solde théorique augmente de 50€

  Scénario: [Mouvement] Retrait pendant le shift
    Quand j'ajoute un mouvement "RETRAIT" de 20€ motif "achat consommables"
    Alors un cash_movement est enregistré RETRAIT -20€

  Et le contexte suivant s'applique.
  """
    Avec description "achat consommables"

  """
  Scénario: [Fermeture] Clôture d'un shift avec rapprochement
  Et le contexte suivant s'applique.
  """
    En fin de journée:
    - Solde théorique = fonds de départ + encaissements + dépôts - retraits
    - Solde compté saisi = montant réellement présent dans la caisse
  """
    Quand je valide la fermeture
    Alors closed_at est horodaté
    Et end_amount = solde compté
    Et l'écart est calculé (différence théorique vs compté)
    Et un rapport de fermeture est généré (fichier export)

  Scénario: [Contrôle] Impossible d'ouvrir 2 shifts actifs en même temps pour le même café
    Étant donné un shift déjà ouvert
    Quand je tente d'ouvrir un 2e shift
    Alors l'ouverture est refusée avec "Caisse déjà ouverte"

  Scénario: [Contrôle] Impossibilité de paiements hors shift
  Et le contexte suivant s'applique.
  """
    Si aucun shift n'est ouvert
  """
    Alors tout paiement est refusé tant que la caisse n'est pas ouverte
    Et un message demande d'ouvrir la caisse
