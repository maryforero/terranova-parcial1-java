<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Documentos de la solicitud";
    request.setCharacterEncoding("UTF-8");
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    int idSolicitud = Integer.parseInt(request.getParameter("id"));

    // Solo el cliente dueno de la solicitud puede radicar documentos en ella.
    boolean esDueno = false;
    try (Connection con = abrirConexion();
         PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM solicitud WHERE id_solicitud=? AND id_cliente=?")) {
        ps.setInt(1, idSolicitud);
        ps.setInt(2, idUsuario);
        try (ResultSet rs = ps.executeQuery()) { rs.next(); esDueno = rs.getInt(1) > 0; }
    } catch (SQLException ex) { }

    if ("POST".equalsIgnoreCase(request.getMethod()) && esDueno) {
        String nombreDoc = request.getParameter("nombreDocumento");
        String urlArchivo = request.getParameter("urlArchivo");
        if (nombreDoc != null && !nombreDoc.trim().isEmpty() && urlArchivo != null && !urlArchivo.trim().isEmpty()) {
            try (Connection con = abrirConexion();
                 PreparedStatement ps = con.prepareStatement(
                     "INSERT INTO documento_solicitud (id_solicitud, nombre_documento, url_archivo) VALUES (?,?,?)")) {
                ps.setInt(1, idSolicitud);
                ps.setString(2, nombreDoc.trim());
                ps.setString(3, urlArchivo.trim());
                ps.executeUpdate();
            } catch (SQLException ex) { }
        }
        response.sendRedirect(ctx + "/solicitudes/subirDocumento.jsp?id=" + idSolicitud);
        return;
    }
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-3"><i class="bi bi-file-earmark-arrow-up"></i> Documentos de la solicitud</h3>

<% if (!esDueno) { %>
    <div class="alert alert-warning">Solicitud no encontrada.</div>
<% } else { %>
<div class="table-responsive mb-3">
<table class="table bg-white">
<thead><tr><th>Documento</th><th>Referencia / URL</th><th>Fecha</th></tr></thead>
<tbody>
<%
    try (Connection con = abrirConexion();
         PreparedStatement ps = con.prepareStatement(
             "SELECT * FROM documento_solicitud WHERE id_solicitud=? ORDER BY fecha_carga")) {
        ps.setInt(1, idSolicitud);
        try (ResultSet rs = ps.executeQuery()) {
            boolean alguno = false;
            while (rs.next()) {
                alguno = true;
%>
    <tr><td><%= escapar(rs.getString("nombre_documento")) %></td>
        <td><%= escapar(rs.getString("url_archivo")) %></td>
        <td><%= rs.getTimestamp("fecha_carga") %></td></tr>
<%          }
            if (!alguno) { %>
    <tr><td colspan="3" class="text-center text-muted">Aun no has adjuntado documentos.</td></tr>
<%          }
        }
    } catch (SQLException ex) { } %>
</tbody>
</table>
</div>

<form method="post" action="<%= ctx %>/solicitudes/subirDocumento.jsp?id=<%= idSolicitud %>"
      class="row g-2 bg-white p-3 rounded-3 shadow-sm" data-validar novalidate>
    <div class="col-md-5">
        <input type="text" name="nombreDocumento" class="form-control" placeholder="Nombre del documento (ej. Cedula)" required>
        <div class="invalid-feedback"></div>
    </div>
    <div class="col-md-5">
        <input type="text" name="urlArchivo" class="form-control" placeholder="Referencia o URL del archivo" required>
        <div class="invalid-feedback"></div>
    </div>
    <div class="col-md-2 d-grid">
        <button type="submit" class="btn btn-success"><i class="bi bi-upload"></i> Adjuntar</button>
    </div>
</form>
<p class="form-text">Nota: por simplicidad esta version registra una referencia/URL del documento en vez de
    almacenar el archivo binario en el servidor.</p>
<a class="btn btn-outline-secondary mt-2" href="<%= ctx %>/solicitudes/listar.jsp">Volver a mis solicitudes</a>
<% } %>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
