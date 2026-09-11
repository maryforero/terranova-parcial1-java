<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Solicitudes";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    boolean esAgente = tieneRol(session, "INMOBILIARIA");
    boolean esCliente = tieneRol(session, "CLIENTE");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-3"><i class="bi bi-file-earmark-text"></i> Solicitudes</h3>

<div class="table-responsive">
<table class="table table-hover bg-white align-middle">
<thead><tr>
    <th>Propiedad</th>
    <% if (!esCliente || esAdmin) { %><th>Cliente</th><% } %>
    <th>Tipo</th><th>Estado</th><th>Fecha</th><th>Documentos</th><th></th>
</tr></thead>
<tbody>
<%
    String sql;
    if (esAdmin) {
        sql = "SELECT s.*, p.titulo, pf.nombres, pf.apellidos, " +
              "  (SELECT COUNT(*) FROM documento_solicitud d WHERE d.id_solicitud=s.id_solicitud) AS ndocs " +
              "FROM solicitud s JOIN propiedad p ON p.id_propiedad=s.id_propiedad " +
              "JOIN perfil pf ON pf.id_usuario=s.id_cliente ORDER BY s.fecha_solicitud DESC";
    } else if (esAgente) {
        sql = "SELECT s.*, p.titulo, pf.nombres, pf.apellidos, " +
              "  (SELECT COUNT(*) FROM documento_solicitud d WHERE d.id_solicitud=s.id_solicitud) AS ndocs " +
              "FROM solicitud s JOIN propiedad p ON p.id_propiedad=s.id_propiedad " +
              "JOIN perfil pf ON pf.id_usuario=s.id_cliente " +
              "WHERE p.id_agente=? ORDER BY s.fecha_solicitud DESC";
    } else {
        sql = "SELECT s.*, p.titulo, NULL AS nombres, NULL AS apellidos, " +
              "  (SELECT COUNT(*) FROM documento_solicitud d WHERE d.id_solicitud=s.id_solicitud) AS ndocs " +
              "FROM solicitud s JOIN propiedad p ON p.id_propiedad=s.id_propiedad " +
              "WHERE s.id_cliente=? ORDER BY s.fecha_solicitud DESC";
    }
    try (Connection con = abrirConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
        if (!esAdmin) ps.setInt(1, idUsuario);
        try (ResultSet rs = ps.executeQuery()) {
            boolean alguna = false;
            while (rs.next()) {
                alguna = true;
                String estado = rs.getString("estado");
%>
    <tr>
        <td><%= escapar(rs.getString("titulo")) %></td>
        <% if (!esCliente || esAdmin) { %><td><%= escapar(rs.getString("nombres")) %> <%= escapar(rs.getString("apellidos")) %></td><% } %>
        <td><%= rs.getString("tipo") %></td>
        <td><span class="badge badge-solicitud-<%= estado %>"><%= estado %></span></td>
        <td><%= rs.getTimestamp("fecha_solicitud") %></td>
        <td><%= rs.getInt("ndocs") %></td>
        <td class="text-nowrap">
        <% if (esCliente && !esAdmin && !esAgente) { %>
            <a class="btn btn-sm btn-outline-secondary" href="<%= ctx %>/solicitudes/subirDocumento.jsp?id=<%= rs.getInt("id_solicitud") %>">Documentos</a>
        <% } %>
        <% if ((esAgente || esAdmin) && ("PENDIENTE".equals(estado) || "EN_REVISION".equals(estado))) { %>
            <a class="btn btn-sm btn-outline-primary" href="<%= ctx %>/solicitudes/cambiarEstado.jsp?id=<%= rs.getInt("id_solicitud") %>&estado=EN_REVISION">En revision</a>
            <a class="btn btn-sm btn-success" href="<%= ctx %>/solicitudes/cambiarEstado.jsp?id=<%= rs.getInt("id_solicitud") %>&estado=APROBADA">Aprobar</a>
            <a class="btn btn-sm btn-danger" href="<%= ctx %>/solicitudes/cambiarEstado.jsp?id=<%= rs.getInt("id_solicitud") %>&estado=RECHAZADA">Rechazar</a>
        <% } %>
        </td>
    </tr>
<%      }
        if (!alguna) { %>
    <tr><td colspan="7" class="text-center text-muted py-4">No hay solicitudes registradas.</td></tr>
<%      }
    }
} catch (SQLException ex) { %>
    <tr><td colspan="7" class="text-danger">Error: <%= escapar(ex.getMessage()) %></td></tr>
<% } %>
</tbody>
</table>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
