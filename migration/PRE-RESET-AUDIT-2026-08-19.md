# Auditoria pre-reset KA94 - 2026-08-19

Objetivo: confirmar que los proyectos son recuperables antes de resetear Windows e instalar Ubuntu.

## Resultado ejecutivo

No resetees todavia si quieres recuperar el estado exacto actual.

La mayoria de proyectos quedaron limpios localmente. El bloqueo pendiente es alinear GitHub `main` con la copia local en MPV, FutureBalance y GeCTExcel. Si Ubuntu clona solo desde GitHub hoy, esos tres no recuperan exactamente el HEAD local actual.

## Estado por proyecto

| Proyecto | Carpeta Windows | Fuente remota observada | Estado |
| --- | --- | --- | --- |
| MPV | `C:\mpv` | GitHub `CarlosAlcivar94/MVP` | Carpeta local limpia, pero HEAD local `6951739` no coincide con GitHub `main` `353f2cf`; el HEAD local no aparecio en remotos configurados. |
| FutureBalance | `C:\FutureBalance` | GitHub `CarlosAlcivar94/FutureBalance` | Carpeta local limpia, pero HEAD local `344ba84` no coincide con GitHub `main` `7a1045e`; el HEAD local no aparecio en remotos configurados. |
| SATurno | `C:\turnero` | Gitea/hospital y GitHub | Limpio y alineado con GitHub `main` (`6a43131`). |
| GeCTExcel | `C:\GeCTExcel` | Gitea/hospital, GitHub esperado `CarlosAlcivar94/GeCTExcel` | Carpeta local limpia. HEAD local `3b7bc64` existe en Gitea `origin`, pero no coincide con GitHub `main` `f354dc5`. |
| ACKA94 | `C:\AdminCenterKA94` | GitHub `CarlosAlcivar94/AdminCenterKA94` | Limpio y alineado con GitHub `main` (`7328bfc`). |
| GlobalView | `C:\globalview` | Gitea/hospital y GitHub `CarlosAlcivar94/GlobalView` | Limpio y alineado con GitHub `main` (`10ca508`). |
| CeviFlash | `C:\Users\Administrador1\Documents\New project 2` | GitHub `CarlosAlcivar94/CeviFlash` | Limpio y alineado con GitHub `main` (`cf78f37`). |
| KA94 Studio Site | `C:\mpv-privacy-policy` | GitHub `CarlosAlcivar94/mpv-privacy-policy` | Tenia cambios locales de este manual; debe quedar limpio despues de commitear y subir estos archivos. |

## Memorias y documentos

| Proyecto | Memorias/docs observadas | Riesgo |
| --- | --- | --- |
| MPV | `CODEX.MD`, `PLAN.MD`, `README.md` | Memorias presentes, pero GitHub `main` no esta en el mismo HEAD local. |
| FutureBalance | `CODEX.MD`, `PLAN.MD`, `README.md`, `RECOVERY.md` | Memorias presentes, pero GitHub `main` no esta en el mismo HEAD local. |
| SATurno | `README.md`, `CLAUDE.md`, `info/codex.md`, `info/plan.md`, `info/manual-instalacion.md` | Recuperable desde GitHub; no esta estandarizado como `CODEX.MD` + `PLAN.MD` en raiz, pero tiene memoria en `info/`. |
| GeCTExcel | `codex.md`, `plan.md`, `README.md`, `DEPENDENCIAS.md`, `MANUAL_REINSTALACION_UBUNTU.md` | Memorias presentes; confirmar remoto canonico porque GitHub no coincide con local. |
| ACKA94 | `CODEX.MD`, `PLAN.MD`, `README.md`, `docs/ubuntu_recovery_manual.md` | Correcto y alineado con GitHub. |
| GlobalView | `codex.md`, `plan.md`, `README.md`, `MANUAL_REINSTALACION_UBUNTU.md` | Correcto y alineado con GitHub. |
| CeviFlash | `codes.md`, `plan.md`, `README.md`, `docs/dependencias.md`, `docs/restauracion-ubuntu.md` | Correcto y alineado con GitHub, aunque el archivo equivalente a Codex se llama `codes.md`. |
| KA94 Studio Site | `README.md`, `migration/*.md` | Este repo queda como manual central de restauracion. |

## Pendientes antes de resetear

1. Reconciliar/pushear MPV: local `6951739` vs GitHub `353f2cf`.
2. Reconciliar/pushear FutureBalance: local `344ba84` vs GitHub `7a1045e`.
3. Reconciliar/pushear GeCTExcel: local `3b7bc64` vs GitHub `f354dc5`, o restaurarlo desde Gitea usando `GECTEXCEL_REPO_URL`.
4. Exportar secretos locales con `migration/export-local-secrets.ps1` y guardar el bundle fuera del disco que se va a formatear.
5. Guardar aparte llaves Android, `.env`, service accounts, certificados y cualquier archivo Excel con datos reales que no deba ir a Git.

## Comando de auditoria

Ejecutar antes del reset:

```powershell
cd C:\mpv-privacy-policy
git pull
powershell -ExecutionPolicy Bypass -File .\migration\pre-reset-audit.ps1 -Online
```

El auditor online ahora revisa GitHub esperado y tambien los remotos configurados como `origin`, `github` o `hospital`.

El resultado ideal antes de resetear es:

- `Changed/untracked files: 0` en todos los proyectos.
- `Local HEAD` igual a `GitHub main HEAD` si GitHub sera la fuente de restauracion.
- `Local HEAD exists on configured remote(s)` en al menos un remoto duradero si se acepta restaurar desde Gitea.
- Secretos exportados y probados con un dry run.
