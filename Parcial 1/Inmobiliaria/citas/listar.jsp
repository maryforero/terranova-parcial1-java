<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Citas";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    boolean esAgente = tieneRol(session, "INMOBILIARIA");
    boolean esCliente = tieneRol(session, "CLIENTE");
    String msg = request.getParameter("msg");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-3"><i class="bi bi-calendar-check"></i> Citas</h3>
<% if ("agendada".equals(msg)) { %><div class="alert alert-success">Cita agendada correctamente.</div><% } %>
<% if ("actualizada".equals(msg)) { %><div class="alert alert-success">Cita actualizada.</div><% } %>

<div class="table-responsive">
<table class="table table-hover bg-white align-middle">
<thead><tr>
    <th>Propiedad</th>
    <% if (!esCliente || esAdmin) { %><th>Cliente</th><% } %>
    <th>Fecha y hora</th><th>Estado</th><th>Observaciones</th><th></th>
</tr></thead>
<tbody>
<%
    String sql;
    if (esAdmin) {
        sql = "SELECT c.*, p.titulo, pf.nombres, pf.apellidos " +
              "FROM cita c JOIN propiedad p ON p.id_propiedad=c.id_propiedad " +
              "JOIN perfil pf ON pf.id_usuario=c.id_cliente ORDER BY c.fecha_hora DESC";
    } else if (esAgente) {
        sql = "SELECT c.*, p.titulo, pf.nombres, pf.apellidos " +
              "FROM cita c JOIN propiedad p ON p.id_propiedad=c.id_propiedad " +
              "JOIN perfil pf ON pf.id_usuario=c.id_cliente " +
              "WHERE p.id_agente=? ORDER BY c.fecha_hora DESC";
    } else {
        sql = "SELECT c.*, p.titulo, NULL AS nombres, NULL AS apellidos " +
              "FROM cita c JOIN propiedad p ON p.id_propiedad=c.id_propiedad " +
              "WHERE c.id_cliente=? ORDER BY c.fecha_hora DESC";
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
        <td><%= rs.getTimestamp("fecha_hora") %></td>
        <td><span class="badge badge-cita-<%= estado %>"><%= estado %></span></td>
        <td><%= escapar(rs.getString("observaciones")) %></td>
        <td class="text-nowrap">
        <% if ((esAgente || esAdmin) && "PENDIENTE".equals(estado)) { %>
            <a class="btn btn-sm btn-success" href="<%= ctx %>/citas/cambiarEstado.jsp?id=<%= rs.getInt("id_cita") %>&estado=CONFIRMADA">Confirmar</a>
            <a class="btn btn-sm btn-danger" href="<%= ctx %>/citas/cambiarEstado.jsp?id=<%= rs.getInt("id_cita") %>&estado=RECHAZADA">Rechazar</a>
        <% } %>
        <% if ((esAgente || esAdmin) && "CONFIRMADA".equals(estado)) { %>
            <a class="btn btn-sm btn-outline-primary" href="<%= ctx %>/citas/cambiarEstado.jsp?id=<%= rs.getInt("id_cita") %>&estado=REALIZADA">Marcar realizada</a>
        <% } %>
        <% if (esCliente && !esAdmin && "PENDIENTE".equals(estado)) { %>
            <a class="btn btn-sm btn-outline-secondary" href="<%= ctx %>/citas/cambiarEstado.jsp?id=<%= rs.getInt("id_cita") %>&estado=CANCELADA"
               onclick="return confirm('¿Cancelar esta cita?');">Cancelar</a>
        <% } %>
        </td>
    </tr>
<%      }
        if (!alguna) { %>
    <tr><td colspan="6" class="text-center text-muted py-4">No hay citas registradas.</td></tr>
<%      }
    }
} catch (SQLException ex) { %>
    <tr><td colspan="6" class="text-danger">Error: <%= escapar(ex.getMessage()) %></td></tr>
<% } %>
</tbody>
</table>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
