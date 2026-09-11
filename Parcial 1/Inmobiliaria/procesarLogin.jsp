<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.terranova.util.PasswordUtil" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    request.setCharacterEncoding("UTF-8");

    String correo = request.getParameter("correo");
    String clave  = request.getParameter("clave");
    final int MAX_INTENTOS = 5;
    final int MINUTOS_BLOQUEO = 15;

    if (correo == null || clave == null || correo.trim().isEmpty() || clave.isEmpty()) {
        response.sendRedirect(ctx + "/login.jsp?error=credenciales");
        return;
    }
    correo = correo.trim().toLowerCase();

    try (Connection con = abrirConexion()) {
        String sql = "SELECT id_usuario, password_hash, password_salt, estado, intentos_fallidos, bloqueado_hasta " +
                     "FROM usuario WHERE correo = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, correo);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    response.sendRedirect(ctx + "/login.jsp?error=credenciales");
                    return;
                }

                int idUsuario   = rs.getInt("id_usuario");
                String hash     = rs.getString("password_hash");
                String salt     = rs.getString("password_salt");
                String estado   = rs.getString("estado");
                Timestamp bloqueadoHasta = rs.getTimestamp("bloqueado_hasta");

                if (bloqueadoHasta != null && bloqueadoHasta.after(new java.util.Date())) {
                    response.sendRedirect(ctx + "/login.jsp?error=bloqueado");
                    return;
                }
                if (!"ACTIVO".equals(estado)) {
                    response.sendRedirect(ctx + "/login.jsp?error=inactivo");
                    return;
                }

                if (!PasswordUtil.verificar(clave, salt, hash)) {
                    try (PreparedStatement psFallo = con.prepareStatement(
                            "UPDATE usuario SET intentos_fallidos = intentos_fallidos + 1, " +
                            "bloqueado_hasta = IF(intentos_fallidos + 1 >= ?, DATE_ADD(NOW(), INTERVAL ? MINUTE), bloqueado_hasta) " +
                            "WHERE id_usuario = ?")) {
                        psFallo.setInt(1, MAX_INTENTOS);
                        psFallo.setInt(2, MINUTOS_BLOQUEO);
                        psFallo.setInt(3, idUsuario);
                        psFallo.executeUpdate();
                    }
                    registrarAuditoria(con, idUsuario, "LOGIN_FALLIDO", "usuario", "Clave incorrecta", request.getRemoteAddr());
                    response.sendRedirect(ctx + "/login.jsp?error=credenciales");
                    return;
                }

                // Login correcto: reinicia contador de intentos
                try (PreparedStatement psOk = con.prepareStatement(
                        "UPDATE usuario SET intentos_fallidos = 0, bloqueado_hasta = NULL WHERE id_usuario = ?")) {
                    psOk.setInt(1, idUsuario);
                    psOk.executeUpdate();
                }

                String nombreCompleto = "";
                try (PreparedStatement psPerfil = con.prepareStatement(
                        "SELECT nombres, apellidos FROM perfil WHERE id_usuario = ?")) {
                    psPerfil.setInt(1, idUsuario);
                    try (ResultSet rsPerfil = psPerfil.executeQuery()) {
                        if (rsPerfil.next()) {
                            nombreCompleto = rsPerfil.getString("nombres") + " " + rsPerfil.getString("apellidos");
                        }
                    }
                }

                java.util.Set<String> roles = new java.util.HashSet<>();
                try (PreparedStatement psRoles = con.prepareStatement(
                        "SELECT r.nombre FROM usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol WHERE ur.id_usuario = ?")) {
                    psRoles.setInt(1, idUsuario);
                    try (ResultSet rsRoles = psRoles.executeQuery()) {
                        while (rsRoles.next()) roles.add(rsRoles.getString("nombre"));
                    }
                }

                registrarAuditoria(con, idUsuario, "LOGIN", "usuario", "Inicio de sesion exitoso", request.getRemoteAddr());

                session.invalidate();
                HttpSession nuevaSesion = request.getSession(true);
                nuevaSesion.setAttribute("idUsuario", idUsuario);
                nuevaSesion.setAttribute("correo", correo);
                nuevaSesion.setAttribute("nombreCompleto", nombreCompleto);
                nuevaSesion.setAttribute("roles", roles);

                if (roles.contains("ADMINISTRADOR")) {
                    response.sendRedirect(ctx + "/panel/panelAdmin.jsp");
                } else if (roles.contains("INMOBILIARIA")) {
                    response.sendRedirect(ctx + "/panel/panelInmobiliaria.jsp");
                } else {
                    response.sendRedirect(ctx + "/panel/panelCliente.jsp");
                }
            }
        }
    } catch (SQLException ex) {
        response.sendRedirect(ctx + "/login.jsp?error=credenciales");
    }
%>
