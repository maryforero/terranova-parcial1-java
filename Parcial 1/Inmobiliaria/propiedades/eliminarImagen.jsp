<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    int idImagen = Integer.parseInt(request.getParameter("idImagen"));
    int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));

    String sql = "DELETE ip FROM imagen_propiedad ip JOIN propiedad p ON p.id_propiedad = ip.id_propiedad " +
                 "WHERE ip.id_imagen=? AND ip.id_propiedad=?" + (esAdmin ? "" : " AND p.id_agente=?");
    try (Connection con = abrirConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, idImagen);
        ps.setInt(2, idPropiedad);
        if (!esAdmin) ps.setInt(3, idUsuario);
        ps.executeUpdate();
    } catch (SQLException ex) { }

    response.sendRedirect(ctx + "/propiedades/imagenes.jsp?id=" + idPropiedad);
%>
