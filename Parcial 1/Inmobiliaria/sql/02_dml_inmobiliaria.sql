-- =====================================================================
-- TerraNova Bienes Raices - Script DML (datos de prueba)
-- Generado automaticamente por scripts/gen_dml.py
-- Las claves y salts de usuario se calculan con hashlib (SHA-256),
-- NUNCA transcritas a mano, para evitar truncamientos accidentales.
-- Clave en texto plano para TODOS los usuarios de prueba: 1234
-- =====================================================================
SET NAMES utf8mb4;
USE inmobiliaria_terranova;

-- ---------------------------------------------------------------------
-- ROLES
-- ---------------------------------------------------------------------
INSERT INTO rol (nombre) VALUES
    ('ADMINISTRADOR'),
    ('INMOBILIARIA'),
    ('CLIENTE');

-- ---------------------------------------------------------------------
-- CIUDADES (area metropolitana de Bucaramanga + algunas de referencia)
-- ---------------------------------------------------------------------
INSERT INTO ciudad (nombre, departamento) VALUES
    ('Bucaramanga', 'Santander'),
    ('Floridablanca', 'Santander'),
    ('Giron', 'Santander'),
    ('Piedecuesta', 'Santander'),
    ('San Gil', 'Santander'),
    ('Barrancabermeja', 'Santander'),
    ('Socorro', 'Santander'),
    ('Malaga', 'Santander'),
    ('Bogota', 'Cundinamarca'),
    ('Medellin', 'Antioquia');

-- ---------------------------------------------------------------------
-- TIPOS DE PROPIEDAD
-- ---------------------------------------------------------------------
INSERT INTO tipo_propiedad (nombre) VALUES
    ('Casa'),
    ('Apartamento'),
    ('Apartaestudio'),
    ('Local Comercial'),
    ('Oficina'),
    ('Lote o Terreno'),
    ('Finca'),
    ('Bodega');

-- ---------------------------------------------------------------------
-- CARACTERISTICAS
-- ---------------------------------------------------------------------
INSERT INTO caracteristica (nombre) VALUES
    ('Piscina'),
    ('Parqueadero'),
    ('Ascensor'),
    ('Gimnasio'),
    ('Balcon'),
    ('Zona BBQ'),
    ('Vigilancia 24 horas'),
    ('Amoblado'),
    ('Aire acondicionado'),
    ('Terraza'),
    ('Deposito'),
    ('Jardin');

-- ---------------------------------------------------------------------
-- INMOBILIARIAS (agencias que publican en el marketplace)
-- id_ciudad: 1=Bucaramanga, 2=Floridablanca, 3=Giron, 4=Piedecuesta
-- ---------------------------------------------------------------------
INSERT INTO inmobiliaria (nombre, nit, telefono, direccion, id_ciudad) VALUES
    ('TerraNova Bienes Raices',        '900123456-1', '6076441000', 'Cra 27 #45-10, Bucaramanga',  1),
    ('Habitat Real',                   '900123457-2', '6076442000', 'Cra 15 #8-40, Floridablanca', 2),
    ('Vivienda Total',                 '900123458-3', '6076443000', 'Cll 12 #6-25, Giron',         3),
    ('Bienes y Raices del Oriente',    '900123459-4', '6076444000', 'Cra 4 #10-12, Piedecuesta',   4);

-- ---------------------------------------------------------------------
-- USUARIOS + PERFIL (1:1) + ROLES (N:M)
-- Clave para TODOS: 1234
-- ---------------------------------------------------------------------
-- Usuario 1: admin@terranova.com (clave: 1234)
INSERT INTO usuario (correo, password_hash, password_salt, id_inmobiliaria, estado) VALUES
    ('admin@terranova.com', 'e2c24d8fcd15d460d8caa1b6b4dee3aa59643a3a963a71779a5fd60ad32fe626', 'a1b2c3d4e5f60708a1b2c3d4e5f60701', NULL, 'ACTIVO');
