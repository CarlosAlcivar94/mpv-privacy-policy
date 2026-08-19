# KA94 Studio Portal - Plan

## Objetivo

Dejar este repositorio como punto de restauracion confiable para que, despues de instalar Ubuntu, Codex pueda clonar proyectos, instalar dependencias, restaurar secretos y continuar el trabajo sin perdida de contexto.

## Antes de resetear Windows

1. Ejecutar auditoria online:

```powershell
cd C:\mpv-privacy-policy
powershell -ExecutionPolicy Bypass -File .\migration\pre-reset-audit.ps1 -Online
```

2. Resolver cualquier proyecto con:

- `Changed/untracked files` mayor a `0`.
- `Local HEAD` distinto a `GitHub main HEAD`, si GitHub sera la fuente de restauracion.
- HEAD local solo en Gitea cuando se planee restaurar desde GitHub.

3. Exportar secretos:

```powershell
cd C:\mpv-privacy-policy
powershell -ExecutionPolicy Bypass -File .\migration\export-local-secrets.ps1 -OutputPath E:\ka94-secrets.bundle.json
```

4. Guardar fuera del disco a formatear:

- `ka94-secrets.bundle.json`
- passphrase del bundle
- llaves de firma Android si no quedaron en el bundle
- cuentas de Google Play, Firebase, GitHub, Gitea, Cloudflare y AdMob

## Despues de instalar Ubuntu

1. Instalar Git y clonar este repo:

```bash
sudo apt-get update
sudo apt-get install -y git curl ca-certificates
mkdir -p ~/Dev
git clone https://github.com/CarlosAlcivar94/mpv-privacy-policy.git ~/Dev/mpv-privacy-policy
cd ~/Dev/mpv-privacy-policy
```

2. Ejecutar setup:

```bash
export GITHUB_TOKEN="PEGAR_TOKEN_NUEVO_AQUI"
chmod +x migration/setup-ubuntu-dev.sh
./migration/setup-ubuntu-dev.sh
```

3. Si GeCTExcel se restaura desde Gitea:

```bash
export GECTEXCEL_REPO_URL="http://192.168.0.124:3000/ADMINISTRADOR/gectexcel.git"
./migration/setup-ubuntu-dev.sh
```

4. Restaurar secretos:

```bash
python3 ~/Dev/mpv-privacy-policy/migration/import-local-secrets.py /ruta/ka94-secrets.bundle.json --destination ~/Dev --dry-run
python3 ~/Dev/mpv-privacy-policy/migration/import-local-secrets.py /ruta/ka94-secrets.bundle.json --destination ~/Dev
```

5. Abrir Android Studio e instalar SDK Android. Luego:

```bash
flutter doctor --android-licenses
flutter doctor
```

## Validacion final

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

```bash
for dir in ~/Dev/MVP ~/Dev/FutureBalance ~/Dev/SATurno ~/Dev/gectexcel ~/Dev/AdminCenterKA94 ~/Dev/globalview ~/Dev/ceviflash ~/Dev/mpv-privacy-policy; do
  echo "=== $dir ==="
  git -C "$dir" status --short
done
```

## Backlog de mantenimiento

- Crear una version Linux del auditor remoto si hace falta verificar desde Ubuntu.
- Agregar nuevos proyectos al inventario apenas tengan repo.
- Mantener sincronizados README, CODEX, PLAN y guias de restauracion.
- Revisar periodicamente que las politicas publicas sigan alineadas con Google Play Console.
- Confirmar que `app-ads.txt` siga visible en `https://ka94studio.com/app-ads.txt`.
