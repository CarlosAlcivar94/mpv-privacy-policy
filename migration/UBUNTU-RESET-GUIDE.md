# Restauracion KA94 en Ubuntu

Esta guia deja una PC Ubuntu lista para clonar y trabajar los proyectos KA94 despues de resetear Windows.

## Regla principal antes de formatear

No formatees hasta que la auditoria pre-reset este limpia. El archivo de referencia es:

```text
migration/PRE-RESET-AUDIT-2026-08-19.md
```

Ejecuta:

```powershell
cd C:\mpv-privacy-policy
git pull
powershell -ExecutionPolicy Bypass -File .\migration\pre-reset-audit.ps1 -Online
```

## Dependencias base en Ubuntu

El script `migration/setup-ubuntu-dev.sh` instala o configura:

- Git
- curl, unzip, xz-utils, zip, ca-certificates
- build-essential, clang, cmake, ninja-build, pkg-config, GTK libraries
- OpenJDK 17
- Node.js 22 mediante nvm
- npm 11
- Firebase CLI
- Python 3, pip, venv y `python3-cryptography`
- PHP CLI y extensiones: curl, mbstring, xml, zip, sqlite3, mysql
- Composer
- Flutter stable en `~/development/flutter`
- FlutterFire CLI
- VS Code, Android Studio y Chromium via Snap cuando Snap este disponible

## Proyectos que se restauran

| Repo GitHub | Carpeta Ubuntu | Perfil |
| --- | --- | --- |
| `CarlosAlcivar94/MVP` | `~/Dev/MVP` | Flutter + Firebase Functions |
| `CarlosAlcivar94/FutureBalance` | `~/Dev/FutureBalance` | Flutter + Firebase Functions |
| `CarlosAlcivar94/SATurno` | `~/Dev/SATurno` | Node/NestJS/Angular |
| `CarlosAlcivar94/GeCTExcel` | `~/Dev/gectexcel` | Python/FastAPI |
| `CarlosAlcivar94/AdminCenterKA94` | `~/Dev/AdminCenterKA94` | Flutter + Firebase Functions |
| `CarlosAlcivar94/GlobalView` | `~/Dev/globalview` | PHP/Composer + Node assets |
| `CarlosAlcivar94/CeviFlash` | `~/Dev/ceviflash` | Angular/Firebase |
| `CarlosAlcivar94/mpv-privacy-policy` | `~/Dev/mpv-privacy-policy` | Sitio estatico |

## Primer arranque en Ubuntu

Instala Git si Ubuntu no lo trae:

```bash
sudo apt-get update
sudo apt-get install -y git curl ca-certificates
```

Clona el repo del portal:

```bash
mkdir -p ~/Dev
git clone https://github.com/CarlosAlcivar94/mpv-privacy-policy.git ~/Dev/mpv-privacy-policy
cd ~/Dev/mpv-privacy-policy
```

Si los repos privados piden autenticacion, crea un token nuevo en GitHub con permiso `repo` y usalo solo en la sesion:

```bash
export GITHUB_TOKEN="PEGAR_TOKEN_NUEVO_AQUI"
```

Si decides restaurar algun proyecto desde Gitea/hospital en vez de GitHub, define la URL antes de correr el setup:

```bash
export SATURNO_REPO_URL="http://192.168.0.124:3000/ADMINISTRADOR/sistema-turnos-general.git"
export GECTEXCEL_REPO_URL="http://192.168.0.124:3000/ADMINISTRADOR/gectexcel.git"
export GLOBALVIEW_REPO_URL="http://192.168.0.124:3000/ADMINISTRADOR/globalview"
```

Ejecuta el setup:

```bash
chmod +x migration/setup-ubuntu-dev.sh
./migration/setup-ubuntu-dev.sh
```

Cierra y abre la terminal para que cargue `PATH`, `nvm`, Flutter y Dart.

## Android/Flutter

Abre Android Studio una vez e instala:

- Android SDK Platform
- Android SDK Command-line Tools
- Android SDK Build-Tools
- Android Emulator si vas a probar con emulador

Luego:

```bash
flutter doctor --android-licenses
flutter doctor
```

Para compilar apps Android:

```bash
cd ~/Dev/MVP
flutter pub get
flutter build appbundle
```

```bash
cd ~/Dev/FutureBalance
flutter pub get
flutter build appbundle
```

## Restaurar secretos locales

Antes de formatear Windows, exporta secretos desde el repo del portal:

```powershell
cd C:\mpv-privacy-policy
powershell -ExecutionPolicy Bypass -File .\migration\export-local-secrets.ps1 -OutputPath E:\ka94-secrets.bundle.json
```

Guarda `ka94-secrets.bundle.json` en USB o almacenamiento privado. No lo subas a Git.

En Ubuntu, despues de clonar proyectos:

```bash
sudo apt-get install -y python3-cryptography
python3 ~/Dev/mpv-privacy-policy/migration/import-local-secrets.py /ruta/ka94-secrets.bundle.json --destination ~/Dev --dry-run
python3 ~/Dev/mpv-privacy-policy/migration/import-local-secrets.py /ruta/ka94-secrets.bundle.json --destination ~/Dev
```

## Verificacion final

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

Luego:

```bash
cd ~/Dev/mpv-privacy-policy
git status
```

Y por proyecto:

```bash
for dir in ~/Dev/MVP ~/Dev/FutureBalance ~/Dev/SATurno ~/Dev/gectexcel ~/Dev/AdminCenterKA94 ~/Dev/globalview ~/Dev/ceviflash ~/Dev/mpv-privacy-policy; do
  echo "=== $dir ==="
  git -C "$dir" status --short
done
```

El estado esperado despues de restaurar es que todos los repos esten clonados, dependencias instaladas y secretos recuperados donde correspondan. Los archivos generados como `.venv`, `node_modules`, `build`, `.dart_tool` y `vendor` no deben subirse a Git.