SET @uid := LAST_INSERT_ID();
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
    (@uid, 'Camila', 'Rueda Ortiz', '1091234501', '3001234501', 'Cra 27 #45-10, Bucaramanga');
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
    (@uid, 1);

-- Usuario 2: director@terranova.com (clave: 1234)
INSERT INTO usuario (correo, password_hash, password_salt, id_inmobiliaria, estado) VALUES
    ('director@terranova.com', 'b9d16c60238bc7f1a4a1d900ea258b995bde570bfc4894057fcdb8b1fe7aeb09', 'a1b2c3d4e5f60708a1b2c3d4e5f60702', 1, 'ACTIVO');
SET @uid := LAST_INSERT_ID();
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
    (@uid, 'Andres', 'Villamizar Cote', '1091234502', '3001234502', 'Cll 36 #22-18, Bucaramanga');
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
    (@uid, 1),
    (@uid, 2);

-- Usuario 3: agente.garcia@terranova.com (clave: 1234)
INSERT INTO usuario (correo, password_hash, password_salt, id_inmobiliaria, estado) VALUES
    ('agente.garcia@terranova.com', 'dc6224e607a38354c610ca321781bf0830909b93b918e5dc15703dbca856f852', 'a1b2c3d4e5f60708a1b2c3d4e5f60703', 1, 'ACTIVO');
SET @uid := LAST_INSERT_ID();
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
    (@uid, 'Laura', 'Garcia Nino', '1091234503', '3001234503', 'Cra 33 #50-20, Bucaramanga');
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
    (@uid, 2);

-- Usuario 4: agente.rios@terranova.com (clave: 1234)
INSERT INTO usuario (correo, password_hash, password_salt, id_inmobiliaria, estado) VALUES
    ('agente.rios@terranova.com', '7908b94b9ac7fd5417f3f68134bc32f900e94fafa0155e2d5f238b71a3796525', 'a1b2c3d4e5f60708a1b2c3d4e5f60704', 1, 'ACTIVO');
SET @uid := LAST_INSERT_ID();
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
    (@uid, 'Felipe', 'Rios Camacho', '1091234504', '3001234504', 'Cll 45 #15-30, Bucaramanga');
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
    (@uid, 2);

-- Usuario 5: agente.pena@habitatreal.com (clave: 1234)
INSERT INTO usuario (correo, password_hash, password_salt, id_inmobiliaria, estado) VALUES
    ('agente.pena@habitatreal.com', 'cc52208e96c6bbf822e694bf528a9c44fbe15c126fb2877ae61435f4f3972ad6', 'a1b2c3d4e5f60708a1b2c3d4e5f60705', 2, 'ACTIVO');
SET @uid := LAST_INSERT_ID();
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
    (@uid, 'Diana', 'Pena Delgado', '1091234505', '3101234505', 'Cra 15 #8-40, Floridablanca');
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
    (@uid, 2);

-- Usuario 6: agente.suarez@viviendatotal.com (clave: 1234)
INSERT INTO usuario (correo, password_hash, password_salt, id_inmobiliaria, estado) VALUES
    ('agente.suarez@viviendatotal.com', '7e855ac2ef76bfd4b44ccc0a1abd099a33fee9ad60b75ef90f583c276fe3b90b', 'a1b2c3d4e5f60708a1b2c3d4e5f60706', 3, 'ACTIVO');
SET @uid := LAST_INSERT_ID();
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
    (@uid, 'Julian', 'Suarez Prada', '1091234506', '3101234506', 'Cll 12 #6-25, Giron');
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
    (@uid, 2);

-- Usuario 7: agente.moreno@bienesoriente.com (clave: 1234)
INSERT INTO usuario (correo, password_hash, password_salt, id_inmobiliaria, estado) VALUES
    ('agente.moreno@bienesoriente.com', 'b4fa2b28d1b1740b5f5e783323cd813543958788e688dd7740d967771feb4ff6', 'a1b2c3d4e5f60708a1b2c3d4e5f60707', 4, 'ACTIVO');
