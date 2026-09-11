# Sprint 1 - Review

**Fecha de la demo:** 2026-09-10

> Nota de transparencia: por restricciones de tiempo del equipo, el
> desarrollo de los tres sprints se ejecuto en sesiones de trabajo
> concentradas en vez de repartirse en el calendario original de 21
> dias. El **alcance funcional** de cada sprint (lo que se planeo vs.
> lo que se entrego) si se respeto tal como se planifico aqui. Las
> tres Reviews se presentan en la misma fecha de sustentacion.

## Incremento demostrado
- Landing page (`index.jsp`) responsiva, con buscador rapido por
  ciudad/tipo/operacion y propiedades destacadas.
- Catalogo publico (`catalogo.jsp`) con filtros por ciudad, tipo,
  operacion, rango de precio y palabra clave.
- Registro de clientes (`registro.jsp` + `procesarRegistro.jsp`):
  probado con correo duplicado -> mensaje "el correo ya se encuentra
  registrado" (no excepcion de Java).
- Login (`login.jsp` + `procesarLogin.jsp`): clave verificada con
  SHA-256+salt; 5 intentos fallidos bloquean la cuenta 15 minutos;
  redireccion automatica a `panelAdmin`/`panelInmobiliaria`/`panelCliente`
  segun el rol.
- `AccesoFilter` (servlet Filter en Java, compilado y registrado en
  `web.xml`) verificado con pruebas HTTP reales:
  - Visitante sin sesion que pide `/admin/usuarios.jsp` -> redirigido a
    `login.jsp`.
  - Cliente autenticado que pide `/admin/usuarios.jsp` -> redirigido a
    `accesoDenegado.jsp`.
  - Administrador autenticado -> accede sin problema.
- Modelo de datos completo (16 tablas) cargado en MySQL/MariaDB con
  datos de prueba: 11 usuarios, 4 inmobiliarias, 14 propiedades, etc.

## Historias completadas
HU-01, HU-02, HU-03, HU-07, HU-14, HU-16 + modelo de datos + filtro.
Todas las comprometidas en el planning se cerraron.

## Metricas
- 14/14 puntos de historia comprometidos, completados: 14 (100%).
