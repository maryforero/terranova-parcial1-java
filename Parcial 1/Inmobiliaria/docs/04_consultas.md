# Consultas obligatorias - TerraNova Bienes Raíces

Las 7 consultas de abajo estan implementadas y se ejecutan en vivo en
`reportes/reportes.jsp` (rol Administrador o Inmobiliaria), agrupadas en
dos secciones: primero las de agregacion (mostradas como graficas de
barras, con una frase de "insight" automatica) y luego los cruces JOIN
(mostrados como tablas). Se documentan aqui tambien en texto plano para
la sustentacion.

## Seccion 1: Agregacion con GROUP BY + HAVING

### 1. Propiedades disponibles por ciudad
```sql
SELECT c.nombre, COUNT(*)
FROM propiedad p JOIN ciudad c ON c.id_ciudad = p.id_ciudad
WHERE p.estado = 'DISPONIBLE'
GROUP BY c.nombre
HAVING COUNT(*) >= 1
ORDER BY 2 DESC;
```
Responde: ¿en que ciudades hay mas inventario disponible ahora mismo?
Alimenta el reporte "propiedades disponibles por ciudad" del enunciado.

### 2. Solicitudes por inmobiliaria
```sql
SELECT i.nombre, COUNT(*)
FROM solicitud s
JOIN propiedad p ON p.id_propiedad = s.id_propiedad
JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria
GROUP BY i.nombre
HAVING COUNT(*) >= 1
ORDER BY 2 DESC;
```
Responde: ¿que agencia aliada esta generando mas tramites de compra/arriendo?

### 3. Citas por estado
```sql
SELECT estado, COUNT(*)
FROM cita
GROUP BY estado
ORDER BY 2 DESC;
```
Responde: ¿que tan efectivo es el proceso de agendamiento (cuantas citas
terminan confirmadas vs. rechazadas vs. canceladas)?

## Seccion 2: Cruces entre tablas (JOIN)

### 4. INNER JOIN entre 4 tablas - Propiedades con ciudad, tipo e inmobiliaria
```sql
SELECT p.titulo, c.nombre AS ciudad, t.nombre AS tipo, i.nombre AS inmobiliaria,
       p.precio, p.estado
FROM propiedad p
JOIN ciudad c ON c.id_ciudad = p.id_ciudad
JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo
JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria
ORDER BY p.fecha_publicacion DESC;
```
Es la vista base del catalogo administrativo de propiedades.

### 5. INNER JOIN entre 5 tablas - Citas con propiedad, cliente e inmobiliaria
```sql
SELECT c.fecha_hora, c.estado, p.titulo, pf.nombres, i.nombre AS inmobiliaria
FROM cita c
JOIN propiedad p ON p.id_propiedad = c.id_propiedad
JOIN usuario u ON u.id_usuario = c.id_cliente
JOIN perfil pf ON pf.id_usuario = u.id_usuario
JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria
ORDER BY c.fecha_hora DESC;
```
Permite a la inmobiliaria ver rapidamente quien agendo que visita y donde.

### 6. Resuelve la relacion N:M - Roles asignados por usuario
```sql
SELECT pf.nombres, pf.apellidos, u.correo, r.nombre AS rol
FROM usuario_rol ur
JOIN usuario u ON u.id_usuario = ur.id_usuario
JOIN perfil pf ON pf.id_usuario = u.id_usuario
JOIN rol r ON r.id_rol = ur.id_rol
ORDER BY pf.nombres;
```
Expande la tabla intermedia `usuario_rol`; el usuario `director@terranova.com`
aparece dos veces (ADMINISTRADOR e INMOBILIARIA), demostrando la N:M real.

### 7. LEFT JOIN - Propiedades sin citas agendadas
```sql
SELECT p.titulo, p.direccion, p.estado
FROM propiedad p
LEFT JOIN cita c ON c.id_propiedad = p.id_propiedad
WHERE c.id_cita IS NULL
ORDER BY p.titulo;
```
El `LEFT JOIN` conserva las propiedades aunque no tengan ninguna fila
coincidente en `cita`; el filtro `WHERE c.id_cita IS NULL` es lo que aisla
las que nunca han tenido una cita agendada.