SET @uid := LAST_INSERT_ID();
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
    (@uid, 'Paola', 'Moreno Rangel', '1091234507', '3101234507', 'Cra 4 #10-12, Piedecuesta');
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
    (@uid, 2);

-- Usuario 8: cliente.torres@gmail.com (clave: 1234)
INSERT INTO usuario (correo, password_hash, password_salt, id_inmobiliaria, estado) VALUES
    ('cliente.torres@gmail.com', '775a3c820f38c6ce54a4c246886fffad7ced311134c7de5603a0d6d13ad6a26d', 'a1b2c3d4e5f60708a1b2c3d4e5f60708', NULL, 'ACTIVO');
SET @uid := LAST_INSERT_ID();
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
    (@uid, 'Sergio', 'Torres Lopez', '1098765401', '3201234508', 'Cra 9 #20-14, Bucaramanga');
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
    (@uid, 3);

-- Usuario 9: cliente.gomez@gmail.com (clave: 1234)
INSERT INTO usuario (correo, password_hash, password_salt, id_inmobiliaria, estado) VALUES
    ('cliente.gomez@gmail.com', 'eeed31b49b3246a3fe3984790fdf7119f2c061715f0a4a7719245af18fd97b28', 'a1b2c3d4e5f60708a1b2c3d4e5f60709', NULL, 'ACTIVO');
SET @uid := LAST_INSERT_ID();
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
    (@uid, 'Valentina', 'Gomez Ardila', '1098765402', '3201234509', 'Cll 30 #14-08, Floridablanca');
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
    (@uid, 3);

-- Usuario 10: cliente.duran@gmail.com (clave: 1234)
INSERT INTO usuario (correo, password_hash, password_salt, id_inmobiliaria, estado) VALUES
    ('cliente.duran@gmail.com', '96539cbc77791be9d62767455d6172638580b36d04ee84b378ebb4ac5d14e352', 'a1b2c3d4e5f60708a1b2c3d4e5f6070a', NULL, 'ACTIVO');
SET @uid := LAST_INSERT_ID();
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
    (@uid, 'Miguel', 'Duran Silva', '1098765403', '3201234510', 'Cra 21 #33-45, Giron');
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
    (@uid, 3);

-- Usuario 11: cliente.rojas@gmail.com (clave: 1234)
INSERT INTO usuario (correo, password_hash, password_salt, id_inmobiliaria, estado) VALUES
    ('cliente.rojas@gmail.com', '51a9e6edffebf725ead358a353fc744c61b824915ad8d0b2acc2b06b74972d08', 'a1b2c3d4e5f60708a1b2c3d4e5f6070b', NULL, 'ACTIVO');
SET @uid := LAST_INSERT_ID();
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
    (@uid, 'Natalia', 'Rojas Mantilla', '1098765404', '3201234511', 'Cll 5 #18-60, Piedecuesta');
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
    (@uid, 3);

-- Referencia rapida de ids de usuario para el resto del script:
--  1 admin@terranova.com (ADMINISTRADOR)
--  2 director@terranova.com (ADMINISTRADOR + INMOBILIARIA, TerraNova)
--  3 agente.garcia@terranova.com (INMOBILIARIA, TerraNova)
--  4 agente.rios@terranova.com (INMOBILIARIA, TerraNova)
--  5 agente.pena@habitatreal.com (INMOBILIARIA, Habitat Real)
--  6 agente.suarez@viviendatotal.com (INMOBILIARIA, Vivienda Total)
--  7 agente.moreno@bienesoriente.com (INMOBILIARIA, Bienes y Raices del Oriente)
--  8 cliente.torres@gmail.com (CLIENTE)
--  9 cliente.gomez@gmail.com (CLIENTE)
-- 10 cliente.duran@gmail.com (CLIENTE)
-- 11 cliente.rojas@gmail.com (CLIENTE)

