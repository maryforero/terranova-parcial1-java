<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    request.setCharacterEncoding("UTF-8");
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    int idUsuario = (Integer) session.getAttribute("idUsuario");

    int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
    String urlImagen = request.getParameter("urlImagen");
    boolean esPrincipal = "1".equals(request.getParameter("esPrincipal"));

    try (Connection con = abrirConexion()) {
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
%>
