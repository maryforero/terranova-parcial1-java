<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    int idUsuario = (Integer) session.getAttribute("idUsuario");

    int idSolicitud = Integer.parseInt(request.getParameter("id"));
    String nuevoEstado = request.getParameter("estado");
    java.util.Set<String> permitidos = new java.util.HashSet<>(java.util.Arrays.asList(
        "PENDIENTE","EN_REVISION","APROBADA","RECHAZADA"));

    if (nuevoEstado != null && permitidos.contains(nuevoEstado)) {
        String sql = "UPDATE solicitud s JOIN propiedad p ON p.id_propiedad = s.id_propiedad " +
                     "SET s.estado=? WHERE s.id_solicitud=?" + (esAdmin ? "" : " AND p.id_agente=?");
        try (Connection con = abrirConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idSolicitud);
            if (!esAdmin) ps.setInt(3, idUsuario);
            ps.executeUpdate();
            registrarAuditoria(con, idUsuario, "CAMBIAR_ESTADO_SOLICITUD", "solicitud",
                "Solicitud " + idSolicitud + " -> " + nuevoEstado, request.getRemoteAddr());
        } catch (SQLException ex) { }
    }
    response.sendRedirect(ctx + "/solicitudes/listar.jsp");
%>
