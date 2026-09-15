<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Iniciar sesion";
    String error = request.getParameter("error");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<div class="row justify-content-center">
    <div class="col-md-5">
        <div class="card shadow-sm">
            <div class="card-body p-4">
                <h4 class="mb-3"><i class="bi bi-box-arrow-in-right"></i> Iniciar sesion</h4>

                <% if ("credenciales".equals(error)) { %>
                    <div class="alert alert-danger">Usuario o clave incorrectos.</div>
                <% } else if ("inactivo".equals(error)) { %>
                    <div class="alert alert-warning">Tu cuenta se encuentra inactiva. Comunicate con el administrador.</div>
                <% } else if ("bloqueado".equals(error)) { %>
                    <div class="alert alert-warning">Tu cuenta esta bloqueada temporalmente por varios intentos fallidos. Intenta en unos minutos.</div>
                <% } else if ("sesion".equals(error)) { %>
                    <div class="alert alert-warning">Debes iniciar sesion para continuar.</div>
                <% } %>

                <p class="small text-muted mb-2 text-center">Acceso rapido de prueba</p>
                <div class="row g-2 mb-4">
                    <div class="col-4">
                        <form method="post" action="<%= ctx %>/procesarLogin.jsp">
                            <input type="hidden" name="correo" value="admin@terranova.com">
                            <input type="hidden" name="clave" value="1234">
                            <button type="submit" class="rol-rapido-card w-100">
                                <i class="bi bi-shield-lock"></i>
                                <span>Admin</span>
                            </button>
                        </form>
                    </div>
                    <div class="col-4">
                        <form method="post" action="<%= ctx %>/procesarLogin.jsp">
                            <input type="hidden" name="correo" value="agente.garcia@terranova.com">
                            <input type="hidden" name="clave" value="1234">
                            <button type="submit" class="rol-rapido-card w-100">
                                <i class="bi bi-building"></i>
                                <span>Agente</span>
                            </button>
                        </form>
                    </div>
                    <div class="col-4">
                        <form method="post" action="<%= ctx %>/procesarLogin.jsp">
                            <input type="hidden" name="correo" value="cliente.torres@gmail.com">
                            <input type="hidden" name="clave" value="1234">
                            <button type="submit" class="rol-rapido-card w-100">
                                <i class="bi bi-person"></i>
                                <span>Cliente</span>
                            </button>
                        </form>
                    </div>
                </div>
                <div class="row g-2 justify-content-center mb-1">
                    <div class="col-4">
                        <form method="post" action="<%= ctx %>/procesarLogin.jsp">
                            <input type="hidden" name="correo" value="director@terranova.com">
                            <input type="hidden" name="clave" value="1234">
                            <button type="submit" class="rol-rapido-card w-100">
                                <i class="bi bi-person-badge"></i>
                                <span>Director</span>
                            </button>
                        </form>
                    </div>
                </div>
                <p class="small text-muted text-center mb-4">Director tiene doble rol
                    (Administrador + Inmobiliaria) para demostrar la relacion N:M.</p>

                <div class="separador-o"><span>o ingresa con tu cuenta</span></div>

                <form method="post" action="<%= ctx %>/procesarLogin.jsp" class="mt-3" data-validar novalidate>
                    <div class="mb-3">
                        <label class="form-label">Correo</label>
                        <input type="email" name="correo" class="form-control" required autofocus>
                        <div class="invalid-feedback"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Clave</label>
                        <input type="password" name="clave" class="form-control" required>
                        <div class="invalid-feedback"></div>
                    </div>
                    <button type="submit" class="btn btn-success w-100"><i class="bi bi-box-arrow-in-right"></i> Ingresar</button>
                </form>
                <p class="text-center mt-3 mb-0">
                    No tienes cuenta? <a href="<%= ctx %>/registro.jsp">Registrate</a></p>
                <hr>
                <p class="small text-muted mb-0">Usuarios de prueba (clave <code>1234</code>):
                    admin@terranova.com &middot; director@terranova.com &middot;
                    agente.garcia@terranova.com &middot; cliente.torres@gmail.com</p>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
