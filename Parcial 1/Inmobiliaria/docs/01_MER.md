# Modelo Entidad-Relación (MER) - TerraNova Bienes Raíces

Diagrama en formato Mermaid (GitHub lo renderiza automaticamente al ver este
archivo en el repositorio). Si el docente pide una imagen o PDF suelto,
puedes abrir este bloque en https://mermaid.live y exportarlo como PNG/SVG.

```mermaid
erDiagram
    ROL {
        int id_rol PK
        varchar nombre UK
    }
    USUARIO {
        int id_usuario PK
        varchar correo UK
        char password_hash
        char password_salt
        int id_inmobiliaria FK
        enum estado
        int intentos_fallidos
        datetime bloqueado_hasta
        datetime fecha_registro
    }
    USUARIO_ROL {
        int id_usuario PK,FK
        int id_rol PK,FK
        datetime fecha_asignacion
    }
    PERFIL {
        int id_perfil PK
        int id_usuario FK,UK
        varchar nombres
        varchar apellidos
        varchar documento
        varchar telefono
        varchar direccion
        varchar foto_url
    }
    INMOBILIARIA {
        int id_inmobiliaria PK
        varchar nombre
        varchar nit UK
        varchar telefono
        varchar direccion
        int id_ciudad FK
    }
    CIUDAD {
        int id_ciudad PK
        varchar nombre
        varchar departamento
    }
    TIPO_PROPIEDAD {
        int id_tipo PK
        varchar nombre UK
    }
    CARACTERISTICA {
        int id_caracteristica PK
        varchar nombre UK
    }
    PROPIEDAD {
        int id_propiedad PK
        varchar matricula_inmobiliaria UK
        varchar titulo
        text descripcion
        int id_tipo FK
        int id_ciudad FK
        int id_inmobiliaria FK
        int id_agente FK
        varchar direccion
        decimal precio
        decimal area_m2
        tinyint habitaciones
        tinyint banos
        enum operacion
        enum estado
        datetime fecha_publicacion
    }
    IMAGEN_PROPIEDAD {
        int id_imagen PK
        int id_propiedad FK
        varchar url_imagen
        tinyint es_principal
        int orden
    }
    PROPIEDAD_CARACTERISTICA {
        int id_propiedad PK,FK
        int id_caracteristica PK,FK
    }
    CITA {
        int id_cita PK
        int id_propiedad FK
        int id_cliente FK
        datetime fecha_hora
        enum estado
        varchar observaciones
    }
    SOLICITUD {
        int id_solicitud PK
        int id_propiedad FK
        int id_cliente FK
        enum tipo
        enum estado
        datetime fecha_solicitud
        varchar observaciones
    }
    DOCUMENTO_SOLICITUD {
        int id_documento PK
        int id_solicitud FK
        varchar nombre_documento
        varchar url_archivo
        datetime fecha_carga
    }
    FAVORITO {
        int id_usuario PK,FK
        int id_propiedad PK,FK
        datetime fecha
    }
    AUDITORIA {
        int id_auditoria PK
        int id_usuario FK
        varchar accion
        varchar tabla_afectada
        varchar detalle
        datetime fecha_hora
        varchar ip
    }

    ROL ||--o{ USUARIO_ROL : "asigna"
    USUARIO ||--o{ USUARIO_ROL : "tiene (N:M)"
    USUARIO ||--|| PERFIL : "1:1"
    INMOBILIARIA ||--o{ USUARIO : "emplea agentes (1:N)"
    CIUDAD ||--o{ INMOBILIARIA : "ubica (1:N)"
    CIUDAD ||--o{ PROPIEDAD : "ubica (1:N)"
    TIPO_PROPIEDAD ||--o{ PROPIEDAD : "clasifica (1:N)"
    INMOBILIARIA ||--o{ PROPIEDAD : "publica (1:N)"
    USUARIO ||--o{ PROPIEDAD : "es agente de (1:N)"
    PROPIEDAD ||--o{ IMAGEN_PROPIEDAD : "galeria (1:N)"
    PROPIEDAD ||--o{ PROPIEDAD_CARACTERISTICA : "tiene (N:M)"
    CARACTERISTICA ||--o{ PROPIEDAD_CARACTERISTICA : "aplica a (N:M)"
    PROPIEDAD ||--o{ CITA : "recibe (1:N)"
    USUARIO ||--o{ CITA : "agenda (1:N)"
    PROPIEDAD ||--o{ SOLICITUD : "recibe (1:N)"
    USUARIO ||--o{ SOLICITUD : "radica (1:N)"
    SOLICITUD ||--o{ DOCUMENTO_SOLICITUD : "adjunta (1:N)"
    USUARIO ||--o{ FAVORITO : "marca (N:M)"
    PROPIEDAD ||--o{ FAVORITO : "es marcada (N:M)"
    USUARIO ||--o{ AUDITORIA : "genera evento"
```

## Relaciones exigidas por el enunciado y donde se materializan

| Tipo | Tablas | Como se garantiza |
|------|--------|--------------------|
| **1:1** | `usuario` &harr; `perfil` | `perfil.id_usuario` es `FOREIGN KEY` y ademas `UNIQUE`: un usuario nunca puede tener dos perfiles. |
| **1:N** | `inmobiliaria` &rarr; `propiedad`, `inmobiliaria` &rarr; `usuario` (agentes), `ciudad` &rarr; `propiedad`, `tipo_propiedad` &rarr; `propiedad`, `propiedad` &rarr; `imagen_propiedad`, `usuario` &rarr; `cita`, `usuario` &rarr; `solicitud`, `solicitud` &rarr; `documento_solicitud` | La llave foranea vive siempre en la tabla "muchos"; cada una declara `ON DELETE`/`ON UPDATE` explicito (ver `02_modelo_relacional.md`). |
| **N:M** | `usuario` &harr; `rol` via `usuario_rol`; `propiedad` &harr; `caracteristica` via `propiedad_caracteristica`; `usuario` &harr; `propiedad` via `favorito` | Las tres tablas intermedias tienen **llave primaria compuesta** por las dos llaves foraneas. `usuario_rol` ademas guarda `fecha_asignacion` como atributo propio de la relacion. |

El caso de uso real de la N:M `usuario_rol` esta en los datos de prueba: el
usuario `director@terranova.com` tiene **simultaneamente** los roles
`ADMINISTRADOR` e `INMOBILIARIA` (ver `sql/02_dml_inmobiliaria.sql`), lo que
demuestra que un usuario puede tener mas de un rol al mismo tiempo.
