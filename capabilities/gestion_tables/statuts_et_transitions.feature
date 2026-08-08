# language: fr

Fonctionnalité: Statuts et transitions d'une table (LIBRE → OCCUPEE → A_SERVIR → SERVIT → PAYE → LIBRE)
    Et le contexte suivant s'applique.
    """
  Afin de suivre l'état exact de chaque table du service
  En tant que gérant ou serveur
  Je veux que la table change de badge de couleur et que les boutons d'action s'activent au bon moment

    """
  Scénario: [Transition] Occuper une table libre
    Étant donné une table "T5" au statut "LIBRE"
    Quand le serveur ou le gérant clique sur "Occuper" sur T5
    Alors T5 passe en statut "OCCUPEE"
    Et le badge devient rouge (type "taken")
    Et le bouton "Occuper" est remplacé par "Libérer"

  Scénario: [Transition] Libérer une table OCCUPEE sans commande
    Étant donné une table "T5" en statut "OCCUPEE" sans commande ouverte
    Quand je clique sur "Libérer"
    Alors T5 repasse en statut "LIBRE"

  Scénario: [Transition] Libérer une table PAYE (après encaissement)
    Étant donné une table "T5" en statut "PAYE"
    Quand je clique sur "Libérer"
    Alors T5 repasse en "LIBRE"
    Et une nouvelle commande peut être créée pour T5

  Scénario: [Transition] Marquer une table "À servir" depuis le serveur
    Étant donné une commande ouverte sur T5 avec des articles
    Quand le serveur clique sur "À servir"
    Alors T5 passe en statut "A_SERVIR"
    Et le badge affiche "À servir" (couleur aservir)
    Et la commande est aussi en statut "A_SERVIR"

  Scénario: [Transition] Gérant marque "Servi" une table À servir
    Étant donné la table T5 en statut "A_SERVIR"
    Et la carte de T5 a un bouton "Servir" activé
    Quand le gérant clique sur "Servir" sur la carte de T5
    Alors T5 passe en statut "SERVIT"
    Et la commande passe en statut "SERVIT"
    Et le flag to_serve des lignes de la commande est remis à 0

  Scénario: [Boutons] Le bouton "Servir" est désactivé si statut pas "A_SERVIR"
    Étant donné une table T5 en statut "SERVIT"
    Alors le bouton "Servir" de la carte est désactivé (disabled)
    Et un clic sur "Servir" ne déclenche aucun appel API

  Scénario: [Paiement] Paiement transforme la table en "PAYE"
    Étant donné T5 en statut "SERVIT" avec une commande et un total
    Quand j'encaisse la commande
    Alors T5 passe en statut "PAYE"
    Et le badge affiche "Payée"
    Et le bouton "Imprimer / PDF" de la dernière ardoise devient activé

  Scénario: [Occuper/Libérer] Le bouton Occuper/Libérer est seulement activé pour LIBRE, OCCUPEE, PAYE
    Étant donné les statuts où le toggle reste activé.
      | statut   |
      | LIBRE    |
      | OCCUPEE  |
      | PAYE     |
    Et les statuts où le toggle est désactivé.
      | statut   |
      | A_SERVIR |
      | SERVIT   |
    Alors le bouton Occuper/Libérer est activé ou désactivé selon le statut de la table

  Scénario: [Auto-transition] Ajout d'un article sur une table SERVIT la remet en A_SERVIR
    Étant donné T5 en statut SERVIT après passage au gérant
    Quand le serveur ajoute un nouvel article (café) sur l'ardoise de T5
    Alors la ligne nouvel article est marquée to_serve=1 (surlignage vert)
    Et la table T5 repasse automatiquement en statut "A_SERVIR"
    Et la commande repasse en statut "A_SERVIR"
    Et le bouton "Servir" du gérant est à nouveau activé pour T5
