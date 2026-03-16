je l’ai mis en place de façon sécurisée : quand tu cliques sur “Choisir capabilities/” et que tu sélectionnes un dossier, le site peut pousser un commit sur GitHub (ce qui déclenche automatiquement un rebuild/déploiement Netlify), puis “remplacer” le contenu de capabilities/ dans le repo.

Ce qui a été ajouté

- Côté UI : après sélection du dossier, le site envoie les fichiers .feature à une fonction Netlify et déclenche un commit (avec une clé demandée via prompt ) : client-pack.js
- Côté Netlify (backend) : une fonction publish-capabilities qui :
  - reçoit la liste des fichiers,
  - régénère capabilities/manifest.json ,
  - supprime les anciens .feature + l’ancien manifest.json (mais conserve capabilities/behat_status.json ),
  - crée un commit GitHub sur la branche et met à jour la ref : publish-capabilities.js
Pré-requis Netlify

- Le site Netlify doit être connecté à ton repo GitHub (déploiement via Git). Le push déclenche alors le rebuild automatiquement.
- Ajouter ces variables d’environnement dans Netlify (Site settings → Environment variables) :
  - PUBLISH_KEY : une clé secrète (ex: une passphrase)
  - GITHUB_TOKEN : token GitHub avec droits d’écriture sur le repo
  - GITHUB_OWNER : owner (user/org)
  - GITHUB_REPO : nom du repo
  - GITHUB_BRANCH (optionnel, défaut main )
Utilisation

- Sur le site Netlify : clique “Choisir capabilities/” → choisis ton dossier → saisis la PUBLISH_KEY quand le prompt apparaît.
- Un commit est poussé et Netlify lance un nouveau déploiement.