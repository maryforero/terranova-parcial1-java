<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Panel cliente";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-4"><i class="bi bi-speedometer2"></i> Mi panel</h3>

<div class="row g-3 mb-4">
<%
    String[][] tarjetas = {
        {"Favoritos", "SELECT COUNT(*) FROM favorito WHERE id_usuario=?", "bi-heart", "danger"},
        {"Mis citas", "SELECT COUNT(*) FROM cita WHERE id_cliente=?", "bi-calendar-event", "warning"},
        {"Mis solicitudes", "SELECT COUNT(*) FROM solicitud WHERE id_cliente=?", "bi-file-earmark-text", "info"}
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
        <a class="btn btn-outline-success w-100 py-3" href="<%= ctx %>/catalogo.jsp">
            <i class="bi bi-search d-block mb-1" style="font-size:1.5rem;"></i> Buscar propiedades</a>
    </div>
    <div class="col-md-3">
        <a class="btn btn-outline-danger w-100 py-3" href="<%= ctx %>/favoritos/listar.jsp">
            <i class="bi bi-heart d-block mb-1" style="font-size:1.5rem;"></i> Mis favoritos</a>
    </div>
    <div class="col-md-3">
        <a class="btn btn-outline-warning w-100 py-3" href="<%= ctx %>/citas/listar.jsp">
            <i class="bi bi-calendar-check d-block mb-1" style="font-size:1.5rem;"></i> Mis citas</a>
    </div>
    <div class="col-md-3">
        <a class="btn btn-outline-info w-100 py-3" href="<%= ctx %>/perfil/verPerfil.jsp">
            <i class="bi bi-person d-block mb-1" style="font-size:1.5rem;"></i> Mi perfil</a>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
