<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Acceso denegado";
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<div class="text-center py-5">
    <i class="bi bi-shield-lock text-danger" style="font-size:4rem;"></i>
    <h3 class="mt-3">Acceso denegado</h3>
    <p class="text-muted">Tu cuenta no tiene el rol necesario para ver esta página.</p>
    <a class="btn btn-success" href="<%= ctx %>/index.jsp"><i class="bi bi-house"></i> Volver al inicio</a>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
