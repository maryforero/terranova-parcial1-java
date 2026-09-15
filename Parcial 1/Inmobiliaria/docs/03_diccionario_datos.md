# Diccionario de datos - TerraNova Bienes Raíces

Motor: MySQL/MariaDB. Charset `utf8mb4`. Todas las PK son `INT AUTO_INCREMENT`
salvo las llaves compuestas de las tablas intermedias N:M.

## rol
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_rol | INT | NO | PK | Identificador del rol |
| nombre | VARCHAR(30) | NO | UK | ADMINISTRADOR / INMOBILIARIA / CLIENTE |

## usuario
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_usuario | INT | NO | PK | Identificador de la cuenta |
| correo | VARCHAR(120) | NO | UK | Credencial de ingreso; no se permiten duplicados |
| password_hash | CHAR(64) | NO | | SHA-256(salt+clave) en hexadecimal |
| password_salt | CHAR(32) | NO | | Salto aleatorio unico por usuario (16 bytes en hex) |
| id_inmobiliaria | INT | SI | FK -> inmobiliaria | Solo se usa si el usuario tiene rol INMOBILIARIA |
| estado | ENUM('ACTIVO','INACTIVO') | NO | | Cuenta activa o dada de baja por el admin |
| intentos_fallidos | INT | NO | | Contador para el bloqueo temporal |
| bloqueado_hasta | DATETIME | SI | | Fecha hasta la que el login queda bloqueado |
| fecha_registro | DATETIME | NO | | Timestamp de creacion de la cuenta |

## usuario_rol (N:M usuario <-> rol)
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_usuario | INT | NO | PK,FK -> usuario | |
| id_rol | INT | NO | PK,FK -> rol | |
| fecha_asignacion | DATETIME | NO | | Cuando se asigno ese rol a ese usuario |

## perfil (1:1 con usuario)
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_perfil | INT | NO | PK | |
| id_usuario | INT | NO | FK,UK -> usuario | UNIQUE: garantiza la relacion 1:1 |
| nombres | VARCHAR(80) | NO | | |
| apellidos | VARCHAR(80) | NO | | |
| documento | VARCHAR(20) | NO | | Cedula u otro documento de identidad |
| telefono | VARCHAR(20) | SI | | |
| direccion | VARCHAR(150) | SI | | |
| foto_url | VARCHAR(255) | SI | | Foto de perfil (URL) |

## ciudad
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_ciudad | INT | NO | PK | |
| nombre | VARCHAR(60) | NO | UK(nombre,departamento) | |
| departamento | VARCHAR(60) | NO | UK(nombre,departamento) | |

## tipo_propiedad
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_tipo | INT | NO | PK | |
| nombre | VARCHAR(40) | NO | UK | Casa, Apartamento, Local Comercial, etc. |

## caracteristica
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_caracteristica | INT | NO | PK | |
| nombre | VARCHAR(40) | NO | UK | Piscina, Parqueadero, Ascensor, etc. |

## inmobiliaria
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_inmobiliaria | INT | NO | PK | |
| nombre | VARCHAR(100) | NO | | Nombre comercial de la agencia |
| nit | VARCHAR(20) | NO | UK | Identificador tributario |
| telefono | VARCHAR(20) | SI | | |
| direccion | VARCHAR(150) | SI | | |
| id_ciudad | INT | SI | FK -> ciudad | |

## propiedad
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_propiedad | INT | NO | PK | |
| matricula_inmobiliaria | VARCHAR(30) | NO | UK | Identifica de forma irrepetible el inmueble |
| titulo | VARCHAR(120) | NO | | |
| descripcion | TEXT | SI | | |
| id_tipo | INT | NO | FK -> tipo_propiedad | |
| id_ciudad | INT | NO | FK -> ciudad | |
| id_inmobiliaria | INT | NO | FK -> inmobiliaria | Agencia que publica |
| id_agente | INT | NO | FK -> usuario | Agente responsable ("sus propiedades") |
| direccion | VARCHAR(150) | NO | | |
| precio | DECIMAL(14,2) | NO | | En pesos colombianos (COP) |
| area_m2 | DECIMAL(8,2) | SI | | |
| habitaciones | TINYINT | SI | | |
| banos | TINYINT | SI | | |
| operacion | ENUM('VENTA','ARRIENDO') | NO | | |
| estado | ENUM('DISPONIBLE','RESERVADO','VENDIDO','ARRENDADO','INACTIVO') | NO | | INACTIVO = baja logica |
| fecha_publicacion | DATETIME | NO | | |

