# Sprint 2 - Planning

**Fechas:** 2026-09-02 a 2026-09-08 (7 dias)
**Sprint Goal:** Nucleo del negocio: CRUD completo de propiedades con
imagenes (1:N) y caracteristicas (N:M), perfil de usuario (1:1) editable,
favoritos (N:M) y paneles diferenciados por rol con metricas basicas.

## Historias comprometidas
| Historia | Estimacion (horas) |
|---|---|
| HU-06 CRUD de propiedades (crear/editar/baja logica) | 6h |
| HU-06 Galeria de imagenes por propiedad | 3h |
| HU-06 Asignacion de caracteristicas (N:M) | 3h |
| HU-05 Perfil de usuario editable + cambio de clave | 3h |
| HU-08 Favoritos (marcar/desmarcar, listado) | 3h |
| Paneles diferenciados (admin/inmobiliaria/cliente) con metricas | 4h |
| **Total** | **22h** |

## Decisiones de diseno tomadas en este sprint
- "Sus propiedades" (HU-06) se interpreto como las propiedades donde
  `id_agente = usuario en sesion`, no todas las de su inmobiliaria; el
  administrador si ve el listado completo. Esto se probo explicitamente
  con dos agentes distintos de la misma inmobiliaria para confirmar que
  no se ven las propiedades del otro.
- La galeria de imagenes no implementa carga binaria de archivos (para
  no ampliar demasiado el alcance): se guarda una URL/referencia. Mismo
  criterio se aplicara en Sprint 3 para los documentos de solicitud.
