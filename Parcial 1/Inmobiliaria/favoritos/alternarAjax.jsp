<%@ page contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    // Version AJAX de favoritos/alternar.jsp: no redirige, solo responde
    // "AGREGADO" o "QUITADO" en texto plano para que favoritos.js actualice
    // el boton sin recargar la pagina (evita perder la posicion del scroll).
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
    String resultado = "ERROR";

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
            resultado = "QUITADO";
        } else {
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO favorito (id_usuario, id_propiedad) VALUES (?,?)")) {
                ps.setInt(1, idUsuario);
                ps.setInt(2, idPropiedad);
                ps.executeUpdate();
                registrarAuditoria(con, idUsuario, "MARCAR_FAVORITO", "favorito",
                    "Propiedad " + idPropiedad, request.getRemoteAddr());
            }
            resultado = "AGREGADO";
        }
    } catch (SQLException ex) { }
%><%= resultado %>