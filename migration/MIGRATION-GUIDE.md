# Migracion de proyectos KA94 a GitHub privado

Objetivo: llevar los proyectos de esta PC a repositorios privados de GitHub y clonarlos en otra PC para seguir programando.

## Repos detectados

- `C:\mpv` -> `CarlosAlcivar94/MVP`
- `C:\FutureBalance` -> `CarlosAlcivar94/FutureBalance`
- `C:\turnero` -> `CarlosAlcivar94/saturno-turnero`
- `C:\GeCTExcel` -> `CarlosAlcivar94/gectexcel`
- `C:\AdminCenterKA94` -> `CarlosAlcivar94/acka94-admin-center`
- `C:\globalview` -> `CarlosAlcivar94/globalview`
- `C:\Users\Administrador1\Documents\New project 2` -> `CarlosAlcivar94/ceviflash`
- `C:\FORMULARIOS` -> `CarlosAlcivar94/formularios-vba`
- `C:\mpv-privacy-policy` -> `CarlosAlcivar94/mpv-privacy-policy`

Nota: `mpv-privacy-policy` publica `ka94studio.com`. No lo conviertas a privado si tu GitHub Pages depende de repo publico.

## Ruta recomendada completa

El proceso tiene dos fases:

- **PC actual:** crear/subir repos privados de GitHub.
- **PC nueva:** instalar herramientas, clonar repos e instalar dependencias.

No conviene copiar carpetas manualmente porque arrastras `node_modules`, `build`, caches, APK/AAB, tokens y archivos temporales. GitHub privado + reinstalacion limpia deja la otra PC reproducible.

## Fase 1: PC actual

1. Instala Git en la nueva PC si no existe.
2. En esta PC, audita archivos sensibles antes de subir:

```powershell
cd C:\mpv-privacy-policy
powershell -ExecutionPolicy Bypass -File .\migration\audit-projects.ps1
```

3. Corrige `.gitignore` o elimina credenciales reales antes de subir. No subas:

- `.env`
- `key.properties`
- `*.jks`, `*.keystore`, `*.p12`, `*.pem`
- service accounts de Firebase o Google Cloud
- bases `.db` / `.sqlite`
- backups `.zip`, `.7z`, `.rar`
- archivos Excel con datos reales de pacientes, clientes o institucion

4. Crea un token temporal de GitHub. Opcion simple: token clasico con permiso `repo`. Guardalo solo en la sesion actual:

```powershell
$env:GITHUB_TOKEN = "PEGAR_TOKEN_AQUI"
```

5. Primero corre simulacion:

```powershell
cd C:\mpv-privacy-policy
powershell -ExecutionPolicy Bypass -File .\migration\publish-to-github-private.ps1 -Owner CarlosAlcivar94
```

6. Si la auditoria esta limpia, ejecuta subida real:

```powershell
powershell -ExecutionPolicy Bypass -File .\migration\publish-to-github-private.ps1 -Owner CarlosAlcivar94 -Execute
```

Si un proyecto queda bloqueado por archivos sensibles, revisa lo que imprime el script. Solo usa `-AllowSensitiveFiles` si verificaste manualmente que esos archivos no contienen secretos ni datos reales.

Para intentar convertir repos existentes a privados desde el API:

```powershell
powershell -ExecutionPolicy Bypass -File .\migration\publish-to-github-private.ps1 -Owner CarlosAlcivar94 -Execute -MakeExistingReposPrivate
```

No uses `-MakeExistingReposPrivate` con el repo del sitio publico si necesitas que GitHub Pages siga funcionando sin plan compatible.

## Fase 2: PC nueva automatizada

En la nueva PC necesitas una sesion de PowerShell como usuario normal. Para instalar herramientas con `winget`, puede pedir permisos de administrador segun el paquete.

1. Instala Git manualmente si todavia no puedes clonar este repo. Despues clona el repo del sitio para obtener los scripts:

```powershell
git clone https://github.com/CarlosAlcivar94/mpv-privacy-policy.git C:\Dev\mpv-privacy-policy
```

2. Ejecuta bootstrap completo:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Dev\mpv-privacy-policy\migration\setup-new-pc.ps1 -Owner CarlosAlcivar94 -Destination C:\Dev
```

Este script intenta instalar:

- Git
- GitHub CLI
- Node.js LTS
- Python 3.12
- Java JDK 17
- PHP 8.3
- Composer
- Android Studio
- Visual Studio Code
- Flutter estable en `C:\development\flutter`

Luego clona los repos privados y ejecuta dependencias:

- Flutter: `flutter pub get`
- Node/Angular: `npm ci` o comandos definidos del proyecto
- Turnero: `npm run install:frontend` y `npm run install:backend`
- Python: crea `.venv` e instala `requirements.txt`
- PHP: `composer install`

3. Para clonar repos privados sin prompts, usa un token temporal:

```powershell
$env:GITHUB_TOKEN = "PEGAR_TOKEN_AQUI"
powershell -ExecutionPolicy Bypass -File C:\Dev\mpv-privacy-policy\migration\setup-new-pc.ps1 -Owner CarlosAlcivar94 -Destination C:\Dev
```

4. Si ya instalaste herramientas y solo quieres clonar/instalar dependencias:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Dev\mpv-privacy-policy\migration\setup-new-pc.ps1 -Owner CarlosAlcivar94 -Destination C:\Dev -SkipToolInstall
```

5. Si ya clonaste todo y solo quieres reinstalar dependencias:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Dev\mpv-privacy-policy\migration\setup-new-pc.ps1 -Owner CarlosAlcivar94 -Destination C:\Dev -SkipToolInstall -SkipClone
```

6. Para Android/Flutter, revisa al final:

```powershell
flutter doctor
```

Si Android Studio no deja listo el SDK, abre Android Studio una vez e instala:

- Android SDK Platform
- Android SDK Command-line Tools
- Android SDK Build-Tools
- Android Emulator si vas a probar emulador

Luego ejecuta:

```powershell
flutter doctor --android-licenses
```

El script soporta `-AcceptAndroidLicenses`, pero ese paso puede ser interactivo o depender del SDK instalado:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Dev\mpv-privacy-policy\migration\setup-new-pc.ps1 -Owner CarlosAlcivar94 -Destination C:\Dev -AcceptAndroidLicenses
```

## En la nueva PC, modo manual

Configura Git:

```powershell
git config --global user.name "Carlos Alcivar"
git config --global user.email "tu-correo-de-github@example.com"
```

Clona primero el repo del sitio para obtener estos scripts:

```powershell
git clone https://github.com/CarlosAlcivar94/mpv-privacy-policy.git C:\Dev\mpv-privacy-policy
```

Luego clona los proyectos privados sin instalar herramientas:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Dev\mpv-privacy-policy\migration\clone-on-new-pc.ps1 -Owner CarlosAlcivar94 -Destination C:\Dev
```

Si tambien quieres clonar el repo del sitio con el script:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Dev\mpv-privacy-policy\migration\clone-on-new-pc.ps1 -Owner CarlosAlcivar94 -Destination C:\Dev -IncludePublicSite
```

## Comandos manuales por si no usas script

Para un proyecto nuevo:

```powershell
cd C:\turnero
git init -b main
git add -A
git commit -m "Initial private backup"
git remote add github-private https://github.com/CarlosAlcivar94/saturno-turnero.git
git push -u github-private main
```

Para clonar en la otra PC:

```powershell
git clone https://github.com/CarlosAlcivar94/saturno-turnero.git C:\Dev\saturno-turnero
```
