<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    Integer idPropiedad = null;
    try { idPropiedad = Integer.parseInt(request.getParameter("id")); } catch (Exception ex) { }

    if (idPropiedad != null) {
        String sql = "UPDATE propiedad SET estado='INACTIVO' WHERE id_propiedad=?" + (esAdmin ? "" : " AND id_agente=?");
        try (Connection con = abrirConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            if (!esAdmin) ps.setInt(2, idUsuario);
            ps.executeUpdate();
            registrarAuditoria(con, idUsuario, "BAJA_PROPIEDAD", "propiedad", "Inactivó propiedad id=" + idPropiedad, request.getRemoteAddr());
        } catch (SQLException ex) { }
    }
    response.sendRedirect(ctx + "/propiedades/listar.jsp?msg=baja");
%>
