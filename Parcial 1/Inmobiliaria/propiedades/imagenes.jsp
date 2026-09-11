<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Galeria de imagenes";
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    int idPropiedad = 0;
    try { idPropiedad = Integer.parseInt(request.getParameter("id")); } catch (Exception ex) { }
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-3"><i class="bi bi-images"></i> Galeria de imagenes</h3>

<div class="row g-3 mb-4">
<%
    String sqlProp = "SELECT titulo FROM propiedad WHERE id_propiedad=?" + (esAdmin ? "" : " AND id_agente=?");
    String tituloProp = null;
    try (Connection con = abrirConexion()) {
        try (PreparedStatement ps = con.prepareStatement(sqlProp)) {
            ps.setInt(1, idPropiedad);
            if (!esAdmin) ps.setInt(2, idUsuario);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) tituloProp = rs.getString("titulo"); }
        }
        if (tituloProp == null) {
%>
    <div class="col-12"><div class="alert alert-warning">Propiedad no encontrada.</div></div>
<%
        } else {
%>
    <div class="col-12"><h5><%= escapar(tituloProp) %></h5></div>
<%
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT * FROM imagen_propiedad WHERE id_propiedad=? ORDER BY es_principal DESC, orden ASC")) {
                ps.setInt(1, idPropiedad);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
%>
    <div class="col-md-3">
        <div class="card shadow-sm">
            <img src="<%= escapar(rs.getString("url_imagen")) %>" class="card-img-top" style="height:140px;object-fit:cover;">
            <div class="card-body text-center p-2">
                <% if (rs.getBoolean("es_principal")) { %><span class="badge text-bg-success mb-1">Principal</span><br><% } %>
                <a class="btn btn-sm btn-outline-danger" href="<%= ctx %>/propiedades/eliminarImagen.jsp?idImagen=<%= rs.getInt("id_imagen") %>&idPropiedad=<%= idPropiedad %>"
                   onclick="return confirm('Eliminar esta imagen?');"><i class="bi bi-trash"></i> Eliminar</a>
            </div>
        </div>
    </div>
<%
                    }
                }
            }
        }
    } catch (SQLException ex) { %>
    <div class="col-12 text-danger">Error: <%= escapar(ex.getMessage()) %></div>
<% } %>
</div>

<% if (tituloProp != null) { %>
<form method="post" action="<%= ctx %>/propiedades/guardarImagen.jsp" class="row g-2 bg-white p-3 rounded-3 shadow-sm" data-validar novalidate>
    <input type="hidden" name="idPropiedad" value="<%= idPropiedad %>">
    <div class="col-md-7">
        <input type="text" name="urlImagen" class="form-control" placeholder="URL de la imagen (https://...)" required>
        <div class="invalid-feedback"></div>
    </div>
    <div class="col-md-3">
        <div class="form-check mt-2">
            <input type="checkbox" class="form-check-input" name="esPrincipal" value="1" id="esPrincipal">
            <label class="form-check-label" for="esPrincipal">Marcar como principal</label>
        </div>
    </div>
    <div class="col-md-2 d-grid">
        <button type="submit" class="btn btn-success"><i class="bi bi-plus-circle"></i> Agregar</button>
    </div>
</form>
<% } %>

<a class="btn btn-outline-secondary mt-3" href="<%= ctx %>/propiedades/listar.jsp">Volver</a>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
