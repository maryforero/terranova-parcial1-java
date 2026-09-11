# Product Backlog - TerraNova Bienes Raices

Product Owner: Docente Julian Barney Jaimes Rincon (segun el enunciado).
Scrum Master / Development Team: estudiante(s) del proyecto.
Tablero de seguimiento: Trello (columnas Backlog / En progreso / En revision / Hecho).

Historias entregadas por el Product Owner en el enunciado, mas las
agregadas por el equipo, priorizadas y con su Definicion de Terminado (DoD).

| # | Historia | Prioridad | Sprint | DoD (Definition of Done) |
|---|----------|-----------|--------|---------------------------|
| HU-01 | Como visitante, quiero una landing page atractiva para conocer la inmobiliaria y buscar propiedades rapidamente. | Alta | 1 | Landing responsiva con buscador rapido (ciudad/tipo/operacion) y propiedades destacadas visibles sin sesion. |
| HU-02 | Como usuario, quiero registrarme con un correo unico y validado para crear mi cuenta sin duplicados. | Alta | 1 | Registro valida campos obligatorios, hashea la clave con salt, y muestra mensaje amigable si el correo ya existe. |
| HU-03 | Como usuario registrado, quiero iniciar y cerrar sesion de forma segura para que el sistema me lleve al panel de mi rol. | Alta | 1 | Login valida contra hash+salt, bloquea tras 5 intentos fallidos, y redirige segun el rol (admin/agente/cliente). |
| HU-04 | Como administrador, quiero asignar y revocar roles a los usuarios para controlar los permisos de la aplicacion. | Alta | 3 | Pantalla admin/usuarios.jsp permite marcar/desmarcar roles con checkboxes y persiste en `usuario_rol`. |
| HU-05 | Como cliente, quiero completar mi perfil con documento, telefono y direccion para agilizar mis tramites. | Media | 2 | perfil/verPerfil.jsp permite editar los datos de `perfil` y cambiar la clave. |
| HU-06 | Como agente, quiero registrar y editar propiedades con fotos, caracteristicas y precio para mantener el catalogo actualizado. | Alta | 2 | CRUD completo de `propiedad`, galeria (`imagen_propiedad`) y caracteristicas (`propiedad_caracteristica`) funcionando y con control de dueno. |
| HU-07 | Como cliente, quiero buscar y filtrar propiedades por ciudad, tipo, precio y caracteristicas. | Alta | 1 | catalogo.jsp filtra por ciudad, tipo, operacion y rango de precio. |
| HU-08 | Como cliente, quiero marcar propiedades como favoritas para consultarlas despues. | Media | 2 | favoritos/alternar.jsp y listar.jsp funcionando (N:M `favorito`). |
| HU-09 | Como cliente, quiero solicitar una cita en un horario disponible sin que se crucen las agendas. | Media | 2 | citas/agendar.jsp respeta UNIQUE(id_propiedad,fecha_hora) con mensaje amigable si esta ocupado. |
| HU-10 | Como cliente, quiero radicar documentos de compra/arriendo y consultar el estado de mi solicitud. | Media | 3 | solicitudes/radicar.jsp + subirDocumento.jsp + listar.jsp con estado visible. |
| HU-11 | Como agente, quiero aprobar o rechazar solicitudes y sus documentos. | Media | 3 | solicitudes/cambiarEstado.jsp restringido a agente/admin, con control de dueno. |
| HU-12 | Como administrador, quiero un reporte de propiedades por ciudad y estado con consultas de agregacion. | Media | 3 | reportes/reportes.jsp con GROUP BY + HAVING. |
| HU-13 | Como administrador, quiero consultar la auditoria de accesos y cambios. | Baja | 3 | admin/auditoria.jsp lista eventos de `auditoria` (login, cambios de estado, roles, etc.). |
| HU-14 | (Agregada por el equipo) Como administrador, quiero bloquear temporalmente una cuenta tras varios intentos fallidos de login. | Baja (valor agregado) | 1 | `usuario.intentos_fallidos`/`bloqueado_hasta` + logica en `procesarLogin.jsp`. |
| HU-15 | (Agregada por el equipo) Como administrador, quiero gestionar catalogos (ciudades, tipos, caracteristicas) sin tocar la base de datos directamente. | Baja | 3 | admin/catalogos.jsp permite agregar valores nuevos a los tres catalogos. |
| HU-16 | (Agregada por el equipo) Como visitante, no quiero ver los datos de contacto completos del agente sin iniciar sesion. | Alta (seguridad) | 1 | detallePropiedad.jsp oculta telefono del agente si no hay sesion. |

## Notas de priorizacion
- Las historias de **autenticacion y control de acceso** (HU-02, HU-03,
  HU-16) se priorizaron primero porque todo el resto del sistema depende
  de saber quien es el usuario y que rol tiene.
- El **CRUD de propiedades** (HU-06) es la segunda prioridad porque sin
  inventario no hay nada que buscar, agendar ni solicitar.
- **Citas, solicitudes y reportes** se dejaron para el cierre porque
  dependen de que ya existan propiedades y usuarios con roles.
