<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    request.setCharacterEncoding("UTF-8");
    int idUsuario = (Integer) session.getAttribute("idUsuario");

    int idPropiedad = 0;
    try { idPropiedad = Integer.parseInt(request.getParameter("idPropiedad")); } catch (Exception ex) { }
    String fechaHoraStr = request.getParameter("fechaHora"); // formato datetime-local: yyyy-MM-ddTHH:mm
    String observaciones = request.getParameter("observaciones");

    if (idPropiedad == 0 || fechaHoraStr == null || fechaHoraStr.isEmpty()) {
        response.sendRedirect(ctx + "/citas/agendar.jsp?idPropiedad=" + idPropiedad + "&error=campos_invalidos");
        return;
    }

    try {
        Timestamp fechaHora = Timestamp.valueOf(fechaHoraStr.replace("T", " ") + ":00");
        try (Connection con = abrirConexion();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO cita (id_propiedad, id_cliente, fecha_hora, observaciones) VALUES (?,?,?,?)")) {
            ps.setInt(1, idPropiedad);
            ps.setInt(2, idUsuario);
            ps.setTimestamp(3, fechaHora);
            ps.setString(4, observaciones);
            ps.executeUpdate();
            registrarAuditoria(con, idUsuario, "AGENDAR_CITA", "cita", "Cita sobre propiedad " + idPropiedad, request.getRemoteAddr());
        }
        response.sendRedirect(ctx + "/citas/listar.jsp?msg=agendada");
    } catch (IllegalArgumentException formatoInvalido) {
        response.sendRedirect(ctx + "/citas/agendar.jsp?idPropiedad=" + idPropiedad + "&error=campos_invalidos");
    } catch (SQLIntegrityConstraintViolationException dup) {
        response.sendRedirect(ctx + "/citas/agendar.jsp?idPropiedad=" + idPropiedad + "&error=horario_ocupado");
    } catch (SQLException ex) {
        response.sendRedirect(ctx + "/citas/agendar.jsp?idPropiedad=" + idPropiedad + "&error=campos_invalidos");
    }
%>
