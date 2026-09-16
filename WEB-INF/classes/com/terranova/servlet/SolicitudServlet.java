package com.terranova.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.terranova.util.ConexionUtil;
import com.terranova.util.Utilidades;

/**
 * Controlador de la entidad Solicitud (y su dependiente documento_solicitud):
 * radicar, cambiar estado y subir documentos. Reemplaza a
 * solicitudes/guardarSolicitud.jsp, solicitudes/cambiarEstado.jsp y
 * solicitudes/subirDocumento.jsp.
 *
 * Caso especial: subirDocumento.jsp mezclaba POST (insertar documento) y
 * GET (listar documentos + formulario) en un mismo archivo. Aqui el POST
 * se maneja en este Servlet y el GET reenvia (forward) a la vista pura
 * solicitudes/subirDocumentoVista.jsp, que quedo con el HTML que antes
 * tenia la segunda mitad de ese archivo.
 */
public class SolicitudServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String ruta = request.getServletPath();
        if (ruta.endsWith("cambiarEstado.jsp")) {
            cambiarEstado(request, response);
        } else if (ruta.endsWith("subirDocumento.jsp")) {
            mostrarDocumentos(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String ruta = request.getServletPath();
        if (ruta.endsWith("guardarSolicitud.jsp")) {
            guardarSolicitud(request, response);
        } else if (ruta.endsWith("subirDocumento.jsp")) {
            subirDocumento(request, response);
        }
    }

    private void guardarSolicitud(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        int idUsuario = (Integer) request.getSession().getAttribute("idUsuario");

        int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
        String tipo = request.getParameter("tipo");
        String observaciones = request.getParameter("observaciones");

        if (!"COMPRA".equals(tipo) && !"ARRIENDO".equals(tipo)) tipo = "COMPRA";

        int idSolicitud = 0;
        try (Connection con = ConexionUtil.abrirConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO solicitud (id_propiedad, id_cliente, tipo, observaciones) VALUES (?,?,?,?)",
                 Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, idPropiedad);
            ps.setInt(2, idUsuario);
            ps.setString(3, tipo);
            ps.setString(4, observaciones);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) { keys.next(); idSolicitud = keys.getInt(1); }
            Utilidades.registrarAuditoria(con, idUsuario, "RADICAR_SOLICITUD", "solicitud",
                "Solicitud " + tipo + " propiedad " + idPropiedad, request.getRemoteAddr());
        } catch (SQLException ex) {
            response.sendRedirect(ctx + "/solicitudes/radicar.jsp?idPropiedad=" + idPropiedad + "&error=1");
            return;
        }

        response.sendRedirect(ctx + "/solicitudes/subirDocumento.jsp?id=" + idSolicitud);
    }

    private void cambiarEstado(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        HttpSession session = request.getSession();
        boolean esAdmin = Utilidades.tieneRol(session, "ADMINISTRADOR");
        int idUsuario = (Integer) session.getAttribute("idUsuario");

        int idSolicitud = Integer.parseInt(request.getParameter("id"));
        String nuevoEstado = request.getParameter("estado");
        Set<String> permitidos = new HashSet<>(Arrays.asList(
            "PENDIENTE", "EN_REVISION", "APROBADA", "RECHAZADA"));

        if (nuevoEstado != null && permitidos.contains(nuevoEstado)) {
            String sql = "UPDATE solicitud s JOIN propiedad p ON p.id_propiedad = s.id_propiedad " +
                         "SET s.estado=? WHERE s.id_solicitud=?" + (esAdmin ? "" : " AND p.id_agente=?");
            try (Connection con = ConexionUtil.abrirConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, nuevoEstado);
                ps.setInt(2, idSolicitud);
                if (!esAdmin) ps.setInt(3, idUsuario);
                ps.executeUpdate();
                Utilidades.registrarAuditoria(con, idUsuario, "CAMBIAR_ESTADO_SOLICITUD", "solicitud",
                    "Solicitud " + idSolicitud + " -> " + nuevoEstado, request.getRemoteAddr());
            } catch (SQLException ex) { }
        }
        response.sendRedirect(ctx + "/solicitudes/listar.jsp");
    }

    private void subirDocumento(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int idUsuario = (Integer) request.getSession().getAttribute("idUsuario");
        int idSolicitud = Integer.parseInt(request.getParameter("id"));

        boolean esDueno = false;
        try (Connection con = ConexionUtil.abrirConexion();
             PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM solicitud WHERE id_solicitud=? AND id_cliente=?")) {
            ps.setInt(1, idSolicitud);
            ps.setInt(2, idUsuario);
            try (ResultSet rs = ps.executeQuery()) { rs.next(); esDueno = rs.getInt(1) > 0; }
        } catch (SQLException ex) { }

        if (esDueno) {
            String nombreDoc = request.getParameter("nombreDocumento");
            String urlArchivo = request.getParameter("urlArchivo");
            if (nombreDoc != null && !nombreDoc.trim().isEmpty() && urlArchivo != null && !urlArchivo.trim().isEmpty()) {
                try (Connection con = ConexionUtil.abrirConexion();
                     PreparedStatement ps = con.prepareStatement(
                         "INSERT INTO documento_solicitud (id_solicitud, nombre_documento, url_archivo) VALUES (?,?,?)")) {
                    ps.setInt(1, idSolicitud);
                    ps.setString(2, nombreDoc.trim());
                    ps.setString(3, urlArchivo.trim());
                    ps.executeUpdate();
                } catch (SQLException ex) { }
            }
        }
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        response.sendRedirect(ctx + "/solicitudes/subirDocumento.jsp?id=" + idSolicitud);
    }

    private void mostrarDocumentos(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        RequestDispatcher rd = request.getRequestDispatcher(
            "/Parcial 1/Inmobiliaria/solicitudes/subirDocumentoVista.jsp");
        rd.forward(request, response);
    }
}
