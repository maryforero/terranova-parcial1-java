# Sprint 2 - Retrospective

**Fecha:** 2026-09-10

## Que funciono bien
- Reutilizar el mismo patron de "verificar dueno antes de mostrar o
  modificar" (`WHERE id_propiedad=? AND id_agente=?`, salvo para
  administrador) en formulario, baja, imagenes y caracteristicas hizo
  que agregar cada pantalla nueva fuera rapido y consistente.
- Probar activamente con DOS agentes distintos (no solo uno) fue lo que
  permitio confirmar que el aislamiento por dueno realmente funciona,
  en vez de asumirlo por lectura de codigo.

## Que no funciono / dificultades
- La primera version de "galeria de imagenes" no controlaba que el
  `id_propiedad` recibido por parametro perteneciera al agente en
  sesion; se corrigio agregando la misma verificacion de dueno que ya
  se usaba en `formulario.jsp` antes de insertar o borrar una imagen.

## Acciones para el siguiente sprint
- Aplicar el mismo patron de verificacion de dueno a citas y
  solicitudes (el agente solo debe poder cambiar el estado de citas o
  solicitudes de SUS propiedades, nunca de otro agente).
- Documentar las 5 consultas obligatorias con JOIN/LEFT JOIN/GROUP BY a
  medida que se construya el modulo de reportes, no al final.
