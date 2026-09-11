# Sprint 2 - Review

**Fecha de la demo:** 2026-09-10

## Incremento demostrado
- CRUD de propiedades (`propiedades/listar.jsp`, `formulario.jsp`,
  `guardar.jsp`, `baja.jsp`) probado end-to-end como agente:
  - Creacion de una propiedad nueva -> aparece en "Mis propiedades".
  - Matricula inmobiliaria duplicada -> mensaje amigable, sin excepcion.
  - Otro agente no puede editar ni ver el formulario de una propiedad
    ajena (verificado: `formulario.jsp?id=X` de otro agente no carga
    los datos).
  - Baja logica (`estado='INACTIVO'`) en vez de DELETE fisico.
- Galeria de imagenes (`propiedades/imagenes.jsp`) y caracteristicas
  N:M (`propiedades/caracteristicas.jsp`) probadas: se agrego una
  imagen marcada como principal y se asignaron 2 caracteristicas a una
  propiedad de prueba, confirmado en base de datos.
- Perfil (`perfil/verPerfil.jsp`): edicion de datos personales y cambio
  de clave (verifica la clave actual con `PasswordUtil.verificar` antes
  de permitir el cambio).
- Favoritos: marcar/desmarcar una propiedad y verlas listadas en
  `favoritos/listar.jsp`.
- Paneles por rol con metricas reales calculadas por consulta SQL
  (usuarios activos, propiedades publicadas, citas/solicitudes
  pendientes, filtradas por agente cuando corresponde).

## Historias completadas
HU-05, HU-06 (con sus tres sub-tareas), HU-08, paneles diferenciados.
Todas las comprometidas se cerraron; no hubo historias que pasaran al
siguiente sprint.

## Metricas
- 22/22 puntos de historia comprometidos, completados: 22 (100%).
