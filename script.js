(function () {
  const GITHUB_REPO = '__GITHUB_REPO__';
  const RELEASE_ASSET = 'Phantom-Studio.exe';
  const LOCAL_ASSET = 'release/Phantom-Studio.exe';

  function detectRepo() {
    const host = location.hostname;
    if (!host.endsWith('.github.io')) return '';
    const owner = host.split('.')[0];
    const parts = location.pathname.split('/').filter(Boolean);
    const repo = parts[0] || `${owner}.github.io`;
    return owner && repo ? `${owner}/${repo}` : '';
  }

  const repo = GITHUB_REPO.startsWith('__') ? detectRepo() : GITHUB_REPO;
  const repoUrl = repo ? `https://github.com/${repo}` : '';
  const downloadUrl = repo
    ? `https://github.com/${repo}/releases/latest/download/${RELEASE_ASSET}`
    : LOCAL_ASSET;

  document.querySelectorAll('[data-download]').forEach((link) => {
    link.setAttribute('href', downloadUrl);
    link.setAttribute('download', RELEASE_ASSET);
  });

  const note = document.getElementById('download-note');
  const ua = navigator.userAgent;
  const platform = /Android/i.test(ua)
    ? 'android'
    : /iPhone|iPad|iPod/i.test(ua)
      ? 'ios'
      : /Macintosh|Mac OS X/i.test(ua)
        ? 'mac'
        : /Linux/i.test(ua)
          ? 'linux'
          : 'windows';

  const notes = {
    windows:
      'Téléchargement direct. Si Windows SmartScreen apparaît : Informations complémentaires → Exécuter quand même.',
    android:
      'Le fichier se télécharge sur ton téléphone. Phantom Studio est une application Windows : ouvre ensuite le .exe sur un PC Windows 10/11.',
    ios:
      'Le fichier se télécharge sur ton iPhone. Phantom Studio est une application Windows : ouvre ensuite le .exe sur un PC Windows 10/11.',
    mac:
      'Le fichier se télécharge. Phantom Studio tourne pour l’instant uniquement sous Windows 10/11.',
    linux:
      'Le fichier se télécharge. Phantom Studio tourne pour l’instant uniquement sous Windows 10/11.'
  };
  if (note) note.textContent = notes[platform];

  document.querySelectorAll('[data-repo]').forEach((link) => {
    if (repoUrl) {
      link.setAttribute('href', repoUrl);
      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');
    }
  });

  const year = document.getElementById('year');
  if (year) year.textContent = String(new Date().getFullYear());
})();
