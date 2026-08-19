# Dependencias del Proyecto Central KA94

Este repo es principalmente un sitio estatico, pero tambien contiene scripts para reinstalar todo el entorno KA94.

## Para servir el sitio

No requiere build.

Requisitos minimos:

- Navegador moderno.
- Git para versionado.
- Hosting estatico, actualmente GitHub Pages con dominio `ka94studio.com`.

Archivos publicados:

- `index.html`
- `app/index.html`
- `apps/*`
- `projects/*`
- `assets/*`
- `app-ads.txt`
- `CNAME`

## Para usar los scripts en Windows

Requisitos:

- Windows PowerShell 5.1 o PowerShell 7.
- Git.
- Acceso a GitHub y, si aplica, Gitea/hospital.
- Python 3 solo si se quieren validar/importar scripts Python localmente.

Scripts principales:

- `migration/pre-reset-audit.ps1`
- `migration/export-local-secrets.ps1`
- `migration/import-local-secrets.ps1`
- `migration/setup-new-pc.ps1`
- `migration/publish-to-github-private.ps1`

## Para restaurar en Ubuntu

El script `migration/setup-ubuntu-dev.sh` instala:

- Git
- curl
- ca-certificates
- unzip, zip, xz-utils
- build-essential
- clang
- cmake
- ninja-build
- pkg-config
- libgtk-3-dev
- libglu1-mesa
- OpenJDK 17
- Node.js 22 via nvm
- npm 11
- Firebase CLI
- Python 3
- python3-pip
- python3-venv
- python3-cryptography
- PHP CLI
- php-curl
- php-mbstring
- php-mysql
- php-sqlite3
- php-xml
- php-zip
- Composer
- Flutter stable
- FlutterFire CLI
- VS Code, Android Studio y Chromium via Snap si Snap esta disponible

## Dependencias por proyecto restaurado

| Proyecto | Tecnologias | Instalacion automatizada |
| --- | --- | --- |
| MPV | Flutter, Dart, Firebase, Google Mobile Ads, Play Billing | `flutter pub get`, `npm install` en `functions` si existe |
| FutureBalance | Flutter, Dart, Firebase, Ads, In-App Purchase, Drift, Riverpod | `flutter pub get`, `npm install` en `functions` |
| SATurno | Node, npm, NestJS, Angular, Prisma | `npm run install:frontend`, `npm run install:backend` |
| GeCTExcel | Python, FastAPI, Uvicorn, pydantic, httpx | `python3 -m venv .venv`, `pip install -r requirements.txt` |
| ACKA94 | Flutter, Firebase, Node functions, TypeScript | `flutter pub get`, `npm install`, `npm install` en `functions` |
| GlobalView | PHP, Composer, dotenv, html2pdf, Node assets | `composer install`, `npm install` |
| CeviFlash | Angular, Firebase, TypeScript, Vitest | `npm install` |
| Portal KA94 | HTML/CSS estatico | Sin instalacion |

## Secretos que no son dependencias

No confundir dependencias con secretos. Estos archivos no deben instalarse desde Git:

- `.env`
- `google-services.json` si se maneja como secreto local
- service accounts
- keystores Android
- `key.properties`
- tokens de GitHub/Firebase/Google
- archivos con datos reales

Se restauran con:

```bash
python3 ~/Dev/mpv-privacy-policy/migration/import-local-secrets.py /ruta/ka94-secrets.bundle.json --destination ~/Dev
```

## Verificacion rapida en Ubuntu

```bash
git --version
node -v
npm -v
python3 --version
php -v
composer --version
flutter --version
firebase --version
```
