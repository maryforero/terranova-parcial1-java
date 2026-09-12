<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
    String volver = request.getParameter("volver");

    boolean quedoFavorito = false;
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
            quedoFavorito = false;
        } else {
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO favorito (id_usuario, id_propiedad) VALUES (?,?)")) {
                ps.setInt(1, idUsuario);
                ps.setInt(2, idPropiedad);
                ps.executeUpdate();
                registrarAuditoria(con, idUsuario, "MARCAR_FAVORITO", "favorito",
                    "Propiedad " + idPropiedad, request.getRemoteAddr());
            }
            quedoFavorito = true;
        }
    } catch (SQLException ex) { }

    String mensaje = quedoFavorito ? "favorito_agregado" : "favorito_quitado";

    String destino;
    if ("detalle".equals(volver)) {
        destino = ctx + "/detallePropiedad.jsp?id=" + idPropiedad;
    } else {
        // Vuelve a la pagina desde donde se hizo clic (catalogo con sus filtros,
        // inicio, etc.) en vez de mandar siempre a "Mis favoritos": asi el
        // corazon funciona igual de bien desde una tarjeta del catalogo.
        String referer = request.getHeader("Referer");
        if (referer != null && referer.contains(request.getContextPath())) {
            destino = referer;
        } else {
            destino = ctx + "/favoritos/listar.jsp";
        }
    }
    destino += (destino.contains("?") ? "&" : "?") + "msg=" + mensaje;

    response.sendRedirect(destino);
%>
