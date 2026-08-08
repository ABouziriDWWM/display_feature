# language: fr

Fonctionnalité: Gestion CRUD des produits
    Et le contexte suivant s'applique.
    """
  Afin de maintenir à jour la carte du café
  En tant que gérant
  Je veux créer, modifier, désactiver/réactiver et supprimer des produits

    """
  Scénario: [Création] Créer un produit avec nom, prix, catégorie, TVA
    Étant donné une session gérant active
    Quand je crée un produit.
      | name     | price | tva_percent | active |
      | "Café"   | 1.50  | 10          | 1      |
    Alors le produit "Café" apparaît dans la liste des produits
    Et le produit est actif, commandeable par les serveurs

  Scénario: [Modification] Modifier le prix d'un produit
    Étant donné le produit "Café" à 1.50€
    Quand je mets son prix à 1.60€
    Alors les prochaines commandes ajoutent "Café" à 1.60€ HT
    Et les commandes déjà créées gardent leur prix historique (unit_price sur la ligne)

  Scénario: [Désactivation] Produit inactif non commandable
    Étant donné un produit "Glace vanille" actif
    Quand je le passe en actif=0
    Alors il disparaît de la sélection serveur
    Et tenter de l'ajouter par API renvoie "Produit indisponible"

  Scénario: [Liste] Produits triés par nom / catégorie dans l'interface gérant
    Quand j'affiche la page Produits
    Alors les produits sont triés (nom asc ou catégorie + nom)
    Et chaque ligne affiche: nom, prix HT, %TVA, boutons Modifier / Désactiver / Supprimer

  Scénario: [Suppression] Suppression impossible si produit référencé par une commande
    Quand un produit a déjà été commandé (présent dans order_items)
    Alors sa suppression est interdite par contraintes de FK
    Et je préfère le DÉSACTIVER plutôt que le supprimer

  Scénario: [TVA] Produits sans TVA en base utilisent la TVA globale du café
  Et le contexte suivant s'applique.
  """
    Si un produit n'a pas de tva_percent en base (colonne absente ou nulle)
  """
    Alors le calcul TTC prend la TVA paramétrée globalement dans SettingsService
    Et l'affichage dans l'ardoise reste correct
