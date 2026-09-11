<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.terranova.util.PasswordUtil" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    request.setCharacterEncoding("UTF-8");
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String accion = request.getParameter("accion");

    if ("cambiarClave".equals(accion)) {
        String claveActual = request.getParameter("claveActual");
        String claveNueva = request.getParameter("claveNueva");
        String confirmar = request.getParameter("confirmarClaveNueva");

        if (claveNueva == null || !claveNueva.equals(confirmar) || claveNueva.length() < 4) {
            response.sendRedirect(ctx + "/perfil/verPerfil.jsp?error=clave_no_coincide");
            return;
        }
        try (Connection con = abrirConexion()) {
            String hashActual = null, saltActual = null;
            try (PreparedStatement ps = con.prepareStatement("SELECT password_hash, password_salt FROM usuario WHERE id_usuario=?")) {
                ps.setInt(1, idUsuario);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) { hashActual = rs.getString(1); saltActual = rs.getString(2); }
                }
            }
            if (hashActual == null || !PasswordUtil.verificar(claveActual, saltActual, hashActual)) {
                response.sendRedirect(ctx + "/perfil/verPerfil.jsp?error=clave_incorrecta");
                return;
            }
            String nuevoSalt = PasswordUtil.generarSalt();
            String nuevoHash = PasswordUtil.calcularHash(nuevoSalt, claveNueva);
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE usuario SET password_hash=?, password_salt=? WHERE id_usuario=?")) {
                ps.setString(1, nuevoHash);
                ps.setString(2, nuevoSalt);
                ps.setInt(3, idUsuario);
                ps.executeUpdate();
            }
            registrarAuditoria(con, idUsuario, "CAMBIAR_CLAVE", "usuario", "Cambio de clave", request.getRemoteAddr());
        } catch (SQLException ex) { }
        response.sendRedirect(ctx + "/perfil/verPerfil.jsp?msg=clave_actualizada");
        return;
    }

    String nombres = request.getParameter("nombres");
    String apellidos = request.getParameter("apellidos");
    String documento = request.getParameter("documento");
    String telefono = request.getParameter("telefono");
    String direccion = request.getParameter("direccion");
    String fotoUrl = request.getParameter("fotoUrl");

    if (nombres != null && !nombres.trim().isEmpty() && apellidos != null && !apellidos.trim().isEmpty()) {
        try (Connection con = abrirConexion();
             PreparedStatement ps = con.prepareStatement(
                 "UPDATE perfil SET nombres=?, apellidos=?, documento=?, telefono=?, direccion=?, foto_url=? WHERE id_usuario=?")) {
            ps.setString(1, nombres.trim());
            ps.setString(2, apellidos.trim());
            ps.setString(3, documento);
            ps.setString(4, telefono);
            ps.setString(5, direccion);
            ps.setString(6, fotoUrl);
            ps.setInt(7, idUsuario);
            ps.executeUpdate();

            session.setAttribute("nombreCompleto", nombres.trim() + " " + apellidos.trim());
        } catch (SQLException ex) { }
    }
    response.sendRedirect(ctx + "/perfil/verPerfil.jsp?msg=actualizado");
%>
