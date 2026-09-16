package com.terranova.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.terranova.util.ConexionUtil;
import com.terranova.util.Utilidades;

/**
 * Controlador de la entidad Favorito. Reemplaza a
 * favoritos/alternarAjax.jsp: responde texto plano "AGREGADO"/"QUITADO"/
 * "ERROR" (sin redirect) para que js/favoritos.js actualice el boton por
 * AJAX sin recargar la pagina.
 */
public class FavoritoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain; charset=UTF-8");
        int idUsuario = (Integer) request.getSession().getAttribute("idUsuario");
        int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
        String resultado = "ERROR";

        try (Connection con = ConexionUtil.abrirConexion()) {
            boolean existe;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM favorito WHERE id_usuario=? AND id_propiedad=?")) {
                ps.setInt(1, idUsuario);
                ps.setInt(2, idPropiedad);
                try (ResultSet rs = ps.executeQuery()) { rs.next(); existe = rs.getInt(1) > 0; }
            }
            if (existe) {
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM favorito WHERE id_usuario=? AND id_propiedad=?")) {
                    ps.setInt(1, idUsuario);
                    ps.setInt(2, idPropiedad);
                    ps.executeUpdate();
                }
                resultado = "QUITADO";
            } else {
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO favorito (id_usuario, id_propiedad) VALUES (?,?)")) {
                    ps.setInt(1, idUsuario);
                    ps.setInt(2, idPropiedad);
                    ps.executeUpdate();
                    Utilidades.registrarAuditoria(con, idUsuario, "MARCAR_FAVORITO", "favorito",
                        "Propiedad " + idPropiedad, request.getRemoteAddr());
                }
                resultado = "AGREGADO";
            }
        } catch (SQLException ex) { }

        PrintWriter out = response.getWriter();
        out.print(resultado);
    }
}
