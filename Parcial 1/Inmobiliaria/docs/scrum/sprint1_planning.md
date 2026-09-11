# Sprint 1 - Planning

**Fechas:** 2026-08-26 a 2026-09-01 (7 dias)
**Sprint Goal:** Tener el modelo de datos completo, la conexion JDBC
centralizada, la landing page publica y el modulo de autenticacion con
control de acceso por rol funcionando de extremo a extremo.

## Historias comprometidas
| Historia | Estimacion (horas) |
|---|---|
| HU-01 Landing page con buscador rapido | 4h |
| HU-02 Registro con correo unico | 4h |
| HU-03 Login + sesion + redireccion por rol | 6h |
| HU-07 Catalogo publico con filtros | 4h |
| HU-14 Bloqueo temporal tras intentos fallidos | 2h |
| HU-16 Ocultar contacto a visitantes | 1h |
| Modelo de datos (MER + DDL + DML) | 8h |
| Filtro de servlet (AccesoFilter) | 4h |
| **Total** | **33h** |

## Tareas tecnicas de soporte (no son historias de usuario, pero son
Sprint 1 por definicion):
- Disenar las 16 entidades y las relaciones 1:1/1:N/N:M exigidas.
- Escribir `01_ddl_inmobiliaria.sql` y `02_dml_inmobiliaria.sql` (datos
  de prueba, generados con un script Python para evitar errores de
  transcripcion en los hashes de clave).
- Escribir y compilar `AccesoFilter.java` (control de acceso real en el
  servidor) y `PasswordUtil.java` (SHA-256 + salt).
- Registrar el filtro y el `jsp-property-group` de UTF-8 en el
  `web.xml` compartido del contexto `/JAVA`.

## Fuera de alcance de este sprint (se deja para Sprint 2/3)
CRUD de propiedades, galeria de imagenes, caracteristicas, citas,
solicitudes, favoritos, reportes, panel de administracion de usuarios.