-- ---------------------------------------------------------------------
-- PROPIEDADES
-- id_tipo: 1 Casa 2 Apto 3 Apartaestudio 4 Local 5 Oficina 6 Lote 7 Finca 8 Bodega
-- id_ciudad: 1 Bucaramanga 2 Floridablanca 3 Giron 4 Piedecuesta 5 San Gil
-- ---------------------------------------------------------------------
INSERT INTO propiedad
    (matricula_inmobiliaria, titulo, id_tipo, id_ciudad, id_inmobiliaria, id_agente,
     direccion, precio, area_m2, habitaciones, banos, operacion, estado)
VALUES
    ('SAN-0001-BGA', 'Casa campestre con piscina en Cabecera', 1, 1, 1, 3, 'Cra 33 #50-20, Bucaramanga', 780000000, 320.0, 4, 3, 'VENTA', 'DISPONIBLE'),
    ('SAN-0002-BGA', 'Apartamento moderno en Cabecera del Llano', 2, 1, 1, 3, 'Cll 45 #15-30, Bucaramanga', 420000000, 95.0, 3, 2, 'VENTA', 'DISPONIBLE'),
    ('SAN-0003-BGA', 'Apartaestudio para estudiantes cerca a la UTS', 3, 1, 1, 4, 'Cra 27 #45-10, Bucaramanga', 1200000, 38.0, 1, 1, 'ARRIENDO', 'DISPONIBLE'),
    ('SAN-0004-BGA', 'Local comercial centro de Bucaramanga', 4, 1, 1, 4, 'Cll 35 #18-22, Bucaramanga', 3500000, 60.0, NULL, 1, 'ARRIENDO', 'DISPONIBLE'),
    ('SAN-0005-BGA', 'Oficina ejecutiva Torre Empresarial', 5, 1, 1, 2, 'Cra 33 #34-15, Bucaramanga', 2800000, 45.0, NULL, 1, 'ARRIENDO', 'RESERVADO'),
    ('SAN-0006-FLB', 'Apartamento con vista a las montanas', 2, 2, 2, 5, 'Cra 15 #8-40, Floridablanca', 380000000, 88.0, 3, 2, 'VENTA', 'DISPONIBLE'),
    ('SAN-0007-FLB', 'Casa familiar en conjunto cerrado', 1, 2, 2, 5, 'Cll 20 #9-30, Floridablanca', 520000000, 210.0, 4, 3, 'VENTA', 'VENDIDO'),
    ('SAN-0008-GIR', 'Local en zona comercial de Giron', 4, 3, 3, 6, 'Cll 12 #6-25, Giron', 2200000, 40.0, NULL, 1, 'ARRIENDO', 'DISPONIBLE'),
    ('SAN-0009-GIR', 'Casa colonial centro historico de Giron', 1, 3, 3, 6, 'Cra 28 #30-10, Giron', 650000000, 180.0, 3, 2, 'VENTA', 'DISPONIBLE'),
    ('SAN-0010-PIE', 'Finca de recreo con zona BBQ', 7, 4, 4, 7, 'Vereda Sevilla, Piedecuesta', 950000000, 5000.0, 5, 4, 'VENTA', 'DISPONIBLE'),
    ('SAN-0011-PIE', 'Apartamento arriendo cerca al parque principal', 2, 4, 4, 7, 'Cra 4 #10-12, Piedecuesta', 1100000, 60.0, 2, 1, 'ARRIENDO', 'ARRENDADO'),
    ('SAN-0012-BGA', 'Bodega industrial zona Chimita', 8, 1, 1, 2, 'Diagonal 15 #100-20, Bucaramanga', 6500000, 400.0, NULL, 1, 'ARRIENDO', 'DISPONIBLE'),
    ('SAN-0013-BGA', 'Lote urbanizable sector Lagos del Cacique', 6, 1, 1, 3, 'Cra 42 #60-10, Bucaramanga', 310000000, 500.0, NULL, NULL, 'VENTA', 'DISPONIBLE'),
    ('SAN-0014-BGA', 'Apartamento antiguo para remodelar', 2, 1, 1, 4, 'Cll 22 #14-30, Bucaramanga', 210000000, 70.0, 2, 1, 'VENTA', 'INACTIVO');

