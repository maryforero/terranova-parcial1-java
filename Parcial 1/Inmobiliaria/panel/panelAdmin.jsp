<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Panel administrador";
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="panel-titulo mb-4"><i class="bi bi-speedometer2"></i> Panel administrador</h3>

<div class="row g-3 mb-4">
<%
    String[][] tarjetas = {
        {"Usuarios activos", "SELECT COUNT(*) FROM usuario WHERE estado='ACTIVO'", "bi-people", "kpi-verde"},
        {"Propiedades publicadas", "SELECT COUNT(*) FROM propiedad WHERE estado <> 'INACTIVO'", "bi-houses", "kpi-dorado"},
        {"Citas pendientes", "SELECT COUNT(*) FROM cita WHERE estado='PENDIENTE'", "bi-calendar-event", "kpi-azul"},
        {"Solicitudes pendientes", "SELECT COUNT(*) FROM solicitud WHERE estado IN ('PENDIENTE','EN_REVISION')", "bi-file-earmark-text", "kpi-gris"}
    };
    try (Connection con = abrirConexion()) {
        for (String[] t : tarjetas) {
            int valor = 0;
            try (PreparedStatement ps = con.prepareStatement(t[1]); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) valor = rs.getInt(1);
            }
%>
    <div class="col-6 col-lg-3">
        <div class="kpi-card <%= t[3] %> d-flex align-items-center gap-3">
            <i class="bi <%= t[2] %>" style="font-size:1.7rem;opacity:0.85;"></i>
            <div><div class="kpi-valor"><%= valor %></div><div class="kpi-label"><%= t[0] %></div></div>
        </div>
    </div>
<%      }
    } catch (SQLException ex) { %>
    <div class="col-12 text-danger">No se pudieron cargar las metricas: <%= escapar(ex.getMessage()) %></div>
<%  } %>
</div>

<div class="row g-3">
    <div class="col-6 col-md-3">
        <a class="panel-accion d-block text-center text-decoration-none" href="<%= ctx %>/admin/usuarios.jsp">
            <i class="bi bi-people"></i> Usuarios y roles</a>
    </div>
    <div class="col-6 col-md-3">
        <a class="panel-accion d-block text-center text-decoration-none" href="<%= ctx %>/admin/catalogos.jsp">
            <i class="bi bi-tags"></i> Catalogos</a>
    </div>
    <div class="col-6 col-md-3">
        <a class="panel-accion d-block text-center text-decoration-none" href="<%= ctx %>/admin/auditoria.jsp">
            <i class="bi bi-shield-check"></i> Auditoria</a>
    </div>
    <div class="col-6 col-md-3">
        <a class="panel-accion d-block text-center text-decoration-none" href="<%= ctx %>/reportes/reportes.jsp">
            <i class="bi bi-bar-chart"></i> Reportes</a>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
