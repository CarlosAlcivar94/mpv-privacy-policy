# Manual de usuario - MPV Mantenimiento Vehicular

## Proposito
Este manual explica como usar la aplicacion MPV para administrar vehiculos, mantenimientos, gastos, repostajes, documentos, analisis y respaldos.

La aplicacion esta pensada para llevar el control operativo de uno o varios vehiculos desde una experiencia simple: registrar lo que ocurre, revisar el estado del vehiculo activo y conservar continuidad de datos mediante backup.

## Primer ingreso
1. Abre la aplicacion.
2. Inicia sesion con tu cuenta.
3. Si no tienes vehiculos registrados, usa la accion `Agregar mi primer vehiculo`.
4. Completa la informacion base del vehiculo.
5. Guarda el vehiculo para entrar al resumen principal.

Si ya tienes vehiculos registrados, la app abre el contexto del vehiculo activo y permite cambiar de vehiculo desde el selector o desde `Ver garaje`.

## Navegacion principal
La pantalla del vehiculo activo se organiza en pestanas inferiores:

- `Resumen`: estado general del vehiculo, avisos, acciones rapidas y costos principales.
- `Mant.`: historial de mantenimientos, avisos activos, recurrencias y garantia.
- `Gastos`: gastos generales asociados al vehiculo.
- `Consumo`: repostajes y consumo de combustible.
- `Analisis`: metricas y graficos por periodo.

Desde el menu superior puedes acceder a:

- `Ajustes`
- `Ver garaje`
- `Cerrar sesion`

## Garaje
El garaje permite ver y administrar los vehiculos registrados.

### Registrar un vehiculo
1. Entra a `Ver garaje` o usa una accion de agregar vehiculo.
2. Completa los campos principales:
   - alias del vehiculo
   - marca
   - modelo
   - anio
   - kilometraje actual
3. Opcionalmente agrega:
   - foto del vehiculo
   - placa
   - VIN
   - tipo de combustible
   - capacidad del tanque
   - aceite recomendado
   - medida de llantas
   - presion sugerida delantera y trasera
4. Guarda el vehiculo.

### Editar un vehiculo
1. Abre el detalle del vehiculo.
2. Usa el menu de acciones.
3. Selecciona `Editar vehiculo`.
4. Ajusta los datos necesarios y guarda.

### Eliminar un vehiculo
1. Abre el detalle del vehiculo o el garaje.
2. Usa la accion `Eliminar vehiculo`.
3. Confirma la eliminacion.

La app bloquea la eliminacion si el vehiculo tiene registros asociados, como mantenimientos, gastos, repostajes o documentos. Esto evita dejar historial suelto o inconsistente.

## Resumen del vehiculo
La pestana `Resumen` muestra una vista rapida del estado del vehiculo activo.

Aqui puedes revisar:

- kilometraje actual
- avisos activos
- proximo mantenimiento
- ultimo mantenimiento
- ultima actividad
- gasto acumulado
- gasto del mes

Tambien tienes accesos rapidos para:

- agregar mantenimiento
- agregar gasto
- agregar repostaje

En plan Gratis pueden aparecer banners discretos en esta seccion. En plan Pro los anuncios se ocultan.

## Mantenimientos
La pestana `Mant.` concentra el historial y los avisos de mantenimiento.

### Registrar mantenimiento
1. Entra a `Mant.`.
2. Presiona `Nuevo` o usa `Agregar mantenimiento` desde accesos rapidos.
3. Selecciona el tipo de mantenimiento.
4. Completa:
   - kilometraje
   - costo total
   - fecha del servicio
5. Opcionalmente agrega:
   - icono o imagen del mantenimiento
   - desglose de partes y mano de obra
   - proximo vencimiento por fecha
   - proximo vencimiento por kilometraje
   - repeticion cada cierto kilometraje
   - repeticion cada cierta cantidad de meses
   - taller o proveedor
   - notas
   - adjuntos
   - garantia del servicio
6. Guarda el mantenimiento.

### Estados de aviso
Un mantenimiento puede tener estos estados:

- `Sin vencimiento`: no tiene proximo vencimiento configurado.
- `Al dia`: tiene vencimiento, pero no esta cerca.
- `Proximo`: faltan 30 dias o menos, o 1000 km o menos.
- `Vencido`: la fecha ya paso o el kilometraje objetivo ya fue alcanzado.

