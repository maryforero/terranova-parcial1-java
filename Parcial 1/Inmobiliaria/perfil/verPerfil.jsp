<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Mi perfil";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");

    String nombres = "", apellidos = "", documento = "", telefono = "", direccion = "", fotoUrl = "";
    try (Connection con = abrirConexion();
         PreparedStatement ps = con.prepareStatement("SELECT * FROM perfil WHERE id_usuario=?")) {
        ps.setInt(1, idUsuario);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                nombres = rs.getString("nombres"); apellidos = rs.getString("apellidos");
                documento = rs.getString("documento"); telefono = rs.getString("telefono");
                direccion = rs.getString("direccion"); fotoUrl = rs.getString("foto_url");
            }
        }
    } catch (SQLException ex) { }
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-3"><i class="bi bi-person"></i> Mi perfil</h3>
<% if ("actualizado".equals(msg)) { %><div class="alert alert-success">Perfil actualizado.</div><% } %>
<% if ("clave_actualizada".equals(msg)) { %><div class="alert alert-success">Clave actualizada.</div><% } %>
<% if ("clave_incorrecta".equals(error)) { %><div class="alert alert-danger">La clave actual no es correcta.</div><% } %>
<% if ("clave_no_coincide".equals(error)) { %><div class="alert alert-danger">Las claves nuevas no coinciden.</div><% } %>

<div class="row g-4">
<div class="col-md-7">
<div class="card shadow-sm"><div class="card-body">
<h6>Datos personales</h6>
<form method="post" action="<%= ctx %>/perfil/guardarPerfil.jsp" data-validar novalidate>
    <div class="row g-3">
        <div class="col-md-6"><label class="form-label">Nombres</label>
            <input type="text" name="nombres" class="form-control" required value="<%= escapar(nombres) %>">
            <div class="invalid-feedback"></div></div>
        <div class="col-md-6"><label class="form-label">Apellidos</label>
            <input type="text" name="apellidos" class="form-control" required value="<%= escapar(apellidos) %>">
            <div class="invalid-feedback"></div></div>
        <div class="col-md-6"><label class="form-label">Documento</label>
            <input type="text" name="documento" class="form-control" required value="<%= escapar(documento) %>">
            <div class="invalid-feedback"></div></div>
        <div class="col-md-6"><label class="form-label">Telefono</label>
            <input type="text" name="telefono" class="form-control" data-tipo="telefono" value="<%= telefono != null ? escapar(telefono) : "" %>">
            <div class="invalid-feedback"></div></div>
        <div class="col-12"><label class="form-label">Direccion</label>
            <input type="text" name="direccion" class="form-control" value="<%= direccion != null ? escapar(direccion) : "" %>"></div>
        <div class="col-12"><label class="form-label">URL de foto (opcional)</label>
            <input type="text" name="fotoUrl" class="form-control" value="<%= fotoUrl != null ? escapar(fotoUrl) : "" %>"></div>
    </div>
    <button type="submit" class="btn btn-success mt-3"><i class="bi bi-check-circle"></i> Guardar cambios</button>
</form>
</div></div>
</div>

<div class="col-md-5">
<div class="card shadow-sm"><div class="card-body">
<h6>Cambiar clave</h6>
<form method="post" action="<%= ctx %>/perfil/guardarPerfil.jsp" data-validar novalidate>
    <input type="hidden" name="accion" value="cambiarClave">
    <div class="mb-2"><label class="form-label">Clave actual</label>
        <input type="password" name="claveActual" class="form-control" required></div>
    <div class="mb-2"><label class="form-label">Clave nueva</label>
        <input type="password" name="claveNueva" class="form-control" required minlength="4"></div>
    <div class="mb-2"><label class="form-label">Confirmar clave nueva</label>
        <input type="password" name="confirmarClaveNueva" class="form-control" required minlength="4"></div>
    <button type="submit" class="btn btn-outline-success"><i class="bi bi-key"></i> Cambiar clave</button>
</form>
</div></div>
</div>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
