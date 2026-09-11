<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Caracteristicas";
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    int idPropiedad = 0;
    try { idPropiedad = Integer.parseInt(request.getParameter("id")); } catch (Exception ex) { }
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-3"><i class="bi bi-tags"></i> Caracteristicas de la propiedad</h3>

<%
    String sqlProp = "SELECT titulo FROM propiedad WHERE id_propiedad=?" + (esAdmin ? "" : " AND id_agente=?");
    String tituloProp = null;
    java.util.Set<Integer> seleccionadas = new java.util.HashSet<>();
    try (Connection con = abrirConexion()) {
        try (PreparedStatement ps = con.prepareStatement(sqlProp)) {
            ps.setInt(1, idPropiedad);
            if (!esAdmin) ps.setInt(2, idUsuario);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) tituloProp = rs.getString("titulo"); }
        }
        if (tituloProp != null) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id_caracteristica FROM propiedad_caracteristica WHERE id_propiedad=?")) {
                ps.setInt(1, idPropiedad);
                try (ResultSet rs = ps.executeQuery()) { while (rs.next()) seleccionadas.add(rs.getInt(1)); }
            }
        }
    } catch (SQLException ex) { }

    if (tituloProp == null) {
%>
    <div class="alert alert-warning">Propiedad no encontrada.</div>
<%
    } else {
%>
<h5><%= escapar(tituloProp) %></h5>
<form method="post" action="<%= ctx %>/propiedades/guardarCaracteristicas.jsp">
    <input type="hidden" name="idPropiedad" value="<%= idPropiedad %>">
    <div class="row g-2 bg-white p-3 rounded-3 shadow-sm">
    <%
        try (Connection con = abrirConexion();
             PreparedStatement ps = con.prepareStatement("SELECT id_caracteristica, nombre FROM caracteristica ORDER BY nombre");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int idc = rs.getInt("id_caracteristica");
                String checked = seleccionadas.contains(idc) ? "checked" : "";
    %>
        <div class="col-md-3">
            <div class="form-check">
                <input type="checkbox" class="form-check-input" name="caracteristicas" value="<%= idc %>"
                       id="car<%= idc %>" <%= checked %>>
                <label class="form-check-label" for="car<%= idc %>"><%= escapar(rs.getString("nombre")) %></label>
            </div>
        </div>
    <% } } catch (SQLException ex) { } %>
    </div>
    <button type="submit" class="btn btn-success mt-3"><i class="bi bi-check-circle"></i> Guardar</button>
    <a class="btn btn-outline-secondary mt-3" href="<%= ctx %>/propiedades/listar.jsp">Volver</a>
</form>
<% } %>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
