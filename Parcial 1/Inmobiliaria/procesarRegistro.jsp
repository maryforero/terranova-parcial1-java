<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.terranova.util.PasswordUtil" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    request.setCharacterEncoding("UTF-8");

    String nombres        = request.getParameter("nombres");
    String apellidos      = request.getParameter("apellidos");
    String documento      = request.getParameter("documento");
    String telefono       = request.getParameter("telefono");
    String direccion      = request.getParameter("direccion");
    String correo         = request.getParameter("correo");
    String clave          = request.getParameter("clave");
    String confirmarClave = request.getParameter("confirmarClave");

    boolean invalido = nombres == null || nombres.trim().isEmpty()
            || apellidos == null || apellidos.trim().isEmpty()
            || documento == null || documento.trim().isEmpty()
            || correo == null || correo.trim().isEmpty()
            || clave == null || clave.length() < 4;

    if (invalido) {
        response.sendRedirect(ctx + "/registro.jsp?error=campos_invalidos");
        return;
    }
    if (!clave.equals(confirmarClave)) {
        response.sendRedirect(ctx + "/registro.jsp?error=clave_no_coincide");
        return;
    }

    Connection con = null;
    try {
        con = abrirConexion();
        con.setAutoCommit(false);

        String salt = PasswordUtil.generarSalt();
        String hash = PasswordUtil.calcularHash(salt, clave);

        int idUsuarioNuevo;
        String sqlUsuario = "INSERT INTO usuario (correo, password_hash, password_salt) VALUES (?,?,?)";
        try (PreparedStatement ps = con.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, correo.trim().toLowerCase());
            ps.setString(2, hash);
            ps.setString(3, salt);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                keys.next();
                idUsuarioNuevo = keys.getInt(1);
            }
        }

        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES (?,?,?,?,?,?)")) {
            ps.setInt(1, idUsuarioNuevo);
            ps.setString(2, nombres.trim());
            ps.setString(3, apellidos.trim());
            ps.setString(4, documento.trim());
            ps.setString(5, telefono);
            ps.setString(6, direccion);
            ps.executeUpdate();
        }

        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO usuario_rol (id_usuario, id_rol) SELECT ?, id_rol FROM rol WHERE nombre='CLIENTE'")) {
            ps.setInt(1, idUsuarioNuevo);
            ps.executeUpdate();
        }

        registrarAuditoria(con, idUsuarioNuevo, "REGISTRO", "usuario", "Nueva cuenta cliente: " + correo, request.getRemoteAddr());

        con.commit();

        // Inicio de sesión automático tras registrarse
        session.invalidate();
        HttpSession nuevaSesion = request.getSession(true);
        nuevaSesion.setAttribute("idUsuario", idUsuarioNuevo);
        nuevaSesion.setAttribute("correo", correo.trim().toLowerCase());
        nuevaSesion.setAttribute("nombreCompleto", nombres.trim() + " " + apellidos.trim());
        java.util.Set<String> roles = new java.util.HashSet<>();
        roles.add("CLIENTE");
        nuevaSesion.setAttribute("roles", roles);

        response.sendRedirect(ctx + "/panel/panelCliente.jsp");
    } catch (SQLIntegrityConstraintViolationException dup) {
        deshacer(con);
        response.sendRedirect(ctx + "/registro.jsp?error=correo_duplicado");
    } catch (SQLException ex) {
        deshacer(con);
        response.sendRedirect(ctx + "/registro.jsp?error=campos_invalidos");
    } finally {
        cerrar(con);
    }
%>
