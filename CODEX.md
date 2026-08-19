# KA94 Studio Portal - Codex Memory

Este repositorio es el punto central de recuperacion y documentacion publica de KA94 Studio.

## Rol del proyecto

- Publica el sitio estatico de KA94 Studio en `https://ka94studio.com`.
- Mantiene el portafolio principal, fichas de proyectos, politicas de privacidad, manuales y paginas de eliminacion de cuenta.
- Centraliza scripts de migracion para restaurar los proyectos en otra PC o en Ubuntu despues de resetear Windows.
- No es el repositorio fuente de las apps, solo el portal y el tablero de recuperacion.

## Repositorios gestionados

| Proyecto | Repo esperado | Carpeta Ubuntu | Perfil |
| --- | --- | --- | --- |
| MPV | `CarlosAlcivar94/MVP` | `~/Dev/MVP` | Flutter + Firebase Functions |
| FutureBalance | `CarlosAlcivar94/FutureBalance` | `~/Dev/FutureBalance` | Flutter + Firebase Functions |
| SATurno | `CarlosAlcivar94/SATurno` | `~/Dev/SATurno` | Node/NestJS/Angular |
| GeCTExcel | `CarlosAlcivar94/GeCTExcel` o Gitea/hospital | `~/Dev/gectexcel` | Python/FastAPI |
| ACKA94 | `CarlosAlcivar94/AdminCenterKA94` | `~/Dev/AdminCenterKA94` | Flutter + Firebase Functions |
| GlobalView | `CarlosAlcivar94/GlobalView` | `~/Dev/globalview` | PHP/Composer + Node assets |
| CeviFlash | `CarlosAlcivar94/CeviFlash` | `~/Dev/ceviflash` | Angular/Firebase |
| Sitio KA94 | `CarlosAlcivar94/mpv-privacy-policy` | `~/Dev/mpv-privacy-policy` | Sitio estatico |

## Archivos clave

- `index.html`: portafolio principal.
- `app/index.html`: indice liviano para documentacion abierta desde apps.
- `apps/mpv/`: paginas publicas de MPV.
- `apps/futurebalance/`: paginas publicas de FutureBalance.
- `projects/*/`: fichas publicas de proyectos.
- `app-ads.txt`: archivo raiz requerido por AdMob.
- `migration/projects.ps1`: inventario canonico de proyectos para Windows.
- `migration/setup-ubuntu-dev.sh`: instalacion y clonacion base en Ubuntu.
- `migration/UBUNTU-RESET-GUIDE.md`: manual principal de restauracion en Ubuntu.
- `migration/PRE-RESET-AUDIT-2026-08-19.md`: ultimo snapshot pre-reset.
- `migration/pre-reset-audit.ps1`: auditor antes de formatear.
- `migration/export-local-secrets.ps1`: exporta secretos cifrados desde Windows.
- `migration/import-local-secrets.py`: importa secretos cifrados en Ubuntu.

## Politica de secretos

No subir secretos a Git:

- `.env`
- tokens
- `google-services.json` si contiene configuracion sensible local no destinada a publicarse
- `key.properties`
- `*.jks`, `*.keystore`, `*.p12`, `*.pem`
- service accounts
- archivos Excel con datos reales

La ruta correcta es:

1. Codigo y documentacion en GitHub/Gitea.
2. Secretos en `ka94-secrets.bundle.json`, cifrado con passphrase.
3. Bundle guardado fuera del disco que se va a formatear.

## Estado pre-reset importante

Antes de resetear Windows e instalar Ubuntu, ejecutar:

```powershell
cd C:\mpv-privacy-policy
git pull
powershell -ExecutionPolicy Bypass -File .\migration\pre-reset-audit.ps1 -Online
```

No resetear hasta que:

- Todos los proyectos tengan `Changed/untracked files: 0`.
- GitHub `main` coincida con el HEAD local si GitHub sera la fuente de restauracion.
- Si se usa Gitea/hospital, el auditor debe indicar que el HEAD local existe en ese remoto.
- El bundle de secretos haya sido exportado y probado con dry run.

## Estado observado el 2026-08-19

- `SATurno`, `ACKA94`, `GlobalView`, `CeviFlash` y este sitio estaban alineados con GitHub.
- `MPV`, `FutureBalance` y `GeCTExcel` necesitaban reconciliar/pushear antes de restaurar solo desde GitHub.
- `GeCTExcel` estaba respaldado en Gitea/hospital, pero no alineado con GitHub.

## Reglas de mantenimiento

- Mantener este repo publico si GitHub Pages sigue sirviendo `ka94studio.com`.
- Mantener `app-ads.txt` en la raiz del dominio.
- Actualizar politicas por app cuando cambien permisos, anuncios, compras, cuentas, almacenamiento, Firebase, Analytics, soporte o eliminacion de datos.
- Actualizar `migration/projects.ps1` y `migration/setup-ubuntu-dev.sh` cuando se agregue un proyecto nuevo.
- Mantener `CODEX.md`, `PLAN.md` y `DEPENDENCIAS.md` al dia, porque son la memoria operativa para Codex despues del reset.
