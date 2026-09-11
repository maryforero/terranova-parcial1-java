# Sprint 3 - Review

**Fecha de la demo:** 2026-09-10

## Incremento demostrado
- Citas (`citas/agendar.jsp`, `guardarCita.jsp`, `listar.jsp`,
  `cambiarEstado.jsp`) probadas end-to-end:
  - Cliente agenda una visita; agendar la MISMA propiedad a la MISMA
    hora una segunda vez arroja "horario ocupado" (UNIQUE real,
    capturado y mostrado de forma amigable).
  - El agente dueno de la propiedad confirma la cita; un agente
    DISTINTO que intenta rechazar esa misma cita no logra cambiarla
    (verificado consultando la base de datos despues del intento).
  - El cliente puede cancelar su propia cita solo mientras esta
    PENDIENTE; una vez CONFIRMADA ya no puede cancelarla el mismo.
- Solicitudes (`solicitudes/radicar.jsp`, `guardarSolicitud.jsp`,
  `subirDocumento.jsp`, `listar.jsp`, `cambiarEstado.jsp`) probadas:
  radicacion, carga de un documento, aislamiento entre clientes
  (otro cliente no puede ver ni subir documentos a una solicitud que no
  es suya) y aprobacion por parte del agente dueno de la propiedad.
- Reportes (`reportes/reportes.jsp`): 7 consultas SQL documentadas y
  ejecutandose en vivo (2 INNER JOIN de 3+ tablas, 1 resolviendo la
  N:M de roles, 1 LEFT JOIN, 3 de agregacion con GROUP BY/HAVING).
- Administracion: asignacion de multiples roles a un mismo usuario
  (demostrado con un usuario de prueba), activacion/inactivacion de
  cuentas (una cuenta inactivada no puede iniciar sesion), gestion de
  catalogos (se agrego la ciudad "Lebrija" en vivo) y consulta de
  auditoria con mas de 15 eventos reales generados por las pruebas.
- Barrido final: las ~40 paginas JSP del proyecto fueron solicitadas
  por HTTP como administrador sin producir ninguna excepcion ni error
  500.

## Historias completadas
HU-04, HU-09, HU-10, HU-11, HU-12, HU-13, HU-15. Todas las comprometidas
se cerraron.

## Metricas
- 27/27 puntos de historia comprometidos, completados: 27 (100%).
- Total del proyecto (3 sprints): 63/63 puntos comprometidos completados.
