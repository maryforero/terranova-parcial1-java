<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Panel inmobiliaria";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-4"><i class="bi bi-speedometer2"></i> Panel de agente</h3>

<div class="row g-3 mb-4">
<%
    String[][] tarjetas = {
        {"Mis propiedades", "SELECT COUNT(*) FROM propiedad WHERE id_agente=? AND estado <> 'INACTIVO'", "bi-houses", "primary"},
        {"Citas pendientes", "SELECT COUNT(*) FROM cita c JOIN propiedad p ON p.id_propiedad=c.id_propiedad WHERE p.id_agente=? AND c.estado='PENDIENTE'", "bi-calendar-event", "warning"},
        {"Solicitudes pendientes", "SELECT COUNT(*) FROM solicitud s JOIN propiedad p ON p.id_propiedad=s.id_propiedad WHERE p.id_agente=? AND s.estado IN ('PENDIENTE','EN_REVISION')", "bi-file-earmark-text", "info"}
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
        <a class="btn btn-outline-primary w-100 py-3" href="<%= ctx %>/propiedades/listar.jsp">
            <i class="bi bi-houses d-block mb-1" style="font-size:1.5rem;"></i> Mis propiedades</a>
    </div>
    <div class="col-md-3">
        <a class="btn btn-outline-success w-100 py-3" href="<%= ctx %>/propiedades/formulario.jsp">
            <i class="bi bi-plus-circle d-block mb-1" style="font-size:1.5rem;"></i> Publicar propiedad</a>
    </div>
    <div class="col-md-3">
        <a class="btn btn-outline-warning w-100 py-3" href="<%= ctx %>/citas/listar.jsp">
            <i class="bi bi-calendar-check d-block mb-1" style="font-size:1.5rem;"></i> Citas</a>
    </div>
    <div class="col-md-3">
        <a class="btn btn-outline-info w-100 py-3" href="<%= ctx %>/solicitudes/listar.jsp">
            <i class="bi bi-file-earmark-text d-block mb-1" style="font-size:1.5rem;"></i> Solicitudes</a>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
