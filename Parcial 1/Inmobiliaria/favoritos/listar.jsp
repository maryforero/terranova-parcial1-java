<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Mis favoritos";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-3"><i class="bi bi-heart-fill text-danger"></i> Mis favoritos</h3>

<div class="row g-3">
<%
    String sql = "SELECT p.id_propiedad, p.titulo, p.precio, p.operacion, p.estado, c.nombre AS ciudad, " +
                 "  (SELECT url_imagen FROM imagen_propiedad ip WHERE ip.id_propiedad=p.id_propiedad " +
                 "     ORDER BY ip.es_principal DESC, ip.orden ASC LIMIT 1) AS imagen " +
                 "FROM favorito f JOIN propiedad p ON p.id_propiedad = f.id_propiedad " +
                 "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                 "WHERE f.id_usuario = ? ORDER BY f.fecha DESC";
    try (Connection con = abrirConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, idUsuario);
        try (ResultSet rs = ps.executeQuery()) {
            boolean alguna = false;
            while (rs.next()) {
                alguna = true;
%>
    <div class="col-md-4 col-favorito">
        <div class="card tarjeta-propiedad shadow-sm">
            <img src="<%= escapar(rs.getString("imagen")) %>" class="card-img-top" alt="Propiedad">
            <div class="card-body">
                <span class="badge badge-estado-<%= rs.getString("estado") %>"><%= rs.getString("estado") %></span>
                <h6 class="mt-2 titulo-propiedad"><%= escapar(rs.getString("titulo")) %></h6>
                <p class="text-muted mb-1"><i class="bi bi-geo-alt"></i> <%= escapar(rs.getString("ciudad")) %></p>
                <p class="precio-destacado"><%= formatoCOP(rs.getDouble("precio")) %></p>
                <div class="d-flex gap-2">
                    <a class="btn btn-outline-success btn-sm flex-fill" href="<%= ctx %>/detallePropiedad.jsp?id=<%= rs.getInt("id_propiedad") %>">Ver</a>
                    <button type="button" class="btn btn-outline-danger btn-sm btn-quitar-favorito" data-id="<%= rs.getInt("id_propiedad") %>">
                        <i class="bi bi-heartbreak"></i></button>
                </div>
            </div>
        </div>
    </div>
<%      }
        if (!alguna) { %>
    <div class="col-12"><p class="text-muted">Aún no tienes propiedades favoritas. <a href="<%= ctx %>/catalogo.jsp">Explora el catálogo</a>.</p></div>
<%      }
    }
} catch (SQLException ex) { %>
    <div class="col-12 text-danger">Error: <%= escapar(ex.getMessage()) %></div>
<% } %>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
