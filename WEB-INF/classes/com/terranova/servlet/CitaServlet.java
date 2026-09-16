package com.terranova.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.terranova.util.ConexionUtil;
import com.terranova.util.Utilidades;

/**
 * Controlador de la entidad Cita: agendar visita y cambiar su estado.
 * Reemplaza a citas/guardarCita.jsp y citas/cambiarEstado.jsp.
 */
public class CitaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getServletPath().endsWith("cambiarEstado.jsp")) {
            cambiarEstado(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (request.getServletPath().endsWith("guardarCita.jsp")) {
            guardarCita(request, response);
        }
    }

    private void guardarCita(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        int idUsuario = (Integer) request.getSession().getAttribute("idUsuario");

        int idPropiedad = 0;
        try { idPropiedad = Integer.parseInt(request.getParameter("idPropiedad")); } catch (Exception ex) { }
        String fechaHoraStr = request.getParameter("fechaHora");
        String observaciones = request.getParameter("observaciones");

        if (idPropiedad == 0 || fechaHoraStr == null || fechaHoraStr.isEmpty()) {
            response.sendRedirect(ctx + "/citas/agendar.jsp?idPropiedad=" + idPropiedad + "&error=campos_invalidos");
            return;
        }

        try {
            Timestamp fechaHora = Timestamp.valueOf(fechaHoraStr.replace("T", " ") + ":00");
            try (Connection con = ConexionUtil.abrirConexion();
                 PreparedStatement ps = con.prepareStatement(
                     "INSERT INTO cita (id_propiedad, id_cliente, fecha_hora, observaciones) VALUES (?,?,?,?)")) {
                ps.setInt(1, idPropiedad);
                ps.setInt(2, idUsuario);
                ps.setTimestamp(3, fechaHora);
                ps.setString(4, observaciones);
                ps.executeUpdate();
                Utilidades.registrarAuditoria(con, idUsuario, "AGENDAR_CITA", "cita", "Cita sobre propiedad " + idPropiedad, request.getRemoteAddr());
            }
            response.sendRedirect(ctx + "/citas/listar.jsp?msg=agendada");
        } catch (IllegalArgumentException formatoInvalido) {
            response.sendRedirect(ctx + "/citas/agendar.jsp?idPropiedad=" + idPropiedad + "&error=campos_invalidos");
        } catch (SQLIntegrityConstraintViolationException dup) {
            response.sendRedirect(ctx + "/citas/agendar.jsp?idPropiedad=" + idPropiedad + "&error=horario_ocupado");
        } catch (SQLException ex) {
            response.sendRedirect(ctx + "/citas/agendar.jsp?idPropiedad=" + idPropiedad + "&error=campos_invalidos");
        }
    }

    private void cambiarEstado(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
        HttpSession session = request.getSession();
        boolean esAdmin = Utilidades.tieneRol(session, "ADMINISTRADOR");
        boolean esAgente = Utilidades.tieneRol(session, "INMOBILIARIA");
        boolean esCliente = Utilidades.tieneRol(session, "CLIENTE");
        int idUsuario = (Integer) session.getAttribute("idUsuario");

        int idCita = Integer.parseInt(request.getParameter("id"));
        String nuevoEstado = request.getParameter("estado");

        Set<String> permitidos = new HashSet<>(Arrays.asList(
            "PENDIENTE", "CONFIRMADA", "RECHAZADA", "REALIZADA", "CANCELADA"));

        if (nuevoEstado != null && permitidos.contains(nuevoEstado)) {
            try (Connection con = ConexionUtil.abrirConexion()) {
                if (esCliente && !esAdmin && !esAgente) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE cita SET estado='CANCELADA' WHERE id_cita=? AND id_cliente=? AND estado='PENDIENTE'")) {
                        ps.setInt(1, idCita);
                        ps.setInt(2, idUsuario);
                        ps.executeUpdate();
                    }
                } else if (esAdmin) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE cita SET estado=? WHERE id_cita=?")) {
                        ps.setString(1, nuevoEstado);
                        ps.setInt(2, idCita);
                        ps.executeUpdate();
                    }
                } else if (esAgente) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE cita c JOIN propiedad p ON p.id_propiedad=c.id_propiedad " +
                            "SET c.estado=? WHERE c.id_cita=? AND p.id_agente=?")) {
                        ps.setString(1, nuevoEstado);
                        ps.setInt(2, idCita);
                        ps.setInt(3, idUsuario);
                        ps.executeUpdate();
                    }
                }
                Utilidades.registrarAuditoria(con, idUsuario, "CAMBIAR_ESTADO_CITA", "cita",
                    "Cita " + idCita + " -> " + nuevoEstado, request.getRemoteAddr());
            } catch (SQLException ex) { }
        }
        response.sendRedirect(ctx + "/citas/listar.jsp?msg=actualizada");
    }
}
