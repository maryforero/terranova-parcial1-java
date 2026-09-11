<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    int idAdmin = (Integer) session.getAttribute("idUsuario");
    int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
    String[] roles = request.getParameterValues("roles");

    Connection con = null;
    try {
        con = abrirConexion();
        con.setAutoCommit(false);
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM usuario_rol WHERE id_usuario=?")) {
            ps.setInt(1, idUsuario);
            ps.executeUpdate();
        }
        if (roles != null && roles.length > 0) {
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO usuario_rol (id_usuario, id_rol) SELECT ?, id_rol FROM rol WHERE nombre=?")) {
                for (String r : roles) {
                    ps.setInt(1, idUsuario);
                    ps.setString(2, r);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
        }
        con.commit();
        registrarAuditoria(con, idAdmin, "CAMBIAR_ROL", "usuario_rol",
            "Actualizo roles del usuario " + idUsuario, request.getRemoteAddr());
    } catch (SQLException ex) {
        deshacer(con);
    } finally {
        cerrar(con);
    }
    response.sendRedirect(ctx + "/admin/usuarios.jsp?msg=actualizado");
%>
