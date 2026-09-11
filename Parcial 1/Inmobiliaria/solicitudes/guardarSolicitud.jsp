<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    request.setCharacterEncoding("UTF-8");
    int idUsuario = (Integer) session.getAttribute("idUsuario");

    int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
    String tipo = request.getParameter("tipo");
    String observaciones = request.getParameter("observaciones");

    if (!"COMPRA".equals(tipo) && !"ARRIENDO".equals(tipo)) tipo = "COMPRA";

    int idSolicitud = 0;
    try (Connection con = abrirConexion();
         PreparedStatement ps = con.prepareStatement(
             "INSERT INTO solicitud (id_propiedad, id_cliente, tipo, observaciones) VALUES (?,?,?,?)",
             Statement.RETURN_GENERATED_KEYS)) {
        ps.setInt(1, idPropiedad);
        ps.setInt(2, idUsuario);
        ps.setString(3, tipo);
        ps.setString(4, observaciones);
        ps.executeUpdate();
        try (ResultSet keys = ps.getGeneratedKeys()) { keys.next(); idSolicitud = keys.getInt(1); }
        registrarAuditoria(con, idUsuario, "RADICAR_SOLICITUD", "solicitud",
            "Solicitud " + tipo + " propiedad " + idPropiedad, request.getRemoteAddr());
    } catch (SQLException ex) {
        response.sendRedirect(ctx + "/solicitudes/radicar.jsp?idPropiedad=" + idPropiedad + "&error=1");
        return;
    }

    response.sendRedirect(ctx + "/solicitudes/subirDocumento.jsp?id=" + idSolicitud);
%>
