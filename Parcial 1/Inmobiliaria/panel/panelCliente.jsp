<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Panel cliente";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="panel-titulo mb-4"><i class="bi bi-speedometer2"></i> Mi panel</h3>

<div class="row g-3 mb-4">
<%
    String[][] tarjetas = {
        {"Favoritos", "SELECT COUNT(*) FROM favorito WHERE id_usuario=?", "bi-heart", "kpi-verde"},
        {"Mis citas", "SELECT COUNT(*) FROM cita WHERE id_cliente=?", "bi-calendar-event", "kpi-dorado"},
        {"Mis solicitudes", "SELECT COUNT(*) FROM solicitud WHERE id_cliente=?", "bi-file-earmark-text", "kpi-azul"}
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
        <a class="panel-accion d-block text-center text-decoration-none" href="<%= ctx %>/catalogo.jsp">
            <i class="bi bi-search"></i> Buscar propiedades</a>
    </div>
    <div class="col-6 col-md-3">
        <a class="panel-accion d-block text-center text-decoration-none" href="<%= ctx %>/favoritos/listar.jsp">
            <i class="bi bi-heart"></i> Mis favoritos</a>
    </div>
    <div class="col-6 col-md-3">
        <a class="panel-accion d-block text-center text-decoration-none" href="<%= ctx %>/citas/listar.jsp">
            <i class="bi bi-calendar-check"></i> Mis citas</a>
    </div>
    <div class="col-6 col-md-3">
        <a class="panel-accion d-block text-center text-decoration-none" href="<%= ctx %>/perfil/verPerfil.jsp">
            <i class="bi bi-person"></i> Mi perfil</a>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
