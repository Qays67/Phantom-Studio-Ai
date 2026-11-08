param(
  [string]$RepoName = "phantom-studio",
  [string]$ReleaseTag = "v1.0.0",
  [string]$InstallerPath = ""
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Fail($Message) {
  Write-Host ""
  Write-Host "ERREUR : $Message" -ForegroundColor Red
  exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Fail "Git n'est pas installé. Installe-le depuis https://git-scm.com/download/win"
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Fail "GitHub CLI n'est pas installé. Lance : winget install --id GitHub.cli"
}

gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
  Fail "Tu n'es pas connecté à GitHub. Lance : gh auth login"
}

$owner = (gh api user --jq .login).Trim()
if (-not $owner) { Fail "Impossible de récupérer ton compte GitHub." }
$repo = "$owner/$RepoName"

if (-not $InstallerPath) {
  $candidates = @(
    (Join-Path $PSScriptRoot "release\Phantom-Studio.exe"),
    "C:\Users\Phantom\Desktop\Plugins et ia Roblox\Astra Studio\site\release\Phantom-Studio.exe"
  )
  $InstallerPath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $InstallerPath -or -not (Test-Path $InstallerPath)) {
  Fail "Installateur introuvable. Place Phantom-Studio.exe dans le dossier release\ du site."
}
$InstallerPath = [System.IO.Path]::GetFullPath($InstallerPath)

Write-Host ""
Write-Host "Phantom Studio -> $repo" -ForegroundColor Magenta

if (-not (Test-Path (Join-Path $PSScriptRoot ".git"))) {
  git init -b main | Out-Null
}

$gitName = git config user.name
if (-not $gitName) {
  git config user.name $owner
  git config user.email "$owner@users.noreply.github.com"
}

git add -A
$hasChanges = git status --porcelain
if ($hasChanges) {
  git commit -m "Phantom Studio - site et telechargement" | Out-Null
}

gh repo view $repo *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host "Creation du depot public..." -ForegroundColor Cyan
  gh repo create $repo --public --source . --remote origin --push
  if ($LASTEXITCODE -ne 0) { Fail "Creation du depot impossible." }
} else {
  Write-Host "Depot existant, envoi des fichiers..." -ForegroundColor Cyan
  $remotes = git remote
  if ($remotes -notcontains "origin") {
    git remote add origin "https://github.com/$repo.git"
  }
  git push -u origin main
  if ($LASTEXITCODE -ne 0) { Fail "Envoi vers GitHub impossible." }
}

Write-Host "Activation de GitHub Pages..." -ForegroundColor Cyan
$pagesFile = Join-Path $env:TEMP "phantom-pages.json"
'{"source":{"branch":"main","path":"/"}}' | Set-Content -Path $pagesFile -Encoding utf8
gh api -X POST "repos/$repo/pages" --input $pagesFile *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host "Pages est peut-etre deja actif (ou sera active manuellement)." -ForegroundColor Yellow
}
Remove-Item $pagesFile -ErrorAction SilentlyContinue

Write-Host "Preparation de la release $ReleaseTag..." -ForegroundColor Cyan
$tempInstaller = Join-Path $env:TEMP "Phantom-Studio.exe"
Copy-Item -Path $InstallerPath -Destination $tempInstaller -Force

gh release view $ReleaseTag --repo $repo *> $null
if ($LASTEXITCODE -ne 0) {
  gh release create $ReleaseTag $tempInstaller --repo $repo --title "Phantom Studio $ReleaseTag" --notes "Application Windows de Phantom Studio. Telechargement direct : Phantom-Studio.exe"
} else {
  gh release upload $ReleaseTag $tempInstaller --repo $repo --clobber
}
if ($LASTEXITCODE -ne 0) {
  Remove-Item $tempInstaller -ErrorAction SilentlyContinue
  Fail "Envoi de l'installateur impossible."
}
Remove-Item $tempInstaller -ErrorAction SilentlyContinue

$siteUrl = "https://$owner.github.io/$RepoName/"
if ($RepoName -eq "$owner.github.io") {
  $siteUrl = "https://$owner.github.io/"
}
$downloadUrl = "https://github.com/$repo/releases/latest/download/Phantom-Studio.exe"

Write-Host ""
Write-Host "C'est carre. Tout est en ligne." -ForegroundColor Green
Write-Host "Site         : $siteUrl"
Write-Host "Telecharger  : $downloadUrl"
Write-Host "Depot        : https://github.com/$repo"
Write-Host ""
Write-Host "GitHub Pages peut mettre 1 a 2 minutes a s'activer."
