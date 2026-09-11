# TerraNova Bienes Raices - Parcial Practico Programacion Java (UTS)

Aplicacion web JSP + JDBC + MySQL para la administracion de una
inmobiliaria ficticia (marketplace multi-agencia), desarrollada para el
Parcial Practico de Programacion Java segun
`Parcial 1/PARCIAL_JAVA_1_CORTE_PRACTICO_V2.pdf`.

> Nota sobre este repositorio: el proyecto corre dentro de un contexto
> de Tomcat (`/JAVA`) compartido con otros ejercicios del curso que no
> forman parte de este parcial. Este repositorio Git se inicializo en
> la raiz de ese contexto pero un `.gitignore` de **lista blanca**
> asegura que solo se versiona lo que pertenece a este proyecto (ver
> seccion "Por que el repo se ve asi" abajo).

## Estructura del proyecto

```
Parcial 1/
  PARCIAL_JAVA_1_CORTE_PRACTICO_V2.pdf   (enunciado original)
  Inmobiliaria/                          <- codigo de la aplicacion
    index.jsp, catalogo.jsp, detallePropiedad.jsp, login/registro...
    panel/            paneles por rol (admin, inmobiliaria, cliente)
    propiedades/      CRUD, galeria de imagenes, caracteristicas (N:M)
    citas/            agendamiento y gestion de visitas
    solicitudes/      radicacion de compra/arriendo + documentos
    favoritos/        favoritos del cliente (N:M)
    reportes/         7 consultas SQL documentadas (JOIN/LEFT JOIN/GROUP BY)
    admin/            usuarios y roles, catalogos, auditoria
    perfil/           datos personales + cambio de clave
    sql/              01_ddl / 02_dml (script generado, ver mas abajo)
    docs/             MER, modelo relacional, diccionario de datos,
                      consultas documentadas y las 3 carpetas de Scrum
                      (planning / review / retrospective por sprint)
WEB-INF/
  web.xml             contexto compartido: aqui se registra el filtro
                      AccesoFilter y el jsp-property-group de UTF-8
  jspf/               fragmentos compartidos SOLO de este proyecto:
                      conexionInmobiliaria.jspf, cabeceraInmobiliaria.jspf,
                      pieInmobiliaria.jspf, utilidadesInmobiliaria.jspf
  classes/com/terranova/
    filter/AccesoFilter.java   control de acceso por rol (servlet Filter)
    util/PasswordUtil.java     SHA-256 + salt para las contraseñas
```

## Como correrlo localmente

1. **Base de datos** (MySQL/MariaDB, probado con XAMPP/MariaDB 10.4):
   ```
   mysql.exe --default-character-set=utf8mb4 -u root < "Parcial 1/Inmobiliaria/sql/01_ddl_inmobiliaria.sql"
   mysql.exe --default-character-set=utf8mb4 -u root < "Parcial 1/Inmobiliaria/sql/02_dml_inmobiliaria.sql"
   ```
   Credenciales por defecto en `WEB-INF/jspf/conexionInmobiliaria.jspf`:
   usuario `root`, clave vacia, base `inmobiliaria_terranova`. Cambialas
   ahi si tu MySQL tiene otra configuracion (es el UNICO lugar donde se
   configura la conexion, no se repite en cada pagina).

2. **Compilar el filtro y el helper de contraseñas** (requiere el
   `servlet-api.jar` de tu instalacion de Tomcat):
   ```
   cd WEB-INF/classes
   javac -encoding UTF-8 -cp "<ruta-a-tomcat>/lib/servlet-api.jar" -d . \
       com/terranova/util/PasswordUtil.java \
       com/terranova/filter/AccesoFilter.java
   ```

3. **Copiar** la carpeta `Parcial 1/` y la carpeta `WEB-INF/` dentro del
   webapp de Tomcat que uses como contexto (o desplegar todo el
   contexto `/JAVA` tal cual, si vas a reusar el mismo layout).

4. Abrir `http://localhost:8080/<contexto>/Parcial%201/Inmobiliaria/index.jsp`

### Usuarios de prueba (clave `1234` para todos)
| Correo | Rol(es) |
|---|---|
| admin@terranova.com | ADMINISTRADOR |
| director@terranova.com | ADMINISTRADOR + INMOBILIARIA (demuestra la N:M usuario-rol) |
| agente.garcia@terranova.com | INMOBILIARIA (TerraNova) |
| agente.rios@terranova.com | INMOBILIARIA (TerraNova) |
| agente.pena@habitatreal.com | INMOBILIARIA (Habitat Real) |
| cliente.torres@gmail.com | CLIENTE |

## Decisiones tecnicas relevantes

- **Contraseñas**: SHA-256 con salto aleatorio por usuario (`usuario.password_salt`,
  16 bytes en hex) calculado en `com.terranova.util.PasswordUtil`. Nunca
  se guarda texto plano.
- **Control de acceso**: `com.terranova.filter.AccesoFilter` (servlet
  `Filter` real, no solo ocultar botones en la vista) protege las rutas
  por rol; se registra en `WEB-INF/web.xml` con
  `url-pattern = /Parcial 1/Inmobiliaria/*`.
- **Espacio en "Parcial 1"**: el contexto usa `ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria"`
  (con `%20`) para todo enlace/redirect que pasa por el navegador; los
  `<%@ include %>` del lado del servidor usan la ruta con espacio
  literal, que es como Tomcat resuelve el archivo en disco.
- **Bug de entorno documentado**: este Tomcat 8.5.96 sobre JDK 17 no
  compila ninguna referencia a `java.lang.System` dentro de un JSP
  (confirmado con una prueba minima); el proyecto usa `java.util.Date`
  en su lugar donde se necesita la fecha/hora actual.
- **Documentos y galeria de imagenes**: por alcance, se guarda una
  URL/referencia en vez de subir el archivo binario al servidor
  (`imagen_propiedad.url_imagen`, `documento_solicitud.url_archivo`).
- **"Sus propiedades"**: se interpreto como las propiedades donde
  `id_agente` = el usuario en sesion (no todas las de su inmobiliaria).
  El administrador si ve el listado completo.

## Documentacion (`Parcial 1/Inmobiliaria/docs/`)
- `01_MER.md` - Diagrama entidad-relacion (Mermaid, se renderiza solo en GitHub).
- `02_modelo_relacional.md` - Esquema relacional, justificacion de 3FN y de cada `ON DELETE`.
- `03_diccionario_datos.md` - Diccionario de datos completo de las 16 tablas.
- `04_consultas.md` - Las 7 consultas SQL documentadas (INNER JOIN x2, N:M, LEFT JOIN, GROUP BY+HAVING x3).
- `scrum/00_product_backlog.md` - Historias priorizadas con DoD.
- `scrum/sprintN_planning.md` / `_review.md` / `_retrospective.md` - las tres ceremonias por cada uno de los 3 sprints.

## Por que el repo se ve asi
Este contexto de Tomcat (`/JAVA`) tambien contiene ejercicios de clase
no relacionados con este parcial, y un par de ellos tienen cadenas de
conexion con credenciales de bases de datos en linea (Clever Cloud,
Neon) hardcodeadas en el codigo de esos ejercicios. El `.gitignore` usa
una lista blanca (ignora todo por defecto, habilita solo `Parcial 1/`,
este `README.md` y las piezas de `WEB-INF/` que pertenecen a este
proyecto) para que el repositorio publico de este parcial nunca incluya
esas credenciales ni el resto de tareas del curso.