### Avisos activos
Cuando un mantenimiento tiene vencimiento o recurrencia, puede aparecer como aviso activo.

Desde un aviso puedes:

- `Registrar ahora`: crea un nuevo mantenimiento prellenado a partir del aviso.
- `Cerrar aviso`: oculta el aviso sin borrar el mantenimiento original.

Si el mantenimiento tiene recurrencia, al registrar desde el aviso la app puede calcular el siguiente vencimiento por kilometraje o por meses.

### Garantia de servicio
Al registrar un mantenimiento puedes agregar informacion de garantia:

- garantia hasta una fecha
- garantia hasta cierto kilometraje
- revision de garantia cada cierta cantidad de meses
- revision de garantia cada cierto kilometraje

En el historial puedes:

- marcar una revision de garantia como realizada
- cerrar una garantia cuando ya no aplica

El cierre de garantia es independiente del cierre de avisos recurrentes.

### Editar o eliminar mantenimiento
En cada item del historial puedes usar las acciones disponibles para:

- editar el registro
- eliminarlo
- detener recurrencia, si aplica

Al editar un mantenimiento ya cerrado o completado, la app conserva su estado salvo que cambies su plan de vencimiento.

## Gastos
La pestana `Gastos` registra costos generales que no necesariamente son mantenimiento ni combustible.

### Registrar gasto
1. Entra a `Gastos`.
2. Presiona `Nuevo`.
3. Selecciona el tipo de gasto.
4. Completa el monto y la fecha.
5. Opcionalmente agrega:
   - tipo personalizado
   - icono o imagen
   - kilometraje
   - notas
   - adjuntos
6. Guarda el gasto.

### Editar o eliminar gasto
Desde el historial de gastos puedes editar o eliminar registros. La app muestra confirmacion antes de eliminar.

## Consumo de combustible
La pestana `Consumo` permite registrar repostajes y calcular metricas de uso.

### Registrar repostaje
1. Entra a `Consumo` o usa `Agregar repostaje` desde `Resumen`.
2. Selecciona el tipo de combustible.
3. Completa:
   - kilometraje
   - costo total
   - precio por unidad
   - volumen
   - fecha
4. Marca si fue tanque lleno cuando corresponda.
5. Opcionalmente agrega notas.
6. Guarda el repostaje.

La app mantiene internamente los datos de volumen en galones, pero puede mostrarlos en galones o litros segun tus ajustes.

### Consumo y precision
Las metricas de rendimiento son mas confiables cuando registras repostajes completos y marcas correctamente `tanque lleno`. Si faltan datos suficientes, la app evita inventar resultados y muestra mensajes de datos insuficientes.

## Documentos del vehiculo
Desde el detalle del vehiculo puedes administrar documentos generales.

### Agregar documento
1. Abre el detalle del vehiculo.
2. Busca la seccion de documentos.
3. Selecciona `Agregar documento`.
4. Elige el tipo de documento.
5. Si usas tipo personalizado, escribe el nombre.
6. Selecciona el archivo.
7. Guarda el documento.

El plan Gratis tiene limite de cantidad y capacidad de documentos. Si alcanzas el limite, la app bloquea nuevas cargas, pero permite seguir consultando o eliminando documentos existentes.

## Analisis
La pestana `Analisis` muestra una lectura visual del comportamiento del vehiculo.

Puedes filtrar por:

- `30 dias`
- `3 meses`
- `6 meses`
- `12 meses`
- `Todo`

El analisis puede incluir:

- resumen ejecutivo del periodo
- gasto total
- gasto promedio
- movimientos del periodo
- avisos activos
- gastos por periodo
- distribucion por categoria
- consumo de combustible
- costo por kilometro
- evolucion de kilometraje
- resumen de mantenimiento
- actividad reciente
- indicador conservador de tanque

Si una seccion no tiene datos suficientes, la app muestra un estado vacio claro en lugar de mostrar graficos incompletos.

En plan Gratis pueden aparecer banners discretos en esta seccion. En plan Pro no se muestran anuncios.

## Ajustes
En `Ajustes` puedes configurar preferencias y funciones de cuenta.

