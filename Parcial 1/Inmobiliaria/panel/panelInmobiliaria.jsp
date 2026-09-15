<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Panel inmobiliaria";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="panel-titulo mb-4"><i class="bi bi-speedometer2"></i> Panel de agente</h3>

<div class="row g-3 mb-4">
<%
    String[][] tarjetas = {
        {"Mis propiedades", "SELECT COUNT(*) FROM propiedad WHERE id_agente=? AND estado <> 'INACTIVO'", "bi-houses", "kpi-verde"},
        {"Citas pendientes", "SELECT COUNT(*) FROM cita c JOIN propiedad p ON p.id_propiedad=c.id_propiedad WHERE p.id_agente=? AND c.estado='PENDIENTE'", "bi-calendar-event", "kpi-dorado"},
        {"Solicitudes pendientes", "SELECT COUNT(*) FROM solicitud s JOIN propiedad p ON p.id_propiedad=s.id_propiedad WHERE p.id_agente=? AND s.estado IN ('PENDIENTE','EN_REVISION')", "bi-file-earmark-text", "kpi-azul"}
    };
    try (Connection con = abrirConexion()) {
        for (String[] t : tarjetas) {
            int valor = 0;
            try (PreparedStatement ps = con.prepareStatement(t[1])) {
                ps.setInt(1, idUsuario);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) valor = rs.getInt(1); }
            }
%>
    <div class="col-md-4">
        <div class="kpi-card <%= t[3] %> d-flex align-items-center gap-3">
            <i class="bi <%= t[2] %>" style="font-size:1.7rem;opacity:0.85;"></i>
            <div><div class="kpi-valor"><%= valor %></div><div class="kpi-label"><%= t[0] %></div></div>
        </div>
    </div>
<%      }
    } catch (SQLException ex) { %>
    <div class="col-12 text-danger">No se pudieron cargar las métricas: <%= escapar(ex.getMessage()) %></div>
<%  } %>
</div>

<div class="row g-3">
    <div class="col-6 col-md-3">
        <a class="panel-accion d-block text-center text-decoration-none" href="<%= ctx %>/propiedades/listar.jsp">
            <i class="bi bi-houses"></i> Mis propiedades</a>
    </div>
    <div class="col-6 col-md-3">
        <a class="panel-accion d-block text-center text-decoration-none" href="<%= ctx %>/propiedades/formulario.jsp">
            <i class="bi bi-plus-circle"></i> Publicar propiedad</a>
    </div>
    <div class="col-6 col-md-3">
        <a class="panel-accion d-block text-center text-decoration-none" href="<%= ctx %>/citas/listar.jsp">
            <i class="bi bi-calendar-check"></i> Citas</a>
    </div>
    <div class="col-6 col-md-3">
        <a class="panel-accion d-block text-center text-decoration-none" href="<%= ctx %>/solicitudes/listar.jsp">
            <i class="bi bi-file-earmark-text"></i> Solicitudes</a>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