-- ---------------------------------------------------------------------
-- IMAGENES DE PROPIEDAD (2 a 3 por inmueble)
-- ---------------------------------------------------------------------
INSERT INTO imagen_propiedad (id_propiedad, url_imagen, es_principal, orden) VALUES
    (1, 'https://picsum.photos/seed/terranova1a/800/600', 1, 1),
    (1, 'https://picsum.photos/seed/terranova1b/800/600', 0, 2),
    (2, 'https://picsum.photos/seed/terranova2a/800/600', 1, 1),
    (2, 'https://picsum.photos/seed/terranova2b/800/600', 0, 2),
    (2, 'https://picsum.photos/seed/terranova2c/800/600', 0, 3),
    (3, 'https://picsum.photos/seed/terranova3a/800/600', 1, 1),
    (3, 'https://picsum.photos/seed/terranova3b/800/600', 0, 2),
    (4, 'https://picsum.photos/seed/terranova4a/800/600', 1, 1),
    (4, 'https://picsum.photos/seed/terranova4b/800/600', 0, 2),
    (4, 'https://picsum.photos/seed/terranova4c/800/600', 0, 3),
    (5, 'https://picsum.photos/seed/terranova5a/800/600', 1, 1),
    (5, 'https://picsum.photos/seed/terranova5b/800/600', 0, 2),
    (6, 'https://picsum.photos/seed/terranova6a/800/600', 1, 1),
    (6, 'https://picsum.photos/seed/terranova6b/800/600', 0, 2),
    (6, 'https://picsum.photos/seed/terranova6c/800/600', 0, 3),
    (7, 'https://picsum.photos/seed/terranova7a/800/600', 1, 1),
    (7, 'https://picsum.photos/seed/terranova7b/800/600', 0, 2),
    (8, 'https://picsum.photos/seed/terranova8a/800/600', 1, 1),
    (8, 'https://picsum.photos/seed/terranova8b/800/600', 0, 2),
    (8, 'https://picsum.photos/seed/terranova8c/800/600', 0, 3),
    (9, 'https://picsum.photos/seed/terranova9a/800/600', 1, 1),
    (9, 'https://picsum.photos/seed/terranova9b/800/600', 0, 2),
    (10, 'https://picsum.photos/seed/terranova10a/800/600', 1, 1),
    (10, 'https://picsum.photos/seed/terranova10b/800/600', 0, 2),
    (10, 'https://picsum.photos/seed/terranova10c/800/600', 0, 3),
    (11, 'https://picsum.photos/seed/terranova11a/800/600', 1, 1),
    (11, 'https://picsum.photos/seed/terranova11b/800/600', 0, 2),
    (12, 'https://picsum.photos/seed/terranova12a/800/600', 1, 1),
    (12, 'https://picsum.photos/seed/terranova12b/800/600', 0, 2),
    (12, 'https://picsum.photos/seed/terranova12c/800/600', 0, 3),
    (13, 'https://picsum.photos/seed/terranova13a/800/600', 1, 1),
    (13, 'https://picsum.photos/seed/terranova13b/800/600', 0, 2),
    (14, 'https://picsum.photos/seed/terranova14a/800/600', 1, 1),
    (14, 'https://picsum.photos/seed/terranova14b/800/600', 0, 2),
    (14, 'https://picsum.photos/seed/terranova14c/800/600', 0, 3);

