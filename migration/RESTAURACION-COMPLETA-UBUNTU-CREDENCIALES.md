# Restauracion completa KA94 en Ubuntu con credenciales

Este documento es el checklist operativo para restaurar los proyectos KA94 despues de formatear Windows e instalar Ubuntu.

No guardar contrasenas reales en este archivo. Las contrasenas deben estar en un gestor de contrasenas, papel seguro o el bundle cifrado `ka94-secrets.bundle.json`.

## Respaldos confirmados

Proyecto central:

```text
\\192.168.0.92\Backup_Tics\01 DESARROLLO\Respaldo_PCCARLOS_19082026\PROYECTOS\mpv-privacy-policy_KA94-Studio-Portal_20260819_094102_f0c7140
```

Bundle cifrado de secretos:

```text
\\192.168.0.92\Backup_Tics\01 DESARROLLO\Respaldo_PCCARLOS_19082026\PROYECTOS\KA94_SECRETS_ENCRYPTED_20260819\ka94-secrets.bundle.json
```

Checksum del bundle:

```text
55676F4565CEED3B6E19C9EF78EA13EB38CAB04C517B6D5D5CAF67801C853AC9
```

## Credenciales necesarias

Tener listas antes de formatear:

- GitHub: usuario `CarlosAlcivar94` y token nuevo con permiso para repos privados.
- Gitea/hospital: usuario y contrasena para `http://192.168.0.124:3000`.
- Passphrase del bundle cifrado `ka94-secrets.bundle.json`.
- Google/Firebase: cuenta con acceso a proyectos Firebase de MPV, FutureBalance, ACKA94 y CeviFlash.
- Google Play Console/AdMob: cuenta usada para publicar apps y validar `app-ads.txt`.
- Android signing: contrasenas de keystore/key alias si no estan dentro de `key.properties` restaurado.
- Cloudflare/Hostinger: cuenta de dominio `ka94studio.com` si se requiere DNS.
- Bases de datos: credenciales MySQL/PostgreSQL/SQLite usadas por SATurno, GlobalView y otros servicios internos.

## Estado de repos antes del formateo

Estado verificado el 2026-08-19:

```text
MPV           GitHub OK
FutureBalance GitHub OK
SATurno       GitHub OK
ACKA94        GitHub OK
GlobalView    GitHub OK
CeviFlash     GitHub OK
Site          GitHub OK
GeCTExcel     Gitea OK, GitHub NO
```

GeCTExcel se debe restaurar desde Gitea, salvo que antes se suba el HEAD actual a GitHub.

## Instalar Ubuntu

Recomendado:

- Ubuntu 24.04 LTS o superior.
- Mantener acceso a la red interna `192.168.0.x` si se va a recuperar GeCTExcel desde Gitea.
- Confirmar que el recurso `\\192.168.0.92\Backup_Tics` sea accesible desde Ubuntu.

