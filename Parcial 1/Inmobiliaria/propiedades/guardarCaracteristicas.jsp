<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    request.setCharacterEncoding("UTF-8");
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
    String[] seleccionadas = request.getParameterValues("caracteristicas");

    Connection con = null;
    try {
        con = abrirConexion();

        String sqlDueno = "SELECT COUNT(*) FROM propiedad WHERE id_propiedad=?" + (esAdmin ? "" : " AND id_agente=?");
        try (PreparedStatement ps = con.prepareStatement(sqlDueno)) {
            ps.setInt(1, idPropiedad);
            if (!esAdmin) ps.setInt(2, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                if (rs.getInt(1) == 0) { response.sendRedirect(ctx + "/propiedades/listar.jsp"); return; }
            }
        }

        con.setAutoCommit(false);
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM propiedad_caracteristica WHERE id_propiedad=?")) {
            ps.setInt(1, idPropiedad);
            ps.executeUpdate();
        }
        if (seleccionadas != null) {
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES (?,?)")) {
                for (String idc : seleccionadas) {
                    ps.setInt(1, idPropiedad);
                    ps.setInt(2, Integer.parseInt(idc));
                    ps.addBatch();
                }
                ps.executeBatch();
            }
        }
        con.commit();
    } catch (SQLException ex) {
        deshacer(con);
    } finally {
        cerrar(con);
    }

    response.sendRedirect(ctx + "/propiedades/listar.jsp?msg=caracteristicas");
%>
