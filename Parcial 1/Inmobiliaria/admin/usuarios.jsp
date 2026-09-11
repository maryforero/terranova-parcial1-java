<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Usuarios y roles";
    String msg = request.getParameter("msg");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-3"><i class="bi bi-people"></i> Usuarios y roles</h3>
<% if ("actualizado".equals(msg)) { %><div class="alert alert-success">Usuario actualizado.</div><% } %>

<div class="table-responsive">
<table class="table table-hover bg-white align-middle">
<thead><tr><th>Nombre</th><th>Correo</th><th>Roles</th><th>Estado</th><th></th></tr></thead>
<tbody>
<%
    String sqlUsuarios = "SELECT u.id_usuario, u.correo, u.estado, pf.nombres, pf.apellidos " +
                         "FROM usuario u JOIN perfil pf ON pf.id_usuario = u.id_usuario ORDER BY pf.nombres";
    try (Connection con = abrirConexion();
         PreparedStatement ps = con.prepareStatement(sqlUsuarios);
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            int idU = rs.getInt("id_usuario");
            java.util.Set<String> rolesActuales = new java.util.HashSet<>();
            try (PreparedStatement psr = con.prepareStatement(
                    "SELECT r.nombre FROM usuario_rol ur JOIN rol r ON r.id_rol=ur.id_rol WHERE ur.id_usuario=?")) {
                psr.setInt(1, idU);
                try (ResultSet rsr = psr.executeQuery()) { while (rsr.next()) rolesActuales.add(rsr.getString(1)); }
            }
%>
    <tr>
        <td><%= escapar(rs.getString("nombres")) %> <%= escapar(rs.getString("apellidos")) %></td>
        <td><%= escapar(rs.getString("correo")) %></td>
        <td>
            <form method="post" action="<%= ctx %>/admin/guardarRolUsuario.jsp" class="d-flex flex-wrap gap-2 align-items-center">
                <input type="hidden" name="idUsuario" value="<%= idU %>">
                <% for (String r : new String[]{"ADMINISTRADOR","INMOBILIARIA","CLIENTE"}) { %>
                <div class="form-check form-check-inline m-0">
                    <input class="form-check-input" type="checkbox" name="roles" value="<%= r %>"
                           id="r<%= idU %>_<%= r %>" <%= rolesActuales.contains(r) ? "checked" : "" %>>
                    <label class="form-check-label small" for="r<%= idU %>_<%= r %>"><%= r %></label>
                </div>
                <% } %>
                <button type="submit" class="btn btn-sm btn-outline-primary">Guardar roles</button>
            </form>
        </td>
        <td><span class="badge text-bg-<%= "ACTIVO".equals(rs.getString("estado")) ? "success" : "secondary" %>">
            <%= rs.getString("estado") %></span></td>
        <td>
            <a class="btn btn-sm btn-outline-warning"
               href="<%= ctx %>/admin/cambiarEstadoUsuario.jsp?id=<%= idU %>&estado=<%= "ACTIVO".equals(rs.getString("estado")) ? "INACTIVO" : "ACTIVO" %>">
                <%= "ACTIVO".equals(rs.getString("estado")) ? "Inactivar" : "Activar" %></a>
        </td>
    </tr>
<%      }
    } catch (SQLException ex) { %>
    <tr><td colspan="5" class="text-danger">Error: <%= escapar(ex.getMessage()) %></td></tr>
<% } %>
</tbody>
</table>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
