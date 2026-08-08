# language: fr

Fonctionnalité: Encaissement et méthodes de paiement (Espèces, CB, Mixte)
    Et le contexte suivant s'applique.
    """
  Afin de clôturer une ardoise et enregistrer le paiement
  En tant que serveur ou gérant
  Je veux encaisser par espèce, carte bancaire ou un mix des deux, et produire un reçu

    """
  Scénario: [Paiement] Encaissement complet en espèces
    Étant donné une commande ouverte sur T9 d'un total TTC de 22.50€
    Quand je choisis le paiement "Espèces" pour 22.50€
    Alors la commande passe en statut PAYE
    Et un paiement de 22.50€ en method CASH est enregistré
    Et T9 passe en statut PAYE

  Scénario: [Paiement] Encaissement complet par carte bancaire
    Étant donné une commande ouverte sur T9 d'un total TTC de 22.50€
    Quand je choisis le paiement "Carte"
    Alors la commande passe PAYE
    Et le paiement enregistré a method CARD
    Et T9 passe en statut PAYE

  Scénario: [Paiement] Encaissement mixte
    Étant donné une commande d'un total de 50.00€
    Quand je choisis "Mixte" avec 20€ espèce + 30€ CB
    Alors un paiement MIXED est créé
    Et la commande est PAYE

  Scénario: [Montant] Le montant payé est forcé au montant exact de la commande
    Étant donné une commande de 22.50€
    Quand j'envoie un paiement avec montant saisi = 30.00€ (trop perçu)
    Alors le montant est ramené automatiquement à 22.50€
    Et le paiement enregistré correspond au vrai montant de la commande

  Scénario: [Contraintes] Encaissement interdit si lignes to_serve=1 ET table non SERVIT
    Étant donné T9 en statut A_SERVIR
    Et au moins une ligne verte (to_serve=1)
    Alors les boutons "Payer en espèces" et "Payer CB" sont désactivés
    Et on ne peut pas lancer le paiement

  Scénario: [Contraintes] Table SERVIT → encaissement autorisé même sans autre action
    Étant donné T9 en statut SERVIT
    Et même s'il restait d'anciennes lignes (remises à 0 lors Servi)
    Alors les boutons paiement sont activés
    Et on peut encaisser

  Scénario: [Reçu] Après paiement, l'ardoise PAYE peut être imprimée / exportée PDF
    Étant donné une commande PAYE
    Quand je clique sur "Imprimer / PDF" dans le panneau Dernière ardoise
    Alors une fenêtre d'impression s'ouvre avec le détail.

  Et le contexte suivant s'applique.
  """
    - Intitulé "Ardoise — Table T9"
    - Liste des lignes × quantité × prix unitaire TTC
    - Total TTC
    - Heure (closed_at ou opened_at)

  """
  Scénario: [Reçu] Bouton imprimer désactivé tant que commande non PAYE
    Quand la commande affichée n'est PAS PAYE
    Alors le bouton "Imprimer / PDF" est désactivé + classe CSS disabled
    Et un clic dessus ne déclenche rien
