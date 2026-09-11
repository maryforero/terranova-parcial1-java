<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
    String volver = request.getParameter("volver");

    try (Connection con = abrirConexion()) {
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
        } else {
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO favorito (id_usuario, id_propiedad) VALUES (?,?)")) {
                ps.setInt(1, idUsuario);
                ps.setInt(2, idPropiedad);
                ps.executeUpdate();
                registrarAuditoria(con, idUsuario, "MARCAR_FAVORITO", "favorito",
                    "Propiedad " + idPropiedad, request.getRemoteAddr());
            }
        }
    } catch (SQLException ex) { }

    if ("detalle".equals(volver)) {
        response.sendRedirect(ctx + "/detallePropiedad.jsp?id=" + idPropiedad);
    } else {
        response.sendRedirect(ctx + "/favoritos/listar.jsp");
    }
%>
