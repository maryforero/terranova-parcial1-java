package com.terranova.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Types;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.terranova.util.ConexionUtil;
import com.terranova.util.Utilidades;

/**
 * Controlador de la entidad Propiedad (y sus dependientes imagen_propiedad
 * y propiedad_caracteristica): crear/editar, baja logica, galeria de
 * imagenes y caracteristicas N:M. Reemplaza a propiedades/guardar.jsp,
 * baja.jsp, guardarCaracteristicas.jsp, guardarImagen.jsp y
 * eliminarImagen.jsp, cada uno mapeado en web.xml a su ruta original.
 */
public class PropiedadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String ruta = request.getServletPath();
        if (ruta.endsWith("baja.jsp")) {
            baja(request, response);
        } else if (ruta.endsWith("eliminarImagen.jsp")) {
            eliminarImagen(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String ruta = request.getServletPath();
        if (ruta.endsWith("guardar.jsp")) {
            guardar(request, response);
        } else if (ruta.endsWith("guardarCaracteristicas.jsp")) {
            guardarCaracteristicas(request, response);
        } else if (ruta.endsWith("guardarImagen.jsp")) {
            guardarImagen(request, response);
        }
    }

    private void guardar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        HttpSession session = request.getSession();
        boolean esAdmin = Utilidades.tieneRol(session, "ADMINISTRADOR");
        int idUsuario = (Integer) session.getAttribute("idUsuario");

        Integer idPropiedad = null;
        try { idPropiedad = Integer.parseInt(request.getParameter("id")); } catch (Exception ex) { }

        String matricula   = request.getParameter("matricula");
        String titulo      = request.getParameter("titulo");
        String descripcion = request.getParameter("descripcion");
        String direccion   = request.getParameter("direccion");
        String operacion   = request.getParameter("operacion");
        String estado      = request.getParameter("estado");

        int idAgente = idUsuario;
        if (esAdmin) {
            try { idAgente = Integer.parseInt(request.getParameter("idAgente")); } catch (Exception ex) { }
        }

        boolean invalido = matricula == null || matricula.trim().isEmpty()
                || titulo == null || titulo.trim().isEmpty()
                || direccion == null || direccion.trim().isEmpty();

        int idTipo = 0, idCiudad = 0;
        double precio = 0;
        Double areaM2 = null; Integer habitaciones = null, banos = null;
        try {
            idTipo = Integer.parseInt(request.getParameter("idTipo"));
            idCiudad = Integer.parseInt(request.getParameter("idCiudad"));
            precio = Double.parseDouble(request.getParameter("precio"));
            String s;
            s = request.getParameter("areaM2"); if (s != null && !s.isEmpty()) areaM2 = Double.parseDouble(s);
            s = request.getParameter("habitaciones"); if (s != null && !s.isEmpty()) habitaciones = Integer.parseInt(s);
            s = request.getParameter("banos"); if (s != null && !s.isEmpty()) banos = Integer.parseInt(s);
        } catch (NumberFormatException nfe) {
            invalido = true;
        }
        if (precio <= 0) invalido = true;

        String volver = ctx + "/propiedades/formulario.jsp" + (idPropiedad != null ? "?id=" + idPropiedad : "");
        if (invalido) {
            response.sendRedirect(volver + (idPropiedad != null ? "&" : "?") + "error=campos_invalidos");
            return;
        }

        Connection con = null;
        try {
            con = ConexionUtil.abrirConexion();

            int idInmobiliaria;
            try (PreparedStatement psInmob = con.prepareStatement("SELECT id_inmobiliaria FROM usuario WHERE id_usuario = ?")) {
                psInmob.setInt(1, idAgente);
                try (ResultSet rs = psInmob.executeQuery()) {
                    rs.next();
                    idInmobiliaria = rs.getInt("id_inmobiliaria");
                }
            }

            if (idPropiedad == null) {
                String sqlIns = "INSERT INTO propiedad (matricula_inmobiliaria, titulo, descripcion, id_tipo, id_ciudad, " +
                                "id_inmobiliaria, id_agente, direccion, precio, area_m2, habitaciones, banos, operacion, estado) " +
                                "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                try (PreparedStatement ps = con.prepareStatement(sqlIns)) {
                    ps.setString(1, matricula.trim());
                    ps.setString(2, titulo.trim());
                    ps.setString(3, descripcion);
                    ps.setInt(4, idTipo);
                    ps.setInt(5, idCiudad);
                    ps.setInt(6, idInmobiliaria);
                    ps.setInt(7, idAgente);
                    ps.setString(8, direccion.trim());
                    ps.setDouble(9, precio);
                    if (areaM2 != null) ps.setDouble(10, areaM2); else ps.setNull(10, Types.DECIMAL);
                    if (habitaciones != null) ps.setInt(11, habitaciones); else ps.setNull(11, Types.TINYINT);
                    if (banos != null) ps.setInt(12, banos); else ps.setNull(12, Types.TINYINT);
                    ps.setString(13, operacion);
                    ps.setString(14, estado);
                    ps.executeUpdate();
                }
                Utilidades.registrarAuditoria(con, idUsuario, "CREAR_PROPIEDAD", "propiedad", "Publicó " + matricula, request.getRemoteAddr());
            } else {
                String sqlUpd = "UPDATE propiedad SET matricula_inmobiliaria=?, titulo=?, descripcion=?, id_tipo=?, id_ciudad=?, " +
                                "id_agente=?, id_inmobiliaria=?, direccion=?, precio=?, area_m2=?, habitaciones=?, banos=?, operacion=?, estado=? " +
                                "WHERE id_propiedad=?" + (esAdmin ? "" : " AND id_agente=?");
                try (PreparedStatement ps = con.prepareStatement(sqlUpd)) {
                    ps.setString(1, matricula.trim());
                    ps.setString(2, titulo.trim());
                    ps.setString(3, descripcion);
                    ps.setInt(4, idTipo);
                    ps.setInt(5, idCiudad);
                    ps.setInt(6, idAgente);
                    ps.setInt(7, idInmobiliaria);
                    ps.setString(8, direccion.trim());
                    ps.setDouble(9, precio);
                    if (areaM2 != null) ps.setDouble(10, areaM2); else ps.setNull(10, Types.DECIMAL);
                    if (habitaciones != null) ps.setInt(11, habitaciones); else ps.setNull(11, Types.TINYINT);
                    if (banos != null) ps.setInt(12, banos); else ps.setNull(12, Types.TINYINT);
                    ps.setString(13, operacion);
                    ps.setString(14, estado);
                    ps.setInt(15, idPropiedad);
                    if (!esAdmin) ps.setInt(16, idUsuario);
                    ps.executeUpdate();
                }
                Utilidades.registrarAuditoria(con, idUsuario, "EDITAR_PROPIEDAD", "propiedad", "Editó " + matricula, request.getRemoteAddr());
            }

            response.sendRedirect(ctx + "/propiedades/listar.jsp?msg=guardado");
        } catch (SQLIntegrityConstraintViolationException dup) {
            response.sendRedirect(volver + (idPropiedad != null ? "&" : "?") + "error=matricula_duplicada");
        } catch (SQLException ex) {
            response.sendRedirect(volver + (idPropiedad != null ? "&" : "?") + "error=campos_invalidos");
        } finally {
            ConexionUtil.cerrar(con);
        }
    }

    private void baja(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        HttpSession session = request.getSession();
        boolean esAdmin = Utilidades.tieneRol(session, "ADMINISTRADOR");
        int idUsuario = (Integer) session.getAttribute("idUsuario");
        Integer idPropiedad = null;
        try { idPropiedad = Integer.parseInt(request.getParameter("id")); } catch (Exception ex) { }

        if (idPropiedad != null) {
            String sql = "UPDATE propiedad SET estado='INACTIVO' WHERE id_propiedad=?" + (esAdmin ? "" : " AND id_agente=?");
            try (Connection con = ConexionUtil.abrirConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, idPropiedad);
                if (!esAdmin) ps.setInt(2, idUsuario);
                ps.executeUpdate();
                Utilidades.registrarAuditoria(con, idUsuario, "BAJA_PROPIEDAD", "propiedad", "Inactivó propiedad id=" + idPropiedad, request.getRemoteAddr());
            } catch (SQLException ex) { }
        }
        response.sendRedirect(ctx + "/propiedades/listar.jsp?msg=baja");
    }

    private void guardarCaracteristicas(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        HttpSession session = request.getSession();
        boolean esAdmin = Utilidades.tieneRol(session, "ADMINISTRADOR");
        int idUsuario = (Integer) session.getAttribute("idUsuario");
        int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
        String[] seleccionadas = request.getParameterValues("caracteristicas");

        Connection con = null;
        try {
            con = ConexionUtil.abrirConexion();

            String sqlDueno = "SELECT COUNT(*) FROM propiedad WHERE id_propiedad=?" + (esAdmin ? "" : " AND id_agente=?");
            try (PreparedStatement ps = con.prepareStatement(sqlDueno)) {
                ps.setInt(1, idPropiedad);
                if (!esAdmin) ps.setInt(2, idUsuario);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    if (rs.getInt(1) == 0) { response.sendRedirect(ctx + "/propiedades/listar.jsp"); return; }
                }
            }

            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement("DELETE FROM propiedad_caracteristica WHERE id_propiedad=?")) {
                ps.setInt(1, idPropiedad);
                ps.executeUpdate();
            }
            if (seleccionadas != null) {
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES (?,?)")) {
                    for (String idc : seleccionadas) {
                        ps.setInt(1, idPropiedad);
                        ps.setInt(2, Integer.parseInt(idc));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }
            con.commit();
        } catch (SQLException ex) {
            ConexionUtil.deshacer(con);
        } finally {
            ConexionUtil.cerrar(con);
        }

        response.sendRedirect(ctx + "/propiedades/listar.jsp?msg=caracteristicas");
    }

    private void guardarImagen(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        HttpSession session = request.getSession();
        boolean esAdmin = Utilidades.tieneRol(session, "ADMINISTRADOR");
        int idUsuario = (Integer) session.getAttribute("idUsuario");

        int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
        String urlImagen = request.getParameter("urlImagen");
        boolean esPrincipal = "1".equals(request.getParameter("esPrincipal"));

        try (Connection con = ConexionUtil.abrirConexion()) {
            String sqlDueno = "SELECT COUNT(*) FROM propiedad WHERE id_propiedad=?" + (esAdmin ? "" : " AND id_agente=?");
            try (PreparedStatement ps = con.prepareStatement(sqlDueno)) {
                ps.setInt(1, idPropiedad);
                if (!esAdmin) ps.setInt(2, idUsuario);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    if (rs.getInt(1) == 0) {
                        response.sendRedirect(ctx + "/propiedades/listar.jsp");
                        return;
                    }
                }
            }

            if (esPrincipal) {
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE imagen_propiedad SET es_principal=0 WHERE id_propiedad=?")) {
                    ps.setInt(1, idPropiedad);
                    ps.executeUpdate();
                }
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO imagen_propiedad (id_propiedad, url_imagen, es_principal, orden) " +
                    "VALUES (?, ?, ?, (SELECT tmp FROM (SELECT COALESCE(MAX(orden),0)+1 AS tmp FROM imagen_propiedad WHERE id_propiedad=?) x))")) {
                ps.setInt(1, idPropiedad);
                ps.setString(2, urlImagen != null ? urlImagen.trim() : "");
                ps.setBoolean(3, esPrincipal);
                ps.setInt(4, idPropiedad);
                ps.executeUpdate();
            }
        } catch (SQLException ex) { }

        response.sendRedirect(ctx + "/propiedades/imagenes.jsp?id=" + idPropiedad);
    }

    private void eliminarImagen(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        HttpSession session = request.getSession();
        boolean esAdmin = Utilidades.tieneRol(session, "ADMINISTRADOR");
        int idUsuario = (Integer) session.getAttribute("idUsuario");
        int idImagen = Integer.parseInt(request.getParameter("idImagen"));
        int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));

        String sql = "DELETE ip FROM imagen_propiedad ip JOIN propiedad p ON p.id_propiedad = ip.id_propiedad " +
                     "WHERE ip.id_imagen=? AND ip.id_propiedad=?" + (esAdmin ? "" : " AND p.id_agente=?");
        try (Connection con = ConexionUtil.abrirConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idImagen);
            ps.setInt(2, idPropiedad);
            if (!esAdmin) ps.setInt(3, idUsuario);
            ps.executeUpdate();
        } catch (SQLException ex) { }

        response.sendRedirect(ctx + "/propiedades/imagenes.jsp?id=" + idPropiedad);
    }
}