-- ---------------------------------------------------------------------
-- PROPIEDAD <-> CARACTERISTICA (N:M)
-- ---------------------------------------------------------------------
INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES
    (1, 2),
    (1, 1),
    (1, 5),
    (1, 4),
    (1, 9),
    (2, 12),
    (2, 2),
    (2, 9),
    (3, 10),
    (3, 7),
    (3, 1),
    (4, 2),
    (4, 4),
    (4, 11),
    (5, 10),
    (5, 1),
    (5, 9),
    (5, 4),
    (5, 7),
    (6, 8),
    (6, 10),
    (6, 5),
    (7, 3),
    (7, 7),
    (7, 6),
    (8, 3),
    (8, 4),
    (8, 6),
    (8, 2),
    (9, 7),
    (9, 2),
    (9, 6),
    (10, 10),
    (10, 5),
    (10, 1),
    (10, 8),
    (11, 2),
    (11, 7),
    (11, 12),
    (11, 9),
    (11, 5),
    (12, 10),
    (12, 6),
    (12, 12),
    (12, 4),
    (12, 2),
    (13, 11),
    (13, 4),
    (13, 5),
    (14, 4),
    (14, 2),
    (14, 7);

-- ---------------------------------------------------------------------
-- CITAS (respetan UNIQUE id_propiedad+fecha_hora)
-- id_cliente: 8,9,10,11
-- ---------------------------------------------------------------------
INSERT INTO cita (id_propiedad, id_cliente, fecha_hora, estado, observaciones) VALUES
    (1, 8, '2026-09-15 10:00:00', 'CONFIRMADA', 'Cliente interesado en compra'),
    (1, 9, '2026-09-16 15:00:00', 'PENDIENTE', NULL),
    (2, 8, '2026-09-14 09:00:00', 'REALIZADA', 'Visita completada'),
    (3, 10, '2026-09-12 17:00:00', 'REALIZADA', NULL),
    (6, 9, '2026-09-18 11:00:00', 'PENDIENTE', NULL),
    (7, 11, '2026-08-30 10:00:00', 'REALIZADA', 'Compra concretada'),
    (9, 10, '2026-09-20 14:00:00', 'CONFIRMADA', NULL),
    (10, 8, '2026-09-22 08:00:00', 'PENDIENTE', 'Visita a finca, confirmar transporte'),
    (11, 9, '2026-08-25 16:00:00', 'REALIZADA', NULL),
    (4, 11, '2026-09-19 13:00:00', 'RECHAZADA', 'Agente no disponible ese dia'),
    (12, 10, '2026-09-21 10:00:00', 'PENDIENTE', NULL),
    (13, 8, '2026-09-23 09:30:00', 'CANCELADA', 'Cliente cancelo');

-- ---------------------------------------------------------------------
-- SOLICITUDES DE COMPRA/ARRIENDO
-- ---------------------------------------------------------------------
INSERT INTO solicitud (id_propiedad, id_cliente, tipo, estado, observaciones) VALUES
    (1, 8, 'COMPRA', 'EN_REVISION', 'Solicita credito hipotecario'),
    (7, 11, 'COMPRA', 'APROBADA', 'Documentacion completa'),
    (3, 10, 'ARRIENDO', 'APROBADA', NULL),
    (11, 9, 'ARRIENDO', 'APROBADA', 'Contrato firmado'),
    (9, 10, 'COMPRA', 'PENDIENTE', NULL),
    (2, 8, 'COMPRA', 'RECHAZADA', 'Ingresos no certificados'),
    (6, 9, 'COMPRA', 'EN_REVISION', NULL),
    (4, 11, 'ARRIENDO', 'PENDIENTE', 'Solicita contrato a 2 anios'),
    (10, 8, 'COMPRA', 'PENDIENTE', 'Interesado en finca completa'),
    (12, 10, 'ARRIENDO', 'EN_REVISION', NULL);

