package com.terranova.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Set;
import javax.servlet.http.HttpSession;

/**
 * Helpers de sesion y auditoria para los Servlets del proyecto TerraNova.
 * Replica exactamente la logica de WEB-INF/jspf/utilidadesInmobiliaria.jspf,
 * que sigue usando cualquier JSP de solo-vista por la misma razon explicada
 * en ConexionUtil.
 */
public final class Utilidades {

    private Utilidades() { }

    public static boolean tieneRol(HttpSession sesion, String... rolesPermitidos) {
        if (sesion == null) return false;
        @SuppressWarnings("unchecked")
        Set<String> roles = (Set<String>) sesion.getAttribute("roles");
        if (roles == null) return false;
        for (String r : rolesPermitidos) {
            if (roles.contains(r)) return true;
        }
        return false;
    }

    public static boolean estaAutenticado(HttpSession sesion) {
        return sesion != null && sesion.getAttribute("idUsuario") != null;
    }

    public static void registrarAuditoria(Connection con, Integer idUsuario, String accion,
                                           String tabla, String detalle, String ip) {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO auditoria (id_usuario, accion, tabla_afectada, detalle, ip) VALUES (?,?,?,?,?)")) {
            if (idUsuario != null) ps.setInt(1, idUsuario); else ps.setNull(1, Types.INTEGER);
            ps.setString(2, accion);
            ps.setString(3, tabla);
            ps.setString(4, detalle);
            ps.setString(5, ip);
            ps.executeUpdate();
        } catch (SQLException ignorada) { }
    }
}
