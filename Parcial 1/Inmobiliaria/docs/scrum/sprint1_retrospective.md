# Sprint 1 - Retrospective

**Fecha:** 2026-09-10

## Que funciono bien
- Generar el DML de datos de prueba con un script Python (en vez de
  escribirlo a mano) elimino de raiz el riesgo de transcribir mal un
  hash SHA-256, que fue justamente el bug que se sufrio en el proyecto
  anterior (Simulacro RestauranteWeb).
- Probar el `AccesoFilter` con peticiones HTTP reales (no solo lectura
  de codigo) permitio confirmar que el control de acceso realmente
  bloquea en el servidor, no solo en la vista.

## Que no funciono / dificultades
- Se encontro un bug del **entorno** (no del codigo): Tomcat 8.5.96
  corriendo sobre JDK 17 falla al compilar cualquier JSP que referencie
  la clase `System` (`System cannot be resolved`), incluso completamente
  calificada como `java.lang.System`. Se aislo con una prueba minima
  (`<%= System.currentTimeMillis() %>` fallaba solo; `Math`, `Thread` y
  `Runtime` sí compilaban).
- Los espacios en el nombre de carpeta `Parcial 1` obligan a mantener
  dos formas de la misma ruta: la version con `%20` para enlaces/redirects
  que pasan por el navegador, y la version con espacio literal para
  archivos e `include`s del lado del servidor.

## Acciones para el siguiente sprint
- Evitar `System.*` en todo el proyecto; usar `java.util.Date` para
  obtener la fecha/hora actual.
- Mantener la convencion `ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria"`
  en **todas** las paginas nuevas para no reintroducir el problema del
  espacio en la ruta.
