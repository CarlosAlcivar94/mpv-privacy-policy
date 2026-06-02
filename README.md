# ACKA94 app policies

Sitio estatico para mantener politicas de privacidad, manuales y enlaces de eliminacion de cuenta por aplicacion.

## Estructura

- `index.html`: portada general del centro documental.
- `app/index.html`: indice ligero pensado para abrir desde las apps.
- `apps/mpv/`: documentacion de My Vehicle Planner.
- `apps/futurebalance/`: documentacion de FutureBalance.
- `assets/site.css`: estilos compartidos.
- `assets/branding/`: logos usados por el portal.

## URLs para Google Play Console

Usar URLs directas por app:

| App | Privacy Policy | Data deletion |
| --- | --- | --- |
| My Vehicle Planner | `apps/mpv/privacy.html` | `apps/mpv/account-deletion.html` |
| FutureBalance | `apps/futurebalance/privacy.html` | `apps/futurebalance/account-deletion.html` |

`index.html` es solo una portada. No conviene usarlo como URL de politica en Play Console.

## Mantenimiento

Cuando una app cambie permisos, SDKs, anuncios, compras, backups, Storage, Drive, soporte, Analytics o cualquier dato tratado:

1. Actualizar la politica de esa app.
2. Actualizar la pagina de eliminacion si cambia el flujo de datos.
3. Revisar el formulario Data safety de Play Console.
4. Confirmar que la app tiene enlace interno a la politica y a la eliminacion de cuenta si permite crear cuenta.

Referencias oficiales:

- Google Play User Data policy: https://support.google.com/googleplay/android-developer/answer/10144311
- Google Play Data safety: https://support.google.com/googleplay/android-developer/answer/10787469
- Account deletion requirements: https://support.google.com/googleplay/android-developer/answer/13327111
