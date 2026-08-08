# language: fr

Fonctionnalité: Hors-ligne — file d'attente locale et rejeu au retour réseau
    Et le contexte suivant s'applique.
    """
  Afin de continuer à travailler même lors d'une coupure Internet ou panne Wi-Fi passagère
  En tant que serveur et gérant
  Je veux que mes actions (ajout article, marquer à servir, marquer servi, paiement) soient empilées localement, puis rejouées dans l'ordre au retour réseau

    """
  Scénario: [Queue] Ajout article hors-ligne → mis en file d'attente
    Étant donné une session serveur active avec T5 sélectionnée
    Et que le réseau est coupé (navigateur offline)
    Quand j'ajoute un produit "Formule midi" à T5
    Alors l'action est immédiatement ajoutée dans IndexedDB (table pending_actions)
    Et un badge "En attente" avec nombre d'actions empilées apparaît en haut à droite
    Et l'ardoise est mise à jour LOCALEMENT avec la ligne Formule midi (affichage optimiste)
    Et l'apparence de la ligne est "en attente de synchro" (style pointillé ou badge)

  Scénario: [Queue] Plusieurs actions consécutives hors-ligne sont ordonnées
  Et le contexte suivant s'applique.
  """
    Réseau coupé:
    1. j'ajoute un café → #1
    2. je marque la table À servir → #2
    3. j'ajoute un dessert → #3
  """
    Alors pending_actions contient 3 entrées avec ordre numérique séquence 1,2,3
    Et elles seront rejouées DANS CET ORDRE au retour réseau

  Scénario: [BackgroundSync] Retour réseau → rejeu automatique via BackgroundSync
    Étant donné 3 actions en attente dans IndexedDB
    Et le réseau revient
    Quand l'événement 'online' est émis
    Alors le Service Worker (via BackgroundSync) défile les 3 actions et les POST à l'API
    Et à chaque succès: la ligne est supprimée de pending_actions
    Et le badge "En attente" diminue puis disparaît
    Et l'utilisateur voit un toast "3 actions synchronisées"

  Scénario: [Idempotence] Chaque action a un idempotency-key pour éviter les doubles
  Et le contexte suivant s'applique.
  """
    Chaque action dans pending_actions porte un id UUID unique (idempotency_key)
  """
    Quand l'action est rejouée, ce key est envoyé dans un header X-Idempotency-Key
  Et le contexte suivant s'applique.
  """
    Si la requête a déjà été exécutée avant (crash avant réponse), l'API renvoie la réponse originale sans réexécuter
  """
    Donc on ne crée pas 2 fois la même ligne commande

  Scénario: [Conflits] last-write-wins par horodatage

  Et le contexte suivant s'applique.
  """
    Simultanément hors-ligne:
    - Appareil A modifie T5 (ajout café, timestamp 10:00:15)
    - Appareil B modifie T5 (ajout dessert, timestamp 10:00:20)
    Au retour réseau, les 2 actions sont rejouées et appliquées sur le backend
    Le backend garde la date la plus récente pour les opérations conflictuelles
    Un message "Conflit résolu" apparaît sur l'appareil A avec un résumé

  """
  Scénario: [Conflits] Verrous locked-by-device sur table pendant l'édition
  Et le contexte suivant s'applique.
  """
    Pour éviter des modifications concurrentes sur LA MÊME table hors-ligne:
    L'appareil A sélectionne T5 → prend un verrou (locked_by="SERVEUR-SOFIA-DEVICE", locked_until=+5min)
    Si appareil B tente d'éditer T5 pendant ce temps
  """
    Alors B reçoit "Table en cours d'édition par Sofia — réessayez dans X min"

  Scénario: [Paiement CB] Paiement CB impossible hors-ligne (géré par la banque)

  Et le contexte suivant s'applique.
  """
    Si hors-ligne:
    - Les boutons CB sont désactivés
    - Si on force une tentative, message "Paiement CB impossible sans connexion"
    - Seul le paiement en ESPÈCES peut être mis en file (enregistré en local puis validé serveur au retour)

  """
  Scénario: [Persistance] Pending actions survivent au refresh et même fermeture navigateur
  Et le contexte suivant s'applique.
  """
    Je mets 4 actions en attente puis je ferme complètement le navigateur
  """
    Quand je réouvre l'application sur le même appareil
    Alors les 4 actions sont toujours présentes dans pending_actions
    Et le badge "En attente 4" s'affiche
    Et elles sont rejouées automatiquement dès que le réseau revient

  Scénario: [Erreurs de synchro] Erreur partielle garde l'action en queue
    Étant donné 2 actions en attente:
      | action | resultat |
      | 1      | OK 200   |
      | 2      | Erreur 500 (pb serveur passager) |
    Quand la synchro est lancée
    Alors l'action 1 est supprimée de la queue
    Et l'action 2 reste en attente dans pending_actions
    Et un toast affiche "1 action en échec, nouvelle tentative dans 5s"
    Et la prochaine tentative suit le replay exponentiel 5s → 10s → 30s → 1min
