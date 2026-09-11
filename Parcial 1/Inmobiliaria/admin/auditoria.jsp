<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Auditoria";
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-3"><i class="bi bi-shield-check"></i> Auditoria de la aplicacion</h3>

<div class="table-responsive">
<table class="table table-sm table-striped bg-white">
<thead><tr><th>Fecha</th><th>Usuario</th><th>Accion</th><th>Tabla</th><th>Detalle</th><th>IP</th></tr></thead>
<tbody>
<%
    String sql = "SELECT a.*, pf.nombres, pf.apellidos " +
                 "FROM auditoria a LEFT JOIN perfil pf ON pf.id_usuario = a.id_usuario " +
                 "ORDER BY a.fecha_hora DESC LIMIT 200";
    try (Connection con = abrirConexion(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
        boolean alguna = false;
        while (rs.next()) {
            alguna = true;
            String usuarioTexto = rs.getString("nombres") != null
                ? escapar(rs.getString("nombres")) + " " + escapar(rs.getString("apellidos"))
                : "(usuario eliminado)";
%>
    <tr>
        <td><%= rs.getTimestamp("fecha_hora") %></td>
        <td><%= usuarioTexto %></td>
        <td><span class="badge text-bg-dark"><%= rs.getString("accion") %></span></td>
        <td><%= escapar(rs.getString("tabla_afectada")) %></td>
        <td><%= escapar(rs.getString("detalle")) %></td>
        <td><%= escapar(rs.getString("ip")) %></td>
    </tr>
<%      }
        if (!alguna) { %>
    <tr><td colspan="6" class="text-center text-muted py-4">Sin registros de auditoria.</td></tr>
<%      }
    } catch (SQLException ex) { %>
    <tr><td colspan="6" class="text-danger">Error: <%= escapar(ex.getMessage()) %></td></tr>
<% } %>
</tbody>
</table>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
