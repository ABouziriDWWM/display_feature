# language: fr

Fonctionnalité: Ardoise — ajout, visualisation, suppression d'articles
    Et le contexte suivant s'applique.
    """
  Afin de matérialiser la consommation d'une table
  En tant que serveur ou gérant
  Je veux ajouter/supprimer des articles et voir le détail et total en temps réel

    """
  Scénario: [Ajout] Serveur ajoute un article actif à l'ardoise
    Étant donné une commande ouverte sur T5
    Et un produit "Café crème" actif au prix de 1.5€ HT
    Quand j'ajoute 1 "Café crème" à la commande
    Alors la ligne apparaît dans la liste de l'ardoise
    Et le flag to_serve de la nouvelle ligne est positionné à 1 (vert)
    Et le total de la commande augmente du prix TTC d'un café

  Scénario: [Ajout] Produit indisponible / inactif — ajout impossible
    Étant donné un produit "Spécialité maison" marqué inactif (active=0)
    Quand j'essaie de l'ajouter à la commande
    Alors je reçois "Produit indisponible"
    Et aucune ligne n'est ajoutée à l'ardoise

  Scénario: [Ajout] Quantité invalide (< 1)
    Quand j'ajoute un produit avec quantité 0
    Alors une erreur "Quantité invalide" est renvoyée

  Scénario: [Ajout] Quantité multiple (>1)
    Étant donné un produit "Eau plate" à 1€ HT
    Quand j'ajoute quantité=3 "Eau plate"
    Alors l'ardoise affiche "3 × Eau plate" avec le bon line_total
    Et le total augmente de 3€ HT (+ TVA)

  Scénario: [Suppression] Retirer une ligne de l'ardoise
    Étant donné une ardoise T5 contenant "Café crème" (ligne #10) et "Formule" (ligne #11)
    Quand je supprime la ligne #10
    Alors la ligne n'apparaît plus dans l'ardoise
    Et le total est recalculé sans le café

  Scénario: [Suppression] Ligne inconnue
    Quand je tente de supprimer une ligne d'id inexistant
    Alors l'API renvoie "Item introuvable"

  Scénario: [Détail de ligne] Calcul TTC avec TVA produit
    Étant donné un produit "Plat" à 15€ HT, TVA 10%
    Quand j'ajoute 1 plat à l'ardoise
    Alors la ligne affiche le prix unitaire TTC = 16.50€
    Et le total de ligne TTC = 16.50€

  Scénario: [Dernière ardoise] Gérant affiche l'ardoise depuis la carte table
    Quand sur la table T5 je clique sur "Dernière ardoise"
    Alors le panneau "Dernière ardoise" affiche la commande ouverte
    Et le titre affiche "Table T5" + badge "Non payé"
    Et le bouton "Servir" est activé ou non selon statut de table T5
    Et je peux faire défiler le détail des lignes + total TTC

  Scénario: [Auto statut] Ajout d'article sur commande SERVIT remet to_serve=1 et commande A_SERVIR
    Étant donné une commande en statut SERVIT (après Servir du gérant)
    Quand j'ajoute un nouvel article à cette même commande
    Alors la nouvelle ligne a to_serve=1
    Et la commande repasse en statut A_SERVIR
    Et la table liée repasse automatiquement en A_SERVIR
