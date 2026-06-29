# Transferir usuarios, contrasenas y archivos secretos

No pongas usuarios, contrasenas, tokens, `.env`, keystores ni archivos Firebase dentro de GitHub. Aunque el repo sea privado, esos secretos quedan en historial y son dificiles de limpiar.

La ruta segura es moverlos en un bundle cifrado.

## 1. Exportar en la PC actual

```powershell
cd C:\mpv-privacy-policy
powershell -ExecutionPolicy Bypass -File .\migration\export-local-secrets.ps1 -OutputPath C:\DevTransfer\ka94-secrets.bundle.json
```

El script pedira una passphrase. Usa una frase larga, no una contrasena corta.

El bundle se crea en:

```text
C:\DevTransfer\ka94-secrets.bundle.json
```

Muevelo a la otra PC por USB o canal privado. No lo subas a GitHub.

## 2. Importar en la PC nueva

Primero clona los proyectos y corre `setup-new-pc.ps1`. Despues restaura secretos:

```powershell
cd C:\Dev\mpv-privacy-policy
powershell -ExecutionPolicy Bypass -File .\migration\import-local-secrets.ps1 -BundlePath C:\DevTransfer\ka94-secrets.bundle.json -Destination C:\Dev
```

Si quieres revisar sin escribir:

```powershell
powershell -ExecutionPolicy Bypass -File .\migration\import-local-secrets.ps1 -BundlePath C:\DevTransfer\ka94-secrets.bundle.json -Destination C:\Dev -DryRun
```

Si ya existen archivos y quieres reemplazarlos:

```powershell
powershell -ExecutionPolicy Bypass -File .\migration\import-local-secrets.ps1 -BundlePath C:\DevTransfer\ka94-secrets.bundle.json -Destination C:\Dev -Overwrite
```

## Archivos incluidos

El manifiesto esta en:

```text
migration\secrets-manifest.ps1
```

Incluye, entre otros:

- MPV: `google-services.json`, `android/key.properties`, keystore.
- FutureBalance: `google-services.json`, `android/key.properties`, keystore.
- Turnero: `apps/backend/.env`.
- GeCTExcel: `.env`, `services.json`.
- ACKA94: `functions/.env` y archivos Android/Firebase si existen.
- GLOBALVIEW: `.env`, `config.php`.
- CEVIFLASH: environments si existen.

Si falta algun archivo, agregalo al manifiesto y vuelve a exportar.

## Regla operativa

- Repositorios: codigo.
- Bundle cifrado: secretos.
- Nueva PC: clonar codigo, instalar dependencias, importar secretos.