-- ---------------------------------------------------------------------
-- DOCUMENTOS POR SOLICITUD
-- ---------------------------------------------------------------------
INSERT INTO documento_solicitud (id_solicitud, nombre_documento, url_archivo) VALUES
    (1, 'Cedula de ciudadania', '/docs/solicitud1_cedula.pdf'),
    (1, 'Certificado laboral', '/docs/solicitud1_laboral.pdf'),
    (2, 'Cedula de ciudadania', '/docs/solicitud2_cedula.pdf'),
    (2, 'Certificado laboral', '/docs/solicitud2_laboral.pdf'),
    (3, 'Cedula de ciudadania', '/docs/solicitud3_cedula.pdf'),
    (3, 'Certificado laboral', '/docs/solicitud3_laboral.pdf'),
    (4, 'Cedula de ciudadania', '/docs/solicitud4_cedula.pdf'),
    (4, 'Certificado laboral', '/docs/solicitud4_laboral.pdf'),
    (5, 'Cedula de ciudadania', '/docs/solicitud5_cedula.pdf'),
    (5, 'Certificado laboral', '/docs/solicitud5_laboral.pdf'),
    (6, 'Cedula de ciudadania', '/docs/solicitud6_cedula.pdf'),
    (6, 'Certificado laboral', '/docs/solicitud6_laboral.pdf'),
    (7, 'Cedula de ciudadania', '/docs/solicitud7_cedula.pdf'),
    (7, 'Certificado laboral', '/docs/solicitud7_laboral.pdf'),
    (8, 'Cedula de ciudadania', '/docs/solicitud8_cedula.pdf'),
    (8, 'Certificado laboral', '/docs/solicitud8_laboral.pdf'),
    (9, 'Cedula de ciudadania', '/docs/solicitud9_cedula.pdf'),
    (9, 'Certificado laboral', '/docs/solicitud9_laboral.pdf'),
    (10, 'Cedula de ciudadania', '/docs/solicitud10_cedula.pdf'),
    (10, 'Certificado laboral', '/docs/solicitud10_laboral.pdf');

-- ---------------------------------------------------------------------
-- FAVORITOS
-- ---------------------------------------------------------------------
INSERT INTO favorito (id_usuario, id_propiedad) VALUES
    (8, 1),
    (8, 5),
    (8, 10),
    (8, 12),
    (9, 2),
    (9, 6),
    (9, 9),
    (10, 3),
    (10, 11),
    (10, 13),
    (11, 4),
    (11, 7);

-- ---------------------------------------------------------------------
-- AUDITORIA (muestra de eventos registrados por la aplicacion)
-- ---------------------------------------------------------------------
INSERT INTO auditoria (id_usuario, accion, tabla_afectada, detalle, ip) VALUES
    (1, 'LOGIN', 'usuario', 'Inicio de sesion exitoso', '127.0.0.1'),
    (2, 'LOGIN', 'usuario', 'Inicio de sesion exitoso', '127.0.0.1'),
    (3, 'CREAR_PROPIEDAD', 'propiedad', 'Publico SAN-0001-BGA', '127.0.0.1'),
    (4, 'CREAR_PROPIEDAD', 'propiedad', 'Publico SAN-0003-BGA', '127.0.0.1'),
    (8, 'REGISTRO', 'usuario', 'Nueva cuenta cliente', '127.0.0.1'),
    (8, 'AGENDAR_CITA', 'cita', 'Cita sobre propiedad 1', '127.0.0.1'),
    (3, 'CAMBIAR_ESTADO_CITA', 'cita', 'Confirmo cita 1', '127.0.0.1'),
    (9, 'RADICAR_SOLICITUD', 'solicitud', 'Solicitud de compra propiedad 6', '127.0.0.1'),
    (5, 'APROBAR_SOLICITUD', 'solicitud', 'Aprobo solicitud 2', '127.0.0.1'),
    (1, 'CAMBIAR_ROL', 'usuario_rol', 'Asigno rol INMOBILIARIA a director', '127.0.0.1'),
    (1, 'INACTIVAR_USUARIO', 'usuario', 'Prueba de baja de cuenta', '127.0.0.1'),
    (10, 'MARCAR_FAVORITO', 'favorito', 'Marco propiedad 3 como favorita', '127.0.0.1');

