# Modelo relacional (normalizado a 3FN) - TerraNova Bienes Raíces

La version exportada en PDF (entregable requerido) esta en
[`docs/diagramas/modelo_relacional.pdf`](diagramas/modelo_relacional.pdf).

Notacion: `tabla(columna PK, columna FK -> tabla_referenciada, ...)`

```
rol(id_rol PK, nombre UK)

usuario(id_usuario PK, correo UK, password_hash, password_salt,
        id_inmobiliaria FK -> inmobiliaria, estado, intentos_fallidos,
        bloqueado_hasta, fecha_registro)

usuario_rol(id_usuario PK,FK -> usuario, id_rol PK,FK -> rol, fecha_asignacion)

perfil(id_perfil PK, id_usuario FK,UK -> usuario, nombres, apellidos,
       documento, telefono, direccion, foto_url)

ciudad(id_ciudad PK, nombre, departamento)  -- UK(nombre, departamento)

tipo_propiedad(id_tipo PK, nombre UK)

caracteristica(id_caracteristica PK, nombre UK)

inmobiliaria(id_inmobiliaria PK, nombre, nit UK, telefono, direccion,
             id_ciudad FK -> ciudad)

propiedad(id_propiedad PK, matricula_inmobiliaria UK, titulo, descripcion,
          id_tipo FK -> tipo_propiedad, id_ciudad FK -> ciudad,
          id_inmobiliaria FK -> inmobiliaria, id_agente FK -> usuario,
          direccion, precio, area_m2, habitaciones, banos, operacion,
          estado, fecha_publicacion)

imagen_propiedad(id_imagen PK, id_propiedad FK -> propiedad, url_imagen,
                  es_principal, orden)

propiedad_caracteristica(id_propiedad PK,FK -> propiedad,
                          id_caracteristica PK,FK -> caracteristica)

cita(id_cita PK, id_propiedad FK -> propiedad, id_cliente FK -> usuario,
     fecha_hora, estado, observaciones)  -- UK(id_propiedad, fecha_hora)

solicitud(id_solicitud PK, id_propiedad FK -> propiedad,
          id_cliente FK -> usuario, tipo, estado, fecha_solicitud,
          observaciones)

documento_solicitud(id_documento PK, id_solicitud FK -> solicitud,
                     nombre_documento, url_archivo, fecha_carga)

favorito(id_usuario PK,FK -> usuario, id_propiedad PK,FK -> propiedad, fecha)

auditoria(id_auditoria PK, id_usuario FK -> usuario (nullable), accion,
          tabla_afectada, detalle, fecha_hora, ip)
```

## Justificacion de 3FN

- **1FN**: todos los atributos son atomicos (por ejemplo, `nombres` y
  `apellidos` estan separados en vez de un solo campo `nombre_completo`;
  no hay columnas repetidas ni listas dentro de una celda).
- **2FN**: las unicas llaves compuestas son las de las tres tablas
  intermedias N:M (`usuario_rol`, `propiedad_caracteristica`, `favorito`).
  Ninguna tiene atributos no clave que dependan de solo una parte de la
  llave compuesta (`fecha_asignacion` depende del PAR `id_usuario+id_rol`,
  no de uno solo).
- **3FN**: no hay dependencias transitivas. Ejemplos concretos de
  decisiones tomadas justamente para evitarlas:
  - `ciudad` es su propia tabla (no se repite `nombre`/`departamento`
    dentro de `propiedad` ni de `inmobiliaria`); ambas solo guardan el FK.
  - `inmobiliaria` es su propia tabla en vez de repetir
    `nombre_inmobiliaria`, `nit`, `telefono` dentro de cada `propiedad`.
  - `perfil` esta separado de `usuario` precisamente para que datos
    personales (que dependen de la persona, no de la cuenta de acceso)
    no vivan mezclados con credenciales.

## Acciones referenciales (ON DELETE / ON UPDATE) y su justificacion

| FK | ON DELETE | Por que |
|----|-----------|---------|
| `usuario.id_inmobiliaria -> inmobiliaria` | SET NULL | Si se elimina una agencia, el agente no debe desaparecer; solo queda sin agencia asignada. |
| `perfil.id_usuario -> usuario` | CASCADE | Un perfil no tiene sentido sin su usuario. |
| `usuario_rol.*` | CASCADE | La asignacion de rol no tiene sentido sin usuario o sin rol. |
| `inmobiliaria.id_ciudad -> ciudad` | SET NULL | La agencia puede quedar sin ciudad asociada temporalmente; no se justifica borrarla. |
| `propiedad.id_tipo/id_ciudad/id_inmobiliaria/id_agente` | RESTRICT | Evita borrar un catalogo o un agente que todavia tiene inventario activo publicado; obliga a reasignar primero. |
| `imagen_propiedad.id_propiedad -> propiedad` | CASCADE | Las imagenes no existen sin la propiedad. |
| `propiedad_caracteristica.*` | CASCADE | La relacion N:M no tiene sentido sin ambos lados. |
| `cita.id_propiedad/id_cliente` | CASCADE | Una cita huerfana (sin propiedad o sin cliente) no aporta valor. |
| `solicitud.id_propiedad/id_cliente` | CASCADE | Igual razon que `cita`. |
| `documento_solicitud.id_solicitud -> solicitud` | CASCADE | Un documento no existe sin su solicitud. |
| `favorito.*` | CASCADE | Un favorito no tiene sentido sin usuario o sin propiedad. |
| `auditoria.id_usuario -> usuario` | SET NULL | El historial de auditoria debe sobrevivir aunque el usuario sea eliminado despues. |

Todos los `ON UPDATE` se dejaron en `CASCADE` porque las llaves primarias
son `AUTO_INCREMENT` internas que nunca cambian manualmente; se declara por
completitud del modelo, no porque se use en la practica.
