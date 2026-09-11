<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Panel administrador";
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-4"><i class="bi bi-speedometer2"></i> Panel administrador</h3>

<div class="row g-3 mb-4">
<%
    String[][] tarjetas = {
        {"Usuarios activos", "SELECT COUNT(*) FROM usuario WHERE estado='ACTIVO'", "bi-people", "primary"},
        {"Propiedades publicadas", "SELECT COUNT(*) FROM propiedad WHERE estado <> 'INACTIVO'", "bi-houses", "success"},
        {"Citas pendientes", "SELECT COUNT(*) FROM cita WHERE estado='PENDIENTE'", "bi-calendar-event", "warning"},
        {"Solicitudes pendientes", "SELECT COUNT(*) FROM solicitud WHERE estado IN ('PENDIENTE','EN_REVISION')", "bi-file-earmark-text", "info"}
    };
    try (Connection con = abrirConexion()) {
        for (String[] t : tarjetas) {
            int valor = 0;
            try (PreparedStatement ps = con.prepareStatement(t[1]); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) valor = rs.getInt(1);
            }
%>
    <div class="col-md-3">
        <div class="card shadow-sm border-<%= t[3] %>">
            <div class="card-body text-center">
                <i class="bi <%= t[2] %> text-<%= t[3] %>" style="font-size:1.8rem;"></i>
                <h3 class="mt-2 mb-0"><%= valor %></h3>
                <small class="text-muted"><%= t[0] %></small>
            </div>
        </div>
    </div>
<%      }
    } catch (SQLException ex) { %>
    <div class="col-12 text-danger">No se pudieron cargar las metricas: <%= escapar(ex.getMessage()) %></div>
<%  } %>
</div>

<div class="row g-3">
    <div class="col-md-3">
        <a class="btn btn-outline-primary w-100 py-3" href="<%= ctx %>/admin/usuarios.jsp">
            <i class="bi bi-people d-block mb-1" style="font-size:1.5rem;"></i> Usuarios y roles</a>
    </div>
    <div class="col-md-3">
        <a class="btn btn-outline-success w-100 py-3" href="<%= ctx %>/admin/catalogos.jsp">
            <i class="bi bi-tags d-block mb-1" style="font-size:1.5rem;"></i> Catalogos</a>
    </div>
    <div class="col-md-3">
        <a class="btn btn-outline-info w-100 py-3" href="<%= ctx %>/admin/auditoria.jsp">
            <i class="bi bi-shield-check d-block mb-1" style="font-size:1.5rem;"></i> Auditoria</a>
    </div>
    <div class="col-md-3">
        <a class="btn btn-outline-warning w-100 py-3" href="<%= ctx %>/reportes/reportes.jsp">
            <i class="bi bi-bar-chart d-block mb-1" style="font-size:1.5rem;"></i> Reportes</a>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
