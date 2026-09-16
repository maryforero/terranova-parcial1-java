package com.terranova.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.terranova.util.ConexionUtil;
import com.terranova.util.PasswordUtil;
import com.terranova.util.Utilidades;

/**
 * Controlador de la entidad Usuario/Sesion: login, registro y logout.
 * Reemplaza a procesarLogin.jsp, procesarRegistro.jsp y logout.jsp, mapeado
 * en web.xml a esas mismas rutas exactas para no romper ningun formulario
 * o enlace existente.
 */
public class AuthServlet extends HttpServlet {

    private static final int MAX_INTENTOS = 5;
    private static final int MINUTOS_BLOQUEO = 15;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getServletPath().endsWith("logout.jsp")) {
            String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
            HttpSession sesion = request.getSession(false);
            if (sesion != null) sesion.invalidate();
            response.sendRedirect(ctx + "/index.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String ruta = request.getServletPath();
        if (ruta.endsWith("procesarLogin.jsp")) {
            procesarLogin(request, response);
        } else if (ruta.endsWith("procesarRegistro.jsp")) {
            procesarRegistro(request, response);
        }
    }

    private void procesarLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        String correo = request.getParameter("correo");
        String clave  = request.getParameter("clave");

        if (correo == null || clave == null || correo.trim().isEmpty() || clave.isEmpty()) {
            response.sendRedirect(ctx + "/login.jsp?error=credenciales");
            return;
        }
        correo = correo.trim().toLowerCase();

        try (Connection con = ConexionUtil.abrirConexion()) {
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
                        Utilidades.registrarAuditoria(con, idUsuario, "LOGIN_FALLIDO", "usuario", "Clave incorrecta", request.getRemoteAddr());
                        response.sendRedirect(ctx + "/login.jsp?error=credenciales");
                        return;
                    }

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

                    Set<String> roles = new HashSet<>();
                    try (PreparedStatement psRoles = con.prepareStatement(
                            "SELECT r.nombre FROM usuario_rol ur JOIN rol r ON r.id_rol = ur.id_rol WHERE ur.id_usuario = ?")) {
                        psRoles.setInt(1, idUsuario);
                        try (ResultSet rsRoles = psRoles.executeQuery()) {
                            while (rsRoles.next()) roles.add(rsRoles.getString("nombre"));
                        }
                    }

                    Utilidades.registrarAuditoria(con, idUsuario, "LOGIN", "usuario", "Inicio de sesión exitoso", request.getRemoteAddr());

                    HttpSession sesionVieja = request.getSession(false);
                    if (sesionVieja != null) sesionVieja.invalidate();
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
    }

    private void procesarRegistro(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";

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
            con = ConexionUtil.abrirConexion();
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

            Utilidades.registrarAuditoria(con, idUsuarioNuevo, "REGISTRO", "usuario", "Nueva cuenta cliente: " + correo, request.getRemoteAddr());

            con.commit();

            HttpSession sesionVieja = request.getSession(false);
            if (sesionVieja != null) sesionVieja.invalidate();
            HttpSession nuevaSesion = request.getSession(true);
            nuevaSesion.setAttribute("idUsuario", idUsuarioNuevo);
            nuevaSesion.setAttribute("correo", correo.trim().toLowerCase());
            nuevaSesion.setAttribute("nombreCompleto", nombres.trim() + " " + apellidos.trim());
            Set<String> roles = new HashSet<>();
            roles.add("CLIENTE");
            nuevaSesion.setAttribute("roles", roles);

            response.sendRedirect(ctx + "/panel/panelCliente.jsp");
        } catch (SQLIntegrityConstraintViolationException dup) {
            ConexionUtil.deshacer(con);
            response.sendRedirect(ctx + "/registro.jsp?error=correo_duplicado");
        } catch (SQLException ex) {
            ConexionUtil.deshacer(con);
            response.sendRedirect(ctx + "/registro.jsp?error=campos_invalidos");
        } finally {
            ConexionUtil.cerrar(con);
        }
    }
}
