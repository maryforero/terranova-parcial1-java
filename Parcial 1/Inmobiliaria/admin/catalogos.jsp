<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Catálogos del sistema";
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-3"><i class="bi bi-tags"></i> Catálogos del sistema</h3>
<% if ("agregado".equals(msg)) { %><div class="alert alert-success">Elemento agregado al catálogo.</div><% } %>
<% if ("duplicado".equals(error)) { %><div class="alert alert-danger">Ese nombre ya existe en el catálogo.</div><% } %>

<div class="row g-4">
<%
    String[][] catalogos = {
        {"ciudad", "Ciudades", "nombre"},
        {"tipo_propiedad", "Tipos de propiedad", "nombre"},
        {"caracteristica", "Características", "nombre"}
    };
    for (String[] cat : catalogos) {
%>
    <div class="col-md-4">
        <div class="card shadow-sm h-100">
            <div class="card-body">
                <h6><%= cat[1] %></h6>
                <ul class="list-group list-group-flush mb-3" style="max-height:220px; overflow-y:auto;">
                <%
                    try (Connection con = abrirConexion();
                         PreparedStatement ps = con.prepareStatement("SELECT " + cat[2] + " FROM " + cat[0] + " ORDER BY " + cat[2]);
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                %>
                    <li class="list-group-item py-1"><%= escapar(rs.getString(1)) %></li>
                <%      }
                    } catch (SQLException ex) { } %>
                </ul>
                <form method="post" action="<%= ctx %>/admin/guardarCatalogo.jsp" class="d-flex gap-2">
                    <input type="hidden" name="tabla" value="<%= cat[0] %>">
                    <input type="text" name="nombre" class="form-control form-control-sm" placeholder="Nuevo..." required>
                    <% if ("ciudad".equals(cat[0])) { %>
                    <input type="text" name="departamento" class="form-control form-control-sm"
                           placeholder="Depto." value="Santander" required>
                    <% } %>
                    <button type="submit" class="btn btn-sm btn-success"><i class="bi bi-plus"></i></button>
                </form>
            </div>
        </div>
    </div>
<% } %>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
