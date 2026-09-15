<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Crear cuenta";
    String error = request.getParameter("error");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<div class="row justify-content-center">
    <div class="col-md-7">
        <div class="card shadow-sm">
            <div class="card-body p-4">
                <h4 class="mb-3"><i class="bi bi-person-plus"></i> Crear cuenta de cliente</h4>

                <% if ("correo_duplicado".equals(error)) { %>
                    <div class="alert alert-danger">El correo ya se encuentra registrado. Intenta con otro o inicia sesión.</div>
                <% } else if ("clave_no_coincide".equals(error)) { %>
                    <div class="alert alert-danger">Las claves no coinciden.</div>
                <% } else if ("campos_invalidos".equals(error)) { %>
                    <div class="alert alert-danger">Revisa los campos marcados: hay datos obligatorios o con formato inválido.</div>
                <% } %>

                <form method="post" action="<%= ctx %>/procesarRegistro.jsp" data-validar novalidate>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Nombres</label>
                            <input type="text" name="nombres" class="form-control" required>
                            <div class="invalid-feedback"></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Apellidos</label>
                            <input type="text" name="apellidos" class="form-control" required>
                            <div class="invalid-feedback"></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Documento</label>
                            <input type="text" name="documento" class="form-control" required>
                            <div class="invalid-feedback"></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Teléfono</label>
                            <input type="text" name="telefono" class="form-control" data-tipo="telefono">
                            <div class="invalid-feedback"></div>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Dirección</label>
                            <input type="text" name="direccion" class="form-control">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Correo electrónico</label>
                            <input type="email" name="correo" class="form-control" required>
                            <div class="invalid-feedback"></div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Clave</label>
                            <input type="password" name="clave" class="form-control" required minlength="4">
                            <div class="invalid-feedback"></div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Confirmar clave</label>
                            <input type="password" name="confirmarClave" class="form-control" required minlength="4">
                            <div class="invalid-feedback"></div>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-success w-100 mt-4">
                        <i class="bi bi-check-circle"></i> Crear cuenta</button>
                </form>
                <p class="text-center mt-3 mb-0">
                    ¿Ya tienes cuenta? <a href="<%= ctx %>/login.jsp">Inicia sesión</a></p>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