## Montar respaldo de red en Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y cifs-utils git curl ca-certificates
sudo mkdir -p /mnt/backup_tics
sudo mount -t cifs //192.168.0.92/Backup_Tics /mnt/backup_tics -o username=TU_USUARIO_DE_RED,vers=3.0
```

Ruta equivalente del respaldo:

```bash
/mnt/backup_tics/01 DESARROLLO/Respaldo_PCCARLOS_19082026/PROYECTOS
```

Si el montaje falla, copiar la carpeta de respaldo por USB.

## Restaurar repo central desde GitHub

```bash
mkdir -p ~/Dev
git clone https://github.com/CarlosAlcivar94/mpv-privacy-policy.git ~/Dev/mpv-privacy-policy
cd ~/Dev/mpv-privacy-policy
```

Si GitHub pide autenticacion para repos privados:

```bash
export GITHUB_TOKEN="PEGAR_TOKEN_NUEVO_AQUI"
```

## Restaurar repo central offline si GitHub falla

```bash
mkdir -p ~/Dev
git clone "/mnt/backup_tics/01 DESARROLLO/Respaldo_PCCARLOS_19082026/PROYECTOS/mpv-privacy-policy_KA94-Studio-Portal_20260819_094102_f0c7140/git/mpv-privacy-policy-f0c7140.bundle" ~/Dev/mpv-privacy-policy
cd ~/Dev/mpv-privacy-policy
git remote add origin https://github.com/CarlosAlcivar94/mpv-privacy-policy.git
```

## Instalar dependencias y clonar proyectos

Si GeCTExcel se restaura desde Gitea:

```bash
export GECTEXCEL_REPO_URL="http://192.168.0.124:3000/ADMINISTRADOR/gectexcel.git"
```

Si tambien se desea forzar Gitea para SATurno o GlobalView:

```bash
export SATURNO_REPO_URL="http://192.168.0.124:3000/ADMINISTRADOR/sistema-turnos-general.git"
export GLOBALVIEW_REPO_URL="http://192.168.0.124:3000/ADMINISTRADOR/globalview"
```

Ejecutar setup:

```bash
cd ~/Dev/mpv-privacy-policy
chmod +x migration/setup-ubuntu-dev.sh
./migration/setup-ubuntu-dev.sh
```

El script instala:

- Git, curl, build tools.
- Node.js 22 via nvm.
- npm 11.
- Firebase CLI.
- Python 3, pip, venv, cryptography.
- PHP, extensiones PHP y Composer.
- Flutter stable.
- FlutterFire CLI.
- Android Studio, VS Code y Chromium via Snap si Snap existe.

## Restaurar secretos

Primero verificar checksum del bundle:

```bash
sha256sum "/mnt/backup_tics/01 DESARROLLO/Respaldo_PCCARLOS_19082026/PROYECTOS/KA94_SECRETS_ENCRYPTED_20260819/ka94-secrets.bundle.json"
```

Debe coincidir con:

```text
55676F4565CEED3B6E19C9EF78EA13EB38CAB04C517B6D5D5CAF67801C853AC9
```

Probar importacion sin escribir:

```bash
python3 ~/Dev/mpv-privacy-policy/migration/import-local-secrets.py "/mnt/backup_tics/01 DESARROLLO/Respaldo_PCCARLOS_19082026/PROYECTOS/KA94_SECRETS_ENCRYPTED_20260819/ka94-secrets.bundle.json" --destination ~/Dev --dry-run
```

Importar definitivamente:

```bash
python3 ~/Dev/mpv-privacy-policy/migration/import-local-secrets.py "/mnt/backup_tics/01 DESARROLLO/Respaldo_PCCARLOS_19082026/PROYECTOS/KA94_SECRETS_ENCRYPTED_20260819/ka94-secrets.bundle.json" --destination ~/Dev
```

El script pedira la passphrase del bundle.

## Configurar Android

Abrir Android Studio una vez e instalar:

- Android SDK Platform.
- Android SDK Command-line Tools.
- Android SDK Build-Tools.
- Android Emulator si se usara emulador.

Luego:

```bash
flutter doctor --android-licenses
flutter doctor
```

## Login de herramientas

```bash
firebase login
```

Opcional si se usa `gh`:

```bash
sudo apt-get install -y gh
gh auth login
```

## Verificacion global

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

Verificar repos:

```bash
for dir in ~/Dev/MVP ~/Dev/FutureBalance ~/Dev/SATurno ~/Dev/gectexcel ~/Dev/AdminCenterKA94 ~/Dev/globalview ~/Dev/ceviflash ~/Dev/mpv-privacy-policy; do
  echo "=== $dir ==="
  git -C "$dir" status --short
  git -C "$dir" log -1 --oneline
done
```

## Verificacion por proyecto

MPV:

```bash
cd ~/Dev/MVP
flutter pub get
flutter analyze
flutter test
```

FutureBalance:

```bash
cd ~/Dev/FutureBalance
flutter pub get
npm install --prefix functions --no-audit --no-fund
npm --prefix functions test
flutter analyze
flutter test
```

SATurno:

```bash
cd ~/Dev/SATurno
npm run install:frontend
npm run install:backend
npm run build:frontend
npm run build:backend
```

GeCTExcel:

```bash
cd ~/Dev/gectexcel
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

ACKA94:

```bash
cd ~/Dev/AdminCenterKA94
flutter pub get
npm install --no-audit --no-fund
npm install --prefix functions --no-audit --no-fund
flutter analyze
```

GlobalView:

```bash
cd ~/Dev/globalview
composer install
npm install --no-audit --no-fund
php -S localhost:8081
```

CeviFlash:

```bash
cd ~/Dev/ceviflash
npm install --no-audit --no-fund
npm run build
```

Portal KA94:

```bash
cd ~/Dev/mpv-privacy-policy
python3 -m http.server 8080
```

Abrir:

```text
http://localhost:8080
```

## Criterio de exito

La restauracion se considera completa cuando:

- Todos los repos existen en `~/Dev`.
- `git status --short` no muestra cambios inesperados.
- Secretos importados sin errores.
- `flutter doctor` reconoce Android toolchain.
- MPV y FutureBalance ejecutan `flutter pub get`.
- SATurno instala frontend/backend.
- GeCTExcel crea `.venv`.
- GlobalView ejecuta `composer install`.
- CeviFlash ejecuta `npm run build`.
- El portal KA94 abre localmente y contiene `app-ads.txt`.
