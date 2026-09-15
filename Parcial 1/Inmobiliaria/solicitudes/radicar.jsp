<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Radicar solicitud";
    int idPropiedad = 0;
    try { idPropiedad = Integer.parseInt(request.getParameter("idPropiedad")); } catch (Exception ex) { }
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<div class="row justify-content-center">
<div class="col-md-6">
<div class="card shadow-sm">
<div class="card-body p-4">
<h4 class="mb-3"><i class="bi bi-file-earmark-plus"></i> Radicar solicitud</h4>
<%
    String titulo = null, operacionProp = null;
    try (Connection con = abrirConexion();
         PreparedStatement ps = con.prepareStatement("SELECT titulo, operacion FROM propiedad WHERE id_propiedad=?")) {
        ps.setInt(1, idPropiedad);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) { titulo = rs.getString("titulo"); operacionProp = rs.getString("operacion"); }
        }
    } catch (SQLException ex) { }

    if (titulo == null) {
%>
    <div class="alert alert-warning">La propiedad no existe.</div>
<% } else { %>
<p class="text-muted"><%= escapar(titulo) %></p>
<form method="post" action="<%= ctx %>/solicitudes/guardarSolicitud.jsp" data-validar novalidate>
    <input type="hidden" name="idPropiedad" value="<%= idPropiedad %>">
    <div class="mb-3">
        <label class="form-label">Tipo de trámite</label>
        <select name="tipo" class="form-select">
            <option value="COMPRA" <%= "VENTA".equals(operacionProp) ? "selected" : "" %>>Compra</option>
            <option value="ARRIENDO" <%= "ARRIENDO".equals(operacionProp) ? "selected" : "" %>>Arriendo</option>
        </select>
    </div>
    <div class="mb-3">
        <label class="form-label">Observaciones (opcional)</label>
        <textarea name="observaciones" class="form-control" rows="3"
                  placeholder="Ej: solicito credito hipotecario, plazo del contrato, etc."></textarea>
    </div>
    <button type="submit" class="btn btn-success w-100"><i class="bi bi-send"></i> Radicar solicitud</button>
</form>
<% } %>
</div>
</div>
</div>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
