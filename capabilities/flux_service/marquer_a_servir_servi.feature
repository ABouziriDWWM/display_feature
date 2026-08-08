# language: fr

Fonctionnalité: Flux "À servir" / "Servi"
    Et le contexte suivant s'applique.
    """
  Afin de piloter la sortie des plats et le service en salle
  En tant que serveur puis gérant
  Je veux que la table passe en À servir quand des articles sont prêts, puis en Servi après validation du gérant

    """
  Scénario: [Déclenchement À servir] Serveur clique "À servir" quand des lignes ont to_serve=1
    Étant donné une commande sur T7 avec 2 articles ayant to_serve=1
    Et T7 est en statut OCCUPEE
    Quand le serveur clique sur le bouton "À servir"
    Alors T7 passe en statut A_SERVIR
    Et la commande passe en statut A_SERVIR
    Et la liste des tables (gérant) montre T7 avec badge "À servir"

  Scénario: [Déclenchement À servir] Autorisé même si aucune ligne n'a encore été marquée to_serve=1 (première commande vide puis remplissage)
    Étant donné T7 occupée avec 1 article (ajouté, donc to_serve=1 implicitement à l'insertion)
    Quand je clique sur "À servir"
    Alors T7 devient A_SERVIR

  Scénario: [Déclenchement À servir] Aucun article → message "Aucune ligne à servir"
    Étant donné T7 occupée avec une commande SANS article
    Quand je clique sur "À servir"
    Alors je vois le message "Aucune ligne à servir"
    Et T7 reste en OCCUPEE

  Scénario: [Validation Servi gérant] Bouton Servir carte active seulement si status = A_SERVIR
    Étant donné T7 en statut A_SERVIR
    Quand le gérant clique sur "Servir" dans la carte T7
    Alors T7 passe en statut SERVIT
    Et la commande passe en statut SERVIT
    Et le flag to_serve de TOUTES les lignes de la commande est remis à 0
    Et le badge affiche "Servit"

  Scénario: [Validation Servi gérant] Panneau dernière ardoise → bouton "Servir" en tête
    Étant donné T7 en A_SERVIR et l'ardoise de T7 affichée dans le panneau "Dernière ardoise"
    Alors le bouton "Servir" en haut du panneau est activé
    Quand je clique sur ce bouton "Servir"
    Alors la table T7 est marquée SERVIT via l'API
    Et l'ardoise est rechargée, les lignes ne sont plus surlignées vert

  Scénario: [Validation Servi gérant] Tentative Servi sans statut A_SERVIR
    Étant donné T7 en statut OCCUPEE
    Quand je tente de cliquer (ou forcer l'API) markServi sur T7
    Alors l'UI bloque via disabled
    Et si on force malgré tout, le bouton affiche un message d'erreur

  Scénario: [Encaissement] Lignes vertes to_serve=1 → encaissement interdit SAUF si statut SERVIT
    Étant donné une commande T7 avec to_serve=1 sur au moins une ligne
    Et la table T7 n'est PAS en statut SERVIT
    Alors les boutons "Payer cash" et "Payer CB" sont désactivés
    Et on ne peut pas encaisser

  Scénario: [Encaissement] Si statut SERVIT → encaissement autorisé même sans autre action
    Étant donné T7 en statut SERVIT
  Et le contexte suivant s'applique.
  """
    Quelles que soient les lignes restantes (to_serve=0)
  """
    Alors les boutons paiement sont activés
    Et je peux encaisser normalement

  Scénario: [Boucle service] Servi → nouvel article → repasse automatiquement À servir
    Étant donné T7 en statut SERVIT après passage gérant
    Quand le serveur ajoute "Dessert" sur T7
    Alors la nouvelle ligne est verte (to_serve=1)
    Et T7 repasse en A_SERVIR automatiquement
    Et le bouton Servir du gérant redevient actif sur T7
    Et le gérant peut "Servir" une deuxième fois pour valider le dessert
