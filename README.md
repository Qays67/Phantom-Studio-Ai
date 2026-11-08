# Phantom Studio — site officiel

Site vitrine + page de téléchargement de **Phantom Studio**.
Tout est prêt pour GitHub Pages et les releases GitHub.

## Contenu du dossier

- `index.html`, `styles.css`, `script.js` : le site complet (aucune dépendance, aucun build).
- `assets/` : logo, icône et captures de l'application.
- `serve.js` : aperçu local du site.
- `publier-github.ps1` : publie tout automatiquement (dépôt, GitHub Pages, release et `.exe`).
- `.nojekyll` : nécessaire pour GitHub Pages.
- `.gitignore` : empêche d'envoyer l'installateur de 181 Mo dans le dépôt.

## 1. Aperçu local

Double-clique simplement sur `index.html` : le site s'ouvre et le bouton télécharge
`release/Phantom-Studio.exe`.

Pour un aperçu avec serveur local :

```powershell
node serve.js
```

Ouvre ensuite `http://localhost:4173`.

## 2. Publication automatique sur GitHub

Prérequis :

1. Installe GitHub CLI si besoin :
   ```powershell
   winget install --id GitHub.cli
   ```
2. Connecte-toi une fois :
   ```powershell
   gh auth login
   ```
3. Depuis ce dossier, double-clique sur **`PUBLIER-SUR-GITHUB.bat`**
   (ou lance `powershell -ExecutionPolicy Bypass -File .\publier-github.ps1`).

Le script :

- crée le dépôt public `phantom-studio` (ou le réutilise) ;
- envoie le site sur la branche `main` ;
- active GitHub Pages ;
- crée la release `v1.0.0` ;
- renomme et envoie l'installateur en `Phantom-Studio.exe` ;
- affiche le lien du site et le lien de téléchargement.

À la fin, tu obtiens :

- **Site** : `https://TON-PSEUDO.github.io/phantom-studio/`
- **Téléchargement** : `https://github.com/TON-PSEUDO/phantom-studio/releases/latest/download/Phantom-Studio.exe`

La première publication GitHub Pages peut prendre 1 à 2 minutes.

## 3. Publication manuelle

1. Crée un dépôt public sur GitHub, par exemple `phantom-studio`.
2. Envoie **le contenu de ce dossier** à la racine du dépôt (pas le dossier lui-même).
3. Va dans **Settings → Pages** :
   - Source : `Deploy from a branch`
   - Branch : `main`
   - Folder : `/ (root)`
4. Crée une release :
   - Tag : `v1.0.0`
   - Titre : `Phantom Studio 1.0.0`
   - Ajoute l'installateur renommé **`Phantom-Studio.exe`**
5. Le bouton du site pointe automatiquement vers la dernière release.

> Le dossier contient `release/Phantom-Studio.exe` pour que le site fonctionne en local.
> Ce fichier est ignoré par `.gitignore` : n'envoie jamais le `.exe` de 181 Mo directement
> dans le dépôt, GitHub refuse les fichiers de plus de 100 Mo. Il doit être ajouté à la **release**.

## 4. Personnalisation

- Couleurs : variables `--bg`, `--accent`, `--text` dans `styles.css`.
- Textes : `index.html`.
- Nom du dépôt : premier paramètre du script, par exemple :
  ```powershell
  .\publier-github.ps1 -RepoName "phantom-studio-site"
  ```
- Nom de domaine personnalisé : décommente `GITHUB_REPO` dans `script.js` et mets `"ton-pseudo/phantom-studio"`.

## 5. Mise à jour de l'application

Après une nouvelle compilation :

```powershell
.\publier-github.ps1 -ReleaseTag "v1.0.1"
```

Le site reste identique, le bouton de téléchargement pointe toujours vers la dernière release.
