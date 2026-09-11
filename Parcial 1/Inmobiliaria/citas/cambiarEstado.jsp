<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    boolean esAgente = tieneRol(session, "INMOBILIARIA");
    boolean esCliente = tieneRol(session, "CLIENTE");
    int idUsuario = (Integer) session.getAttribute("idUsuario");

    int idCita = Integer.parseInt(request.getParameter("id"));
    String nuevoEstado = request.getParameter("estado");

    java.util.Set<String> permitidos = new java.util.HashSet<>(java.util.Arrays.asList(
        "PENDIENTE","CONFIRMADA","RECHAZADA","REALIZADA","CANCELADA"));

    if (nuevoEstado != null && permitidos.contains(nuevoEstado)) {
        try (Connection con = abrirConexion()) {
            String sql;
            if (esCliente && !esAdmin && !esAgente) {
                // El cliente solo puede cancelar SU PROPIA cita, y solo si esta pendiente
                sql = "UPDATE cita SET estado='CANCELADA' WHERE id_cita=? AND id_cliente=? AND estado='PENDIENTE'";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, idCita);
                    ps.setInt(2, idUsuario);
                    ps.executeUpdate();
                }
            } else if (esAdmin) {
                sql = "UPDATE cita SET estado=? WHERE id_cita=?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, nuevoEstado);
                    ps.setInt(2, idCita);
                    ps.executeUpdate();
                }
            } else if (esAgente) {
                // El agente solo puede cambiar el estado de citas de SUS propiedades
                sql = "UPDATE cita c JOIN propiedad p ON p.id_propiedad=c.id_propiedad " +
                      "SET c.estado=? WHERE c.id_cita=? AND p.id_agente=?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, nuevoEstado);
                    ps.setInt(2, idCita);
                    ps.setInt(3, idUsuario);
                    ps.executeUpdate();
                }
            }
            registrarAuditoria(con, idUsuario, "CAMBIAR_ESTADO_CITA", "cita",
                "Cita " + idCita + " -> " + nuevoEstado, request.getRemoteAddr());
        } catch (SQLException ex) { }
    }
    response.sendRedirect(ctx + "/citas/listar.jsp?msg=actualizada");
%>
