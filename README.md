# med-tutor dans Codex pour Windows

Pilote pour les étudiants invités, version **0.1.2**. Le plugin apprend à Codex à chercher dans les Collèges officiels et à citer le Collège, l'édition, l'item et la page.

**État :** le pilote utilise un test réduit sur l'ordinateur de l'auteur. L'installation Git est testée dans un profil CLI temporaire; OAuth desktop, la persistance et un compte étudiant distinct restent à vérifier. Les outils d'une conversation déjà connectée ne prouvent pas une nouvelle connexion. Les invitations restent en attente de ces vérifications.

## Ce qu'il vous faut

- Codex pour Windows, connecté à votre propre compte OpenAI disposant d'un accès à Codex. Consultez le [guide officiel](https://learn.chatgpt.com/docs/quickstart).
- Git pour Windows ([téléchargement officiel](https://git-scm.com/downloads/win)) pour récupérer le marketplace.
- Un compte med-tutor créé par la personne qui vous invite et dont l'adresse est autorisée sur le serveur. Ces identifiants sont différents de ceux de votre compte OpenAI.

Le dépôt public contient les instructions du plugin et l'adresse du service. Les livres et les passages restent sur le serveur; chaque étudiant s'authentifie individuellement.

## 1. Installer le plugin

Téléchargez [install.ps1 de la version v0.1.2](https://raw.githubusercontent.com/HaqpYc/med-tutor-codex/v0.1.2/install.ps1), enregistrez-le dans votre dossier Téléchargements et ouvrez PowerShell dans ce dossier. Lisez le script, puis exécutez :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

L'option s'applique seulement à ce processus PowerShell. Si une politique administrée bloque le script, contactez l'administrateur; ne la contournez pas. Aucun mot de passe ne vous est demandé par le script. Si Codex est introuvable, ouvrez l'application une première fois; le script accepte aussi `-CodexPath` suivi du chemin de `codex.exe`.

Vous pouvez également exécuter les deux commandes dans un terminal où `codex` est disponible :

```powershell
codex plugin marketplace add https://github.com/HaqpYc/med-tutor-codex.git --ref v0.1.2
codex plugin add med-tutor@med-tutor-codex
```

Pour une mise à jour ou une réinstallation, utilisez le script: il réenregistre seulement la source med-tutor-codex à la version demandée et conserve les autres sources. Si une source du même nom vient d'un autre dépôt, il s'arrête et la conserve.

## 2. Connecter med-tutor

Quittez complètement Codex, y compris son éventuelle icône dans la zone de notification, puis relancez-le. Ouvrez un dossier d'étude vide, puis une nouvelle conversation. Vérifiez dans les plugins que **med-tutor** est installé et activé; lancez sa connexion lorsque Codex vous le propose.

Le navigateur doit ouvrir **med-tutor-consent.pages.dev**. Entrez vos identifiants med-tutor uniquement sur cette page, vérifiez le compte et l'application demandeuse, puis autorisez la connexion que vous venez de lancer. Le retour OAuth de Codex peut utiliser une adresse locale `127.0.0.1` ou `localhost`. Revenez dans Codex et vérifiez que la connexion a abouti. Ne copiez jamais un mot de passe ou une URL de retour OAuth dans le chat.

Les intitulés exacts des menus et le retour OAuth doivent être confirmés lors du test desktop. Une installation réussie ou une connexion affichée ne prouve pas encore que les outils fonctionnent.

## 3. Poser une première question

Dans une nouvelle conversation, sélectionnez la compétence med-tutor dans le menu des compétences si elle est disponible, puis demandez :

> Quels seuils de pression artérielle définissent l'HTA en consultation et en automesure ?

Vérifiez qu'une recherche `search_colleges` a réellement lieu. Demandez ensuite :

> Lis le contexte d'un passage que tu viens de citer avec get_source, puis précise à quelle situation il s'applique.

Chaque phrase factuelle doit citer un identifiant de passage entre crochets. Une liste **Sources** termine la réponse avec le Collège, l'édition, l'item et les pages. Si les outils sont indisponibles, med-tutor doit le signaler. Les rangs A/B/C ne sont pas renseignés dans la base; un rang ne peut être rapporté que si le passage le dit explicitement.

## En cas de problème

| Symptôme | Action |
| --- | --- |
| `codex` ou Git introuvable | Ouvrez Codex, installez Git si nécessaire, puis ouvrez un nouveau terminal. |
| Plugin absent après installation | Quittez complètement Codex; relancez-le et ouvrez une nouvelle conversation. Vérifiez `install.ps1 -Action Check`. |
| Connexion n'ouvre aucune page | Regardez le navigateur, relancez la connexion et relevez l'erreur exacte, sans recréer un autre plugin. |
| `Invalid login credentials` | Utilisez les identifiants med-tutor, puis contactez la personne qui vous invite si nécessaire. La récupération de mot de passe reste manuelle. |
| `403` ou `Forbidden` après connexion | L'adresse n'est pas autorisée: contactez la personne qui vous invite. |
| Demande expirée | Relancez une nouvelle connexion depuis Codex; ne réutilisez pas l'ancien lien. |
| Réponse sans Sources ou venant du web | Vérifiez le plugin, sa compétence et les appels aux outils dans une nouvelle conversation. Signalez la réponse. |

## Mettre à jour ou retirer

La version du pilote est épinglée à `v0.1.2`. Utilisez uniquement une nouvelle version validée qui vous est annoncée, puis exécutez le script avec `-Release vX.Y.Z`. Relancez Codex et vérifiez à nouveau une réponse sourcée. Rafraîchir le marketplace seul ne change pas la version épinglée. La version 0.1.2 conserve les octets des fichiers malgré la conversion automatique de fins de ligne de Git pour Windows; le tag 0.1.1 reste inchangé.

Pour retirer le plugin :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Action Remove
```

Une connexion MCP/OAuth distincte peut subsister: déconnectez-la aussi dans Codex. Pour retirer l'accès serveur, la personne qui vous invite enlève votre adresse de la liste d'accès.

## Test réduit du pilote

Sans créer un nouveau compte Windows, le test réduit installe le plugin depuis Git dans un profil Codex CLI temporaire sans reprendre de configuration ou de jeton MCP. Il vérifie la réinstallation, le retrait, les octets de la compétence et la conservation d'une autre source de plugins et d'un autre réglage. Les deux outils peuvent ensuite être vérifiés séparément dans la conversation desktop déjà connectée.

Ce test n'établit pas une connexion OAuth desktop neuve, le fonctionnement avec un autre compte, le redémarrage ou le renouvellement d'un jeton. Le rapport local garde ces étapes « non testées ». Il ne modifie pas la liste d'accès serveur.

## Test complémentaire sur un ordinateur neuf

Créez un **nouveau profil Windows** et utilisez un navigateur vierge ainsi qu'un compte OpenAI étudiant distinct. Ne copiez ni configuration Codex, ni cache, ni session navigateur, ni jeton depuis l'installation habituelle. Commencez dans un dossier d'étude vide.

1. Avant installation, lancez [clean-test.ps1](https://raw.githubusercontent.com/HaqpYc/med-tutor-codex/v0.1.2/clean-test.ps1). Son rapport local ne contient aucun identifiant. Confirmez séparément le navigateur vierge et le compte OpenAI distinct.
2. Suivez seulement ce guide. Notez les versions de l'application, du CLI et du plugin, ainsi que le commit du tag.
3. Avec un compte med-tutor de test d'abord non autorisé, vérifiez que les recherches sont refusées. L'administrateur ajoute ensuite cette adresse en conservant la liste complète, puis vous relancez la connexion et une recherche.
4. Vérifiez les deux outils, les citations, une question ordinaire sans sélectionner la compétence, et une demande « rang A uniquement ».
5. Gardez la compétence installée, désactivez seulement sa connexion MCP et vérifiez que le tuteur signale l'indisponibilité. Réactivez-la ensuite.
6. Quittez complètement Codex, relancez-le et répétez une question. Après expiration naturelle du jeton d'accès, vérifiez une recherche ou la reconnexion demandée; ne modifiez pas l'horloge.
7. Déconnectez/reconnectez, puis désinstallez/réinstallez dans ce profil de test.

Conservez le détail des appels et des réponses seulement dans un dossier local privé. Notez chaque étape comme **réussie**, **échouée** ou **non testée**. Une simulation OAuth, un test CLI ou les outils d'un ancien chat ne valident pas cette installation desktop.

## Données et sources

Le service reçoit les mots-clés envoyés à ses outils, les identifiants des passages demandés et votre identité med-tutor. Ne transmettez pas de données identifiantes de patients. Utilisez les passages protégés pour réviser, sans les republier. Le service fournit un accès en lecture seule.

[Documentation officielle des plugins](https://developers.openai.com/plugins/build/plugins) · [Commandes Codex](https://learn.chatgpt.com/docs/developer-commands)
