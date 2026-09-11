# Sprint 3 - Planning

**Fechas:** 2026-09-09 a 2026-09-15 (7 dias)
**Sprint Goal:** Operacion y cierre: citas, solicitudes con documentos,
reportes con consultas de agregacion, panel de administracion (usuarios,
roles, catalogos, auditoria), pruebas de extremo a extremo de los tres
roles y documentacion final del proyecto.

## Historias comprometidas
| Historia | Estimacion (horas) |
|---|---|
| HU-09 Agendar citas sin cruce de horario | 4h |
| HU-10 Radicar solicitud + documentos | 4h |
| HU-11 Aprobar/rechazar solicitudes | 2h |
| HU-04 Asignar/revocar roles (admin) | 3h |
| HU-12 Reportes con GROUP BY/HAVING | 4h |
| HU-13 Auditoria de accesos y cambios | 2h |
| HU-15 Gestion de catalogos (ciudades/tipos/caracteristicas) | 2h |
| Pruebas end-to-end de los 3 roles + documentacion (MER, diccionario,
  consultas, README) | 6h |
| **Total** | **27h** |

## Riesgos identificados al planear
- Las citas y solicitudes necesitan la MISMA logica de "solo el dueno
  (agente) o el administrador pueden cambiar el estado" que ya se probo
  en Sprint 2 para propiedades; se reutiliza el patron, no se reinventa.
- El endpoint de cambiar estado de una cita lo usan DOS roles distintos
  con permisos distintos (agente confirma/rechaza, cliente cancela la
  suya): se resuelve validando el rol y la propiedad del recurso DENTRO
  de la pagina, no solo con el filtro de rutas.
