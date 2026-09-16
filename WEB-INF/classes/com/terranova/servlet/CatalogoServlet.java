package com.terranova.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.terranova.util.ConexionUtil;
import com.terranova.util.Utilidades;

/**
 * Controlador de los catalogos del sistema (ciudad, tipo_propiedad,
 * caracteristica). Reemplaza a admin/guardarCatalogo.jsp.
 */
public class CatalogoServlet extends HttpServlet {

    // Lista blanca de tablas de catalogo permitidas: nunca se concatena un
    // nombre de tabla/columna que venga directo del usuario sin validar.
    private static final Set<String> TABLAS_PERMITIDAS =
        new HashSet<>(Arrays.asList("ciudad", "tipo_propiedad", "caracteristica"));

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        int idAdmin = (Integer) request.getSession().getAttribute("idUsuario");

        String tabla        = request.getParameter("tabla");
        String nombre       = request.getParameter("nombre");
        String departamento = request.getParameter("departamento");

        if (tabla != null && TABLAS_PERMITIDAS.contains(tabla) && nombre != null && !nombre.trim().isEmpty()) {
            String sqlIns = "ciudad".equals(tabla)
                ? "INSERT INTO ciudad (nombre, departamento) VALUES (?, ?)"
                : "INSERT INTO " + tabla + " (nombre) VALUES (?)";
            try (Connection con = ConexionUtil.abrirConexion();
                 PreparedStatement ps = con.prepareStatement(sqlIns)) {
                ps.setString(1, nombre.trim());
                if ("ciudad".equals(tabla)) {
                    ps.setString(2, (departamento != null && !departamento.trim().isEmpty()) ? departamento.trim() : "Santander");
                }
                ps.executeUpdate();
                Utilidades.registrarAuditoria(con, idAdmin, "AGREGAR_CATALOGO", tabla, "Agregó '" + nombre.trim() + "'", request.getRemoteAddr());
                response.sendRedirect(ctx + "/admin/catalogos.jsp?msg=agregado");
                return;
            } catch (SQLIntegrityConstraintViolationException dup) {
                response.sendRedirect(ctx + "/admin/catalogos.jsp?error=duplicado");
                return;
            } catch (SQLException ex) { }
        }
        response.sendRedirect(ctx + "/admin/catalogos.jsp");
    }
}
