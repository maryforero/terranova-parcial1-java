# Diagrama de casos de uso - TerraNova Bienes Raíces

Diagrama en formato Mermaid (GitHub lo renderiza automáticamente al ver este
archivo en el repositorio). La versión exportada como imagen está en
[`docs/diagramas/casos_uso.png`](diagramas/casos_uso.png).

![Diagrama de casos de uso de TerraNova](diagramas/casos_uso.png)

```mermaid
flowchart LR
    subgraph Visitante_SG["👤 Visitante (no autenticado)"]
        direction TB
        V1(["Ver catálogo público de propiedades"])
        V2(["Ver detalle de una propiedad"])
        V3(["Registrarse"])
        V4(["Iniciar sesión"])
    end

    subgraph Cliente_SG["👤 Cliente"]
        direction TB
        C1(["Buscar y filtrar propiedades"])
        C2(["Marcar / quitar favorito"])
        C3(["Agendar visita a una propiedad"])
        C4(["Cancelar su propia cita"])
        C5(["Radicar solicitud de compra o arriendo"])
        C6(["Subir documentos de la solicitud"])
        C7(["Consultar el estado de su solicitud"])
        C8(["Actualizar su perfil / cambiar clave"])
    end

    subgraph Agente_SG["👤 Inmobiliaria (Agente)"]
        direction TB
        A1(["Publicar propiedad"])
        A2(["Editar propiedad"])
        A3(["Dar de baja una propiedad"])
        A4(["Gestionar características de la propiedad"])
        A5(["Gestionar galería de imágenes"])
        A6(["Confirmar / rechazar / marcar visita realizada"])
        A7(["Aprobar / rechazar solicitud"])
        A8(["Generar reportes de ventas y arriendos"])
    end

    subgraph Admin_SG["👤 Administrador"]
        direction TB
        D1(["Gestionar usuarios y asignar roles"])
        D2(["Activar / inactivar cuentas"])
        D3(["Parametrizar catálogos del sistema"])
        D4(["Consultar la auditoría de la aplicación"])
        D5(["Generar reportes"])
    end
```

## Notas sobre casos de uso compartidos

- **Iniciar sesión** lo hacen los cuatro roles con el mismo formulario
  (`login.jsp` → `AuthServlet`); el sistema redirige a un panel distinto
  según el rol que traiga la sesión (`panelAdmin.jsp`, `panelInmobiliaria.jsp`
  o `panelCliente.jsp`). El Visitante es el único que puede usar el sistema
  sin haber iniciado sesión.
- **Generar reportes** lo hacen tanto el Administrador como la Inmobiliaria
  (mismas 7 consultas de `reportes/reportes.jsp`); el Administrador ve el
  panorama completo y la Inmobiliaria ve el recorte de sus propias
  propiedades.
- El **Administrador tiene acceso total**: además de sus casos de uso
  propios, puede hacer cualquier operación de Cliente e Inmobiliaria (lo
  refleja `AccesoFilter.java`, cuyas reglas de `propiedades/`, `citas/` y
  `solicitudes/` incluyen explícitamente el rol `ADMINISTRADOR` junto al
  rol dueño de cada módulo).
- Los casos de uso de **Cliente** que dependen de una propiedad concreta
  (agendar visita, radicar solicitud, marcar favorito) requieren primero
  haber usado **Ver detalle de una propiedad**, heredado del Visitante.