## imagen_propiedad (1:N con propiedad)
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_imagen | INT | NO | PK | |
| id_propiedad | INT | NO | FK -> propiedad | |
| url_imagen | VARCHAR(255) | NO | | |
| es_principal | TINYINT(1) | NO | | 1 = foto de portada |
| orden | INT | NO | | Orden dentro de la galeria |

## propiedad_caracteristica (N:M propiedad <-> caracteristica)
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_propiedad | INT | NO | PK,FK -> propiedad | |
| id_caracteristica | INT | NO | PK,FK -> caracteristica | |

## cita
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_cita | INT | NO | PK | |
| id_propiedad | INT | NO | FK -> propiedad, UK(id_propiedad,fecha_hora) | |
| id_cliente | INT | NO | FK -> usuario | |
| fecha_hora | DATETIME | NO | UK(id_propiedad,fecha_hora) | Evita doble agenda en el mismo horario |
| estado | ENUM('PENDIENTE','CONFIRMADA','RECHAZADA','REALIZADA','CANCELADA') | NO | | |
| observaciones | VARCHAR(255) | SI | | |

## solicitud
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_solicitud | INT | NO | PK | |
| id_propiedad | INT | NO | FK -> propiedad | |
| id_cliente | INT | NO | FK -> usuario | |
| tipo | ENUM('COMPRA','ARRIENDO') | NO | | |
| estado | ENUM('PENDIENTE','EN_REVISION','APROBADA','RECHAZADA') | NO | | |
| fecha_solicitud | DATETIME | NO | | |
| observaciones | VARCHAR(255) | SI | | |

## documento_solicitud (1:N con solicitud)
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_documento | INT | NO | PK | |
| id_solicitud | INT | NO | FK -> solicitud | |
| nombre_documento | VARCHAR(120) | NO | | Ej: "Cedula", "Certificado laboral" |
| url_archivo | VARCHAR(255) | NO | | Referencia/URL del archivo (ver nota tecnica en el README) |
| fecha_carga | DATETIME | NO | | |

## favorito (N:M usuario <-> propiedad)
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_usuario | INT | NO | PK,FK -> usuario | |
| id_propiedad | INT | NO | PK,FK -> propiedad | |
| fecha | DATETIME | NO | | |

## auditoria
| Columna | Tipo | Null | Llave | Descripcion |
|---|---|---|---|---|
| id_auditoria | INT | NO | PK | |
| id_usuario | INT | SI | FK -> usuario (SET NULL) | Quien genero el evento |
| accion | VARCHAR(60) | NO | | LOGIN, REGISTRO, CREAR_PROPIEDAD, CAMBIAR_ESTADO_CITA, etc. |
| tabla_afectada | VARCHAR(60) | SI | | |
| detalle | VARCHAR(255) | SI | | |
| fecha_hora | DATETIME | NO | | |
| ip | VARCHAR(45) | SI | | IP de origen de la peticion |

## Restricciones UNIQUE del modelo (minimo exigido: 3)
1. `usuario.correo`
2. `propiedad.matricula_inmobiliaria`
3. `perfil.id_usuario` (sostiene la relacion 1:1)
4. `usuario_rol(id_usuario, id_rol)` (llave compuesta, evita roles repetidos)
5. `cita(id_propiedad, fecha_hora)` (evita doble agenda)
6. `inmobiliaria.nit`
7. `rol.nombre`, `tipo_propiedad.nombre`, `caracteristica.nombre`
8. `ciudad(nombre, departamento)`

Todas las inserciones/actualizaciones que pueden violar un UNIQUE (correo en
registro, matricula en propiedades, horario en citas) estan envueltas en
`try/catch SQLIntegrityConstraintViolationException` en las paginas JSP
correspondientes y muestran un mensaje de error legible en vez de una
excepcion de Java (ver `procesarRegistro.jsp`, `propiedades/guardar.jsp`,
`citas/guardarCita.jsp`).
