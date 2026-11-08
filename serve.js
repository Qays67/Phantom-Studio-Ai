const fs = require('fs');
const http = require('http');
const path = require('path');

const root = __dirname;
const port = Number(process.env.PORT) || 4173;
const localInstaller = path.join(__dirname, 'release', 'Phantom-Studio.exe');
const installer = fs.existsSync(localInstaller)
  ? localInstaller
  : path.resolve(__dirname, '..', 'dist', 'Phantom Studio', 'Phantom Studio.exe');

const types = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.svg': 'image/svg+xml'
};

function sendFile(res, file, download) {
  const ext = path.extname(file).toLowerCase();
  res.writeHead(200, {
    'Content-Type': types[ext] || 'application/octet-stream',
    'Content-Length': fs.statSync(file).size,
    ...(download ? { 'Content-Disposition': 'attachment; filename="Phantom-Studio.exe"' } : {})
  });
  fs.createReadStream(file).pipe(res);
}

http
  .createServer((req, res) => {
    const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);

    if (url.pathname === '/release/Phantom-Studio.exe') {
      if (!fs.existsSync(installer)) {
        res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end("L'installateur n'est pas disponible dans dist/.");
        return;
      }
      sendFile(res, installer, true);
      return;
    }

    let target = path.resolve(root, `.${decodeURIComponent(url.pathname)}`);
    if (target !== root && !target.startsWith(root + path.sep)) {
      res.writeHead(403);
      res.end('Interdit');
      return;
    }
    if (fs.existsSync(target) && fs.statSync(target).isDirectory()) {
      target = path.join(target, 'index.html');
    }
    if (!fs.existsSync(target)) {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('Page introuvable');
      return;
    }
    sendFile(res, target, false);
  })
  .listen(port, '127.0.0.1', () => {
    console.log(`SITE http://localhost:${port}`);
  });
