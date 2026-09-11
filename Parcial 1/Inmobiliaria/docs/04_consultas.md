# Consultas obligatorias - TerraNova Bienes Raices

Las 7 consultas de abajo estan implementadas y se ejecutan en vivo en
`reportes/reportes.jsp` (rol Administrador o Inmobiliaria). Se documentan
aqui tambien en texto plano para la sustentacion.

## 1. INNER JOIN entre 3+ tablas - Propiedades con ciudad, tipo e inmobiliaria
```sql
SELECT p.titulo, c.nombre AS ciudad, t.nombre AS tipo, i.nombre AS inmobiliaria,
       p.precio, p.estado
FROM propiedad p
JOIN ciudad c ON c.id_ciudad = p.id_ciudad
JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo
JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria
ORDER BY p.fecha_publicacion DESC;
```
Sirve para el catalogo y para el listado administrativo de propiedades.

## 2. INNER JOIN entre 3+ tablas - Citas con propiedad, cliente e inmobiliaria
```sql
SELECT c.fecha_hora, c.estado, p.titulo, pf.nombres, pf.apellidos, i.nombre AS inmobiliaria
FROM cita c
JOIN propiedad p ON p.id_propiedad = c.id_propiedad
JOIN usuario u ON u.id_usuario = c.id_cliente
JOIN perfil pf ON pf.id_usuario = u.id_usuario
JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria
ORDER BY c.fecha_hora DESC;
```
Permite a la inmobiliaria ver rapidamente quien agendo que visita y donde.

## 3. Resuelve la relacion N:M - Roles asignados por usuario
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

## 4. LEFT JOIN - Propiedades sin citas agendadas
```sql
SELECT p.titulo, p.direccion, p.estado
FROM propiedad p
LEFT JOIN cita c ON c.id_propiedad = p.id_propiedad
WHERE c.id_cita IS NULL
ORDER BY p.titulo;
```
El `LEFT JOIN` conserva las propiedades aunque no tengan ninguna fila
coincidente en `cita`; el filtro `WHERE c.id_cita IS NULL` es lo que aisla
las que nunca han tenido una cita.

## 5. Agregacion con GROUP BY + HAVING - Propiedades disponibles por ciudad
```sql
SELECT c.nombre AS ciudad, COUNT(*) AS total_disponibles
FROM propiedad p
JOIN ciudad c ON c.id_ciudad = p.id_ciudad
WHERE p.estado = 'DISPONIBLE'
GROUP BY c.nombre
HAVING COUNT(*) >= 1
ORDER BY total_disponibles DESC;
```
Alimenta el reporte "propiedades disponibles por ciudad" pedido en el
enunciado.

## 6. Agregacion adicional - Solicitudes por inmobiliaria
```sql
SELECT i.nombre AS inmobiliaria, COUNT(*) AS total_solicitudes
FROM solicitud s
JOIN propiedad p ON p.id_propiedad = s.id_propiedad
JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria
GROUP BY i.nombre
HAVING COUNT(*) >= 1
ORDER BY total_solicitudes DESC;
```

## 7. Agregacion adicional - Citas por estado
```sql
SELECT estado, COUNT(*) AS total FROM cita GROUP BY estado ORDER BY total DESC;
```

Las consultas 6 y 7 son adicionales a las 5 minimas exigidas, incluidas
porque el enunciado tambien pide explicitamente los reportes "citas por
estado" y "solicitudes por inmobiliaria" en la seccion de Reportes.
