# language: fr

Fonctionnalité: Surlignage vert "à servir" des lignes d'ardoise
    Et le contexte suivant s'applique.
    """
  Afin de visualiser rapidement ce qui reste à sortir en cuisine / bar
  En tant que gérant et serveur
  Je veux que les lignes marquées "to_serve=1" soient en fond vert dans l'ardoise

    """
  Scénario: [Surlignage] Nouvelle ligne ajoutée → surlignée verte
    Étant donné une commande ouverte sur T8
    Quand j'ajoute un article "Coca"
    Alors dans l'ardoise la ligne Coca apparaît sur fond vert (classe CSS to-serve)
    Et le to_serve vaut 1 (ou équivalent numérique/chaîne)

  Scénario: [Surlignage] Après passage "Servi" du gérant, le vert disparaît
    Étant donné T8 en A_SERVIR avec lignes vertes
    Quand le gérant valide "Servir" sur T8
    Alors to_serve des lignes passe à 0
    Et le fond vert (to-serve) est retiré de toutes les lignes
    Et l'affichage redevient normal

  Scénario: [Surlignage] Ajout article après Servi → nouvelle ligne verte, anciennes non
    Étant donné T8 en statut SERVIT (anciennes lignes non vertes)
    Quand j'ajoute un nouveau produit "Tiramisu"
    Alors la ligne Tiramisu est verte

  Et le contexte suivant s'applique.
  """
    Les anciennes lignes restent non surlignées

  """
  Scénario: [Surlignage] Le surlignage est robuste au type (string vs number)
  Et le contexte suivant s'applique.
  """
    Même si le backend renvoie to_serve sous forme de chaîne "1"
  """
    Alors la ligne est bien reconnue "à servir"
    Et le fond vert est appliqué correctement

  Scénario: [Panneau dernière ardoise] Gérant voit le vert dans le panneau "Dernière ardoise"
    Quand le gérant affiche la dernière ardoise d'une table A_SERVIR
    Alors les lignes à servir apparaissent en fond vert
    Et il peut distinguer visuellement ce qui reste à sortir

  Scénario: [Détection serveur] Détection "hasHighlightedLines" pour blocage paiement
  Et le contexte suivant s'applique.
  """
    Si au moins une ligne est verte (to_serve=1) dans la commande
  """
    Alors hasHighlightedLines() renvoie true
    Et les boutons de paiement sont désactivés tant que la table n'est pas SERVIT
