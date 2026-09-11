<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    int idAdmin = (Integer) session.getAttribute("idUsuario");
    int idUsuario = Integer.parseInt(request.getParameter("id"));
    String estado = request.getParameter("estado");

    if ("ACTIVO".equals(estado) || "INACTIVO".equals(estado)) {
        try (Connection con = abrirConexion();
             PreparedStatement ps = con.prepareStatement("UPDATE usuario SET estado=? WHERE id_usuario=?")) {
            ps.setString(1, estado);
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
            registrarAuditoria(con, idAdmin, "CAMBIAR_ESTADO_USUARIO", "usuario",
                "Usuario " + idUsuario + " -> " + estado, request.getRemoteAddr());
        } catch (SQLException ex) { }
    }
    response.sendRedirect(ctx + "/admin/usuarios.jsp?msg=actualizado");
%>
