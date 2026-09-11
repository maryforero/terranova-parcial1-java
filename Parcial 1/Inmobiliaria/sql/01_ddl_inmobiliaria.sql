-- =====================================================================
-- TerraNova Bienes Raices - Script DDL
-- Parcial Practico Programacion Java - UTS
-- Motor: MySQL / MariaDB (XAMPP)
--
-- IMPORTANTE: se fuerza utf8mb4 en la conexion del cliente ANTES de
-- crear nada, porque mysql.exe en Windows no usa UTF-8 por defecto y
-- corrompe las tildes/enies de los datos de prueba si no se declara.
-- Ejecutar siempre asi:
--   mysql.exe --default-character-set=utf8mb4 -u root < 01_ddl_inmobiliaria.sql
-- =====================================================================
SET NAMES utf8mb4;

DROP DATABASE IF EXISTS inmobiliaria_terranova;
CREATE DATABASE inmobiliaria_terranova
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE inmobiliaria_terranova;

-- ---------------------------------------------------------------------
-- CATALOGOS BASE
-- ---------------------------------------------------------------------

CREATE TABLE rol (
    id_rol      INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE ciudad (
    id_ciudad     INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(60) NOT NULL,
    departamento  VARCHAR(60) NOT NULL,
    UNIQUE KEY uq_ciudad_departamento (nombre, departamento)
) ENGINE=InnoDB;

CREATE TABLE tipo_propiedad (
    id_tipo    INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(40) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE caracteristica (
    id_caracteristica  INT AUTO_INCREMENT PRIMARY KEY,
    nombre             VARCHAR(40) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE inmobiliaria (
    id_inmobiliaria  INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    nit              VARCHAR(20) NOT NULL UNIQUE,
    telefono         VARCHAR(20),
    direccion        VARCHAR(150),
    id_ciudad        INT,
    CONSTRAINT fk_inmobiliaria_ciudad
        FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- USUARIOS, PERFIL (1:1) Y ROLES (N:M)
-- ---------------------------------------------------------------------

CREATE TABLE usuario (
    id_usuario         INT AUTO_INCREMENT PRIMARY KEY,
    correo             VARCHAR(120) NOT NULL UNIQUE,
    password_hash      CHAR(64) NOT NULL,   -- SHA-256(salt + ':' + clave) en hexadecimal
    password_salt      CHAR(32) NOT NULL,   -- salto aleatorio unico por usuario (16 bytes en hex)
    id_inmobiliaria    INT NULL,            -- solo se usa si el usuario tiene el rol INMOBILIARIA
    estado             ENUM('ACTIVO','INACTIVO') NOT NULL DEFAULT 'ACTIVO',
    intentos_fallidos  INT NOT NULL DEFAULT 0,
    bloqueado_hasta    DATETIME NULL,
    fecha_registro     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuario_inmobiliaria
        FOREIGN KEY (id_inmobiliaria) REFERENCES inmobiliaria(id_inmobiliaria)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Relacion 1:1 usuario <-> perfil: el FK perfil.id_usuario es UNIQUE,
-- de modo que un usuario jamas pueda tener dos perfiles.
CREATE TABLE perfil (
    id_perfil    INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario   INT NOT NULL UNIQUE,
    nombres      VARCHAR(80) NOT NULL,
    apellidos    VARCHAR(80) NOT NULL,
    documento    VARCHAR(20) NOT NULL,
    telefono     VARCHAR(20),
    direccion    VARCHAR(150),
    foto_url     VARCHAR(255),
    CONSTRAINT fk_perfil_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Relacion N:M usuario <-> rol: un usuario puede tener varios roles
-- (ej. un director que administra Y gestiona propiedades) y un rol
-- pertenece a muchos usuarios. Llave primaria compuesta evita roles
-- repetidos para el mismo usuario.
CREATE TABLE usuario_rol (
    id_usuario        INT NOT NULL,
    id_rol            INT NOT NULL,
    fecha_asignacion  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT fk_usuario_rol_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_usuario_rol_rol
        FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- PROPIEDADES
-- ---------------------------------------------------------------------

CREATE TABLE propiedad (
    id_propiedad             INT AUTO_INCREMENT PRIMARY KEY,
    matricula_inmobiliaria   VARCHAR(30) NOT NULL UNIQUE,
    titulo                   VARCHAR(120) NOT NULL,
    descripcion              TEXT,
    id_tipo                  INT NOT NULL,
    id_ciudad                INT NOT NULL,
    id_inmobiliaria          INT NOT NULL,
    id_agente                INT NOT NULL,
    direccion                VARCHAR(150) NOT NULL,
    precio                   DECIMAL(14,2) NOT NULL,
    area_m2                  DECIMAL(8,2),
    habitaciones             TINYINT,
    banos                    TINYINT,
    operacion                ENUM('VENTA','ARRIENDO') NOT NULL,
    estado                   ENUM('DISPONIBLE','RESERVADO','VENDIDO','ARRENDADO','INACTIVO')
                             NOT NULL DEFAULT 'DISPONIBLE',
    fecha_publicacion        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- RESTRICT en los catalogos y en el agente: si alguien intenta borrar
    -- una ciudad/tipo/inmobiliaria/agente que todavia tiene propiedades
    -- publicadas, la base de datos rechaza el borrado en vez de dejar
    -- huerfanos o borrar en cascada un inventario completo por error.
    CONSTRAINT fk_propiedad_tipo
        FOREIGN KEY (id_tipo) REFERENCES tipo_propiedad(id_tipo)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_propiedad_ciudad
        FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_propiedad_inmobiliaria
        FOREIGN KEY (id_inmobiliaria) REFERENCES inmobiliaria(id_inmobiliaria)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_propiedad_agente
        FOREIGN KEY (id_agente) REFERENCES usuario(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Relacion 1:N propiedad -> imagen_propiedad (galeria)
CREATE TABLE imagen_propiedad (
    id_imagen      INT AUTO_INCREMENT PRIMARY KEY,
    id_propiedad   INT NOT NULL,
    url_imagen     VARCHAR(255) NOT NULL,
    es_principal   TINYINT(1) NOT NULL DEFAULT 0,
    orden          INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_imagen_propiedad
        FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Relacion N:M propiedad <-> caracteristica
CREATE TABLE propiedad_caracteristica (
    id_propiedad        INT NOT NULL,
    id_caracteristica    INT NOT NULL,
    PRIMARY KEY (id_propiedad, id_caracteristica),
    CONSTRAINT fk_propcar_propiedad
        FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_propcar_caracteristica
        FOREIGN KEY (id_caracteristica) REFERENCES caracteristica(id_caracteristica)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- CITAS, SOLICITUDES, DOCUMENTOS, FAVORITOS
-- ---------------------------------------------------------------------

CREATE TABLE cita (
    id_cita         INT AUTO_INCREMENT PRIMARY KEY,
    id_propiedad    INT NOT NULL,
    id_cliente      INT NOT NULL,
    fecha_hora      DATETIME NOT NULL,
    estado          ENUM('PENDIENTE','CONFIRMADA','RECHAZADA','REALIZADA','CANCELADA')
                    NOT NULL DEFAULT 'PENDIENTE',
    observaciones   VARCHAR(255),
    UNIQUE KEY uq_cita_propiedad_horario (id_propiedad, fecha_hora),
    CONSTRAINT fk_cita_propiedad
        FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cita_cliente
        FOREIGN KEY (id_cliente) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE solicitud (
    id_solicitud      INT AUTO_INCREMENT PRIMARY KEY,
    id_propiedad      INT NOT NULL,
    id_cliente        INT NOT NULL,
    tipo              ENUM('COMPRA','ARRIENDO') NOT NULL,
    estado            ENUM('PENDIENTE','EN_REVISION','APROBADA','RECHAZADA')
                      NOT NULL DEFAULT 'PENDIENTE',
    fecha_solicitud   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observaciones     VARCHAR(255),
    CONSTRAINT fk_solicitud_propiedad
        FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_solicitud_cliente
        FOREIGN KEY (id_cliente) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE documento_solicitud (
    id_documento       INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitud       INT NOT NULL,
    nombre_documento   VARCHAR(120) NOT NULL,
    url_archivo        VARCHAR(255) NOT NULL,
    fecha_carga        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_documento_solicitud
        FOREIGN KEY (id_solicitud) REFERENCES solicitud(id_solicitud)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Relacion N:M usuario(cliente) <-> propiedad
CREATE TABLE favorito (
    id_usuario     INT NOT NULL,
    id_propiedad   INT NOT NULL,
    fecha          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_propiedad),
    CONSTRAINT fk_favorito_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_favorito_propiedad
        FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- AUDITORIA
-- ---------------------------------------------------------------------

CREATE TABLE auditoria (
    id_auditoria     INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario       INT NULL,
    accion           VARCHAR(60) NOT NULL,
    tabla_afectada   VARCHAR(60),
    detalle          VARCHAR(255),
    fecha_hora       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip               VARCHAR(45),
    -- SET NULL: la auditoria debe sobrevivir aunque el usuario que
    -- genero el evento sea eliminado despues.
    CONSTRAINT fk_auditoria_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;