### Tema e idioma
Puedes cambiar:

- tema visual: dia o noche
- idioma visible: espanol o ingles

### Unidades de medida
Puedes configurar:

- distancia: kilometros o millas
- volumen de combustible: galones o litros
- presion de llantas: PSI o bar

Cambiar unidades solo modifica la visualizacion. La app conserva el historial de forma canonica para mantener calculos y alertas consistentes.

### Plan
El bloque de plan muestra:

- plan actual: Gratis o Pro
- tipo de licencia
- limite de vehiculos
- estado de anuncios
- disponibilidad de backup automatico

Desde aqui puedes:

- ver beneficios Pro
- mejorar a Pro cuando la oferta este disponible
- restaurar una compra previa

## Plan Gratis y Plan Pro
La aplicacion mantiene el plan Gratis como una version util para operar un vehiculo.

### Gratis
Incluye:

- registro de un vehiculo
- mantenimientos
- gastos
- repostajes
- analisis
- backup manual
- documentos con limite
- banners discretos en zonas no criticas

### Pro
Agrega:

- multiples vehiculos
- sin anuncios
- backup automatico
- backup manual
- capacidad ampliada de documentos
- restauracion guiada
- compra de pago unico, no suscripcion

Los avisos de mejora aparecen principalmente cuando alcanzas un limite real, como crear mas vehiculos o subir mas documentos.

## Backup y restauracion
La app incluye respaldo en Google Drive.

### Crear backup manual
1. Entra a `Ajustes`.
2. Busca `Backup manual`.
3. Presiona `Crear backup ahora`.
4. Espera la confirmacion.

El backup manual esta disponible para usuarios Gratis y Pro.

### Restaurar backup
1. Entra a `Ajustes`.
2. Busca `Backup manual`.
3. Presiona `Restaurar desde backup`.
4. Elige el respaldo.
5. Confirma la restauracion.

Importante: restaurar un backup reemplaza los datos operativos actuales por los datos del respaldo seleccionado.

### Backup automatico Pro
En plan Pro puedes activar `Backup automatico`.

Cuando esta activo:

- la frecuencia fija es cada 24 horas
- se ejecuta en momentos seguros, como inicio de app o regreso a primer plano
- el backup manual sigue disponible
- `Ajustes` muestra ultimo exito o ultimo error para diagnostico

## Buenas practicas
- Registra el kilometraje real cada vez que agregues mantenimiento, gasto o repostaje.
- Marca `tanque lleno` solo cuando realmente corresponda.
- Usa vencimientos por fecha o kilometraje para mantenimientos importantes.
- Usa recurrencias para servicios periodicos como aceite, filtros o llantas.
- Adjunta documentos importantes del vehiculo, como matricula, seguro o revision.
- Crea backup manual antes de restaurar datos o hacer cambios grandes.
- Revisa `Analisis` despues de cargar varios registros para detectar tendencias de gasto y consumo.

## Solucion de problemas
### No puedo crear otro vehiculo
Si estas en plan Gratis, el limite es un vehiculo. Puedes mejorar a Pro desde `Ajustes` para registrar multiples vehiculos.

### No puedo subir mas documentos
Puede que hayas alcanzado el limite del plan Gratis. Puedes eliminar documentos existentes o mejorar a Pro para ampliar capacidad.

### No veo graficos en Analisis
Algunas graficas requieren datos suficientes. Registra mantenimientos, gastos y repostajes con fecha y kilometraje para habilitar mas secciones.

### El rendimiento de combustible no aparece
El calculo necesita repostajes validos, especialmente pares de tanque lleno. Revisa que los registros tengan kilometraje, volumen y costo correctos.

### No puedo eliminar un vehiculo
La app protege vehiculos con datos asociados. Primero revisa si tiene mantenimientos, gastos, repostajes o documentos vinculados.

### La restauracion muestra una advertencia
Es normal. Restaurar reemplaza datos operativos actuales, por eso la app pide confirmacion antes de continuar.

## Alcance de datos del backup
El backup incluye datos operativos del usuario:

- vehiculos
- mantenimientos
- gastos
- repostajes
- documentos del vehiculo
- adjuntos de mantenimientos y gastos
- preferencias de usuario compatibles

El backup no debe modificar el estado de compra o plan del usuario.

