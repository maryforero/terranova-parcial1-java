# Sprint 3 - Retrospective

**Fecha:** 2026-09-10

## Que funciono bien
- El patron "el filtro de servlet solo exige rol o login; la regla fina
  de propiedad del recurso se valida dentro del JSP" resulto ser el
  diseño correcto para `citas/cambiarEstado.jsp`, que atiende a la vez
  a agentes/admin (confirmar/rechazar) y a clientes (cancelar la suya).
  Intentar resolver eso solo con el `AccesoFilter` habria requerido
  logica de negocio (quien es dueno de que) dentro del filtro, que es
  el lugar equivocado para eso.
- Reutilizar el `.gitignore` de lista blanca (en vez de excluir
  archivo por archivo) evito por completo el riesgo de subir al
  repositorio publico las credenciales de bases de datos en linea que
  existen en carpetas vecinas del mismo contexto compartido de Tomcat
  (`MySQL Online/`, `PostgreSQL Online/`).

## Que no funciono / dificultades
- Ninguna dificultad tecnica nueva en este sprint; los problemas de
  entorno (bug de `System` en Jasper, espacios en la ruta) ya se habian
  resuelto y documentado en el Sprint 1.

## Cierre del proyecto
- Con este sprint se completa el 100% del backlog comprometido
  (HU-01 a HU-16). Pendiente fuera del alcance de este entregable:
  despliegue en linea de la base de datos y la aplicacion (otorga
  puntos adicionales segun el enunciado, no es obligatorio) y carga
  binaria real de archivos para documentos/imagenes (se documento la
  simplificacion tomada).
