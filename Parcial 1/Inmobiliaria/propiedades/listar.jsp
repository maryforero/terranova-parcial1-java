<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Mis propiedades";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    String msg = request.getParameter("msg");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="mb-0"><i class="bi bi-houses"></i> <%= esAdmin ? "Todas las propiedades" : "Mis propiedades" %></h3>
    <a class="btn btn-success" href="<%= ctx %>/propiedades/formulario.jsp"><i class="bi bi-plus-circle"></i> Publicar</a>
</div>

<% if ("guardado".equals(msg)) { %><div class="alert alert-success">Propiedad guardada correctamente.</div><% } %>
<% if ("baja".equals(msg)) { %><div class="alert alert-success">Propiedad dada de baja (inactivada).</div><% } %>
<% if ("caracteristicas".equals(msg)) { %><div class="alert alert-success">Caracteristicas actualizadas.</div><% } %>
<% if ("imagen_agregada".equals(msg)) { %><div class="alert alert-success">Imagen agregada.</div><% } %>
<% if ("imagen_eliminada".equals(msg)) { %><div class="alert alert-success">Imagen eliminada.</div><% } %>
<% if ("matricula_duplicada".equals(msg)) { %><div class="alert alert-danger">Esa matricula inmobiliaria ya esta registrada en otra propiedad.</div><% } %>

<div class="table-responsive">
<table class="table table-hover bg-white align-middle">
<thead><tr>
    <th>Matricula</th><th>Titulo</th><th>Ciudad</th><th>Tipo</th>
    <% if (esAdmin) { %><th>Agente</th><% } %>
    <th>Precio</th><th>Operacion</th><th>Estado</th><th></th>
</tr></thead>
<tbody>
<%
    String sql = "SELECT p.*, c.nombre AS ciudad, t.nombre AS tipo, pf.nombres, pf.apellidos " +
                 "FROM propiedad p " +
                 "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                 "JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo " +
                 "JOIN usuario u ON u.id_usuario = p.id_agente " +
                 "JOIN perfil pf ON pf.id_usuario = u.id_usuario " +
                 (esAdmin ? "" : "WHERE p.id_agente = ? ") +
                 "ORDER BY p.fecha_publicacion DESC";
    try (Connection con = abrirConexion();
         PreparedStatement ps = con.prepareStatement(sql)) {
        if (!esAdmin) ps.setInt(1, idUsuario);
        try (ResultSet rs = ps.executeQuery()) {
            boolean alguna = false;
            while (rs.next()) {
                alguna = true;
                int idProp = rs.getInt("id_propiedad");
%>
    <tr>
        <td><%= escapar(rs.getString("matricula_inmobiliaria")) %></td>
        <td><%= escapar(rs.getString("titulo")) %></td>
        <td><%= escapar(rs.getString("ciudad")) %></td>
        <td><%= escapar(rs.getString("tipo")) %></td>
        <% if (esAdmin) { %><td><%= escapar(rs.getString("nombres")) %> <%= escapar(rs.getString("apellidos")) %></td><% } %>
        <td><%= formatoCOP(rs.getDouble("precio")) %></td>
        <td><%= rs.getString("operacion") %></td>
        <td><span class="badge badge-estado-<%= rs.getString("estado") %>"><%= rs.getString("estado") %></span></td>
        <td class="text-nowrap">
            <a class="btn btn-sm btn-outline-primary" href="<%= ctx %>/propiedades/formulario.jsp?id=<%= idProp %>" title="Editar"><i class="bi bi-pencil"></i></a>
            <a class="btn btn-sm btn-outline-secondary" href="<%= ctx %>/propiedades/imagenes.jsp?id=<%= idProp %>" title="Galeria"><i class="bi bi-images"></i></a>
            <a class="btn btn-sm btn-outline-secondary" href="<%= ctx %>/propiedades/caracteristicas.jsp?id=<%= idProp %>" title="Caracteristicas"><i class="bi bi-tags"></i></a>
            <% if (!"INACTIVO".equals(rs.getString("estado"))) { %>
            <a class="btn btn-sm btn-outline-danger" href="<%= ctx %>/propiedades/baja.jsp?id=<%= idProp %>"
               onclick="return confirm('Dar de baja esta propiedad?');" title="Dar de baja"><i class="bi bi-trash"></i></a>
            <% } %>
        </td>
    </tr>
<%      }
        if (!alguna) { %>
    <tr><td colspan="9" class="text-center text-muted py-4">No hay propiedades registradas todavia.</td></tr>
<%      }
    }
} catch (SQLException ex) { %>
    <tr><td colspan="9" class="text-danger">Error: <%= escapar(ex.getMessage()) %></td></tr>
<% } %>
</tbody>
</table>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
