package com.terranova.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.terranova.util.ConexionUtil;
import com.terranova.util.Utilidades;

/**
 * Controlador de la entidad Usuario para acciones de administracion:
 * asignar/revocar roles y activar/inactivar cuentas. Reemplaza a
 * admin/guardarRolUsuario.jsp y admin/cambiarEstadoUsuario.jsp.
 */
public class UsuarioAdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getServletPath().endsWith("cambiarEstadoUsuario.jsp")) {
            cambiarEstado(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (request.getServletPath().endsWith("guardarRolUsuario.jsp")) {
            guardarRol(request, response);
        }
    }

    private void cambiarEstado(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        int idAdmin = (Integer) request.getSession().getAttribute("idUsuario");
        int idUsuario = Integer.parseInt(request.getParameter("id"));
        String estado = request.getParameter("estado");

        if ("ACTIVO".equals(estado) || "INACTIVO".equals(estado)) {
            try (Connection con = ConexionUtil.abrirConexion();
                 PreparedStatement ps = con.prepareStatement("UPDATE usuario SET estado=? WHERE id_usuario=?")) {
                ps.setString(1, estado);
                ps.setInt(2, idUsuario);
                ps.executeUpdate();
                Utilidades.registrarAuditoria(con, idAdmin, "CAMBIAR_ESTADO_USUARIO", "usuario",
                    "Usuario " + idUsuario + " -> " + estado, request.getRemoteAddr());
            } catch (SQLException ex) { }
        }
        response.sendRedirect(ctx + "/admin/usuarios.jsp?msg=actualizado");
    }

    private void guardarRol(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        int idAdmin = (Integer) request.getSession().getAttribute("idUsuario");
        int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
        String[] roles = request.getParameterValues("roles");

        Connection con = null;
        try {
            con = ConexionUtil.abrirConexion();
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
            Utilidades.registrarAuditoria(con, idAdmin, "CAMBIAR_ROL", "usuario_rol",
                "Actualizó roles del usuario " + idUsuario, request.getRemoteAddr());
        } catch (SQLException ex) {
            ConexionUtil.deshacer(con);
        } finally {
            ConexionUtil.cerrar(con);
        }
        response.sendRedirect(ctx + "/admin/usuarios.jsp?msg=actualizado");
    }
}
