<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Agendar visita";
    int idPropiedad = 0;
    try { idPropiedad = Integer.parseInt(request.getParameter("idPropiedad")); } catch (Exception ex) { }
    String error = request.getParameter("error");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<div class="row justify-content-center">
<div class="col-md-6">
<div class="card shadow-sm">
<div class="card-body p-4">
<h4 class="mb-3"><i class="bi bi-calendar-plus"></i> Agendar visita</h4>

<% if ("horario_ocupado".equals(error)) { %>
    <div class="alert alert-danger">Ya existe una cita agendada para esta propiedad en ese horario. Elige otro momento.</div>
<% } else if ("campos_invalidos".equals(error)) { %>
    <div class="alert alert-danger">Selecciona una fecha y hora validas.</div>
<% } %>

<%
    String titulo = null;
    try (Connection con = abrirConexion();
         PreparedStatement ps = con.prepareStatement("SELECT titulo, direccion FROM propiedad WHERE id_propiedad=?")) {
        ps.setInt(1, idPropiedad);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                titulo = rs.getString("titulo");
%>
<p class="text-muted"><%= escapar(titulo) %> &middot; <%= escapar(rs.getString("direccion")) %></p>
<%
            }
        }
    } catch (SQLException ex) { }

    if (titulo == null) {
%>
    <div class="alert alert-warning">La propiedad no existe.</div>
<%
    } else {
%>
<form method="post" action="<%= ctx %>/citas/guardarCita.jsp" data-validar novalidate>
    <input type="hidden" name="idPropiedad" value="<%= idPropiedad %>">
    <div class="mb-3">
        <label class="form-label">Fecha y hora de la visita</label>
        <input type="datetime-local" name="fechaHora" class="form-control" required>
        <div class="invalid-feedback"></div>
    </div>
    <div class="mb-3">
        <label class="form-label">Observaciones (opcional)</label>
        <textarea name="observaciones" class="form-control" rows="2"></textarea>
    </div>
    <button type="submit" class="btn btn-success w-100"><i class="bi bi-calendar-check"></i> Confirmar visita</button>
</form>
<% } %>
</div>
</div>
</div>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
