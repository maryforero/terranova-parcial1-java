<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    request.setCharacterEncoding("UTF-8");
    int idAdmin = (Integer) session.getAttribute("idUsuario");

    // Lista blanca de tablas de catálogo permitidas: nunca se concatena
    // un nombre de tabla/columna que venga directo del usuario sin validar.
    java.util.Set<String> tablasPermitidas = new java.util.HashSet<>(
        java.util.Arrays.asList("ciudad", "tipo_propiedad", "caracteristica"));

    String tabla        = request.getParameter("tabla");
    String nombre       = request.getParameter("nombre");
    String departamento = request.getParameter("departamento");

    if (tabla != null && tablasPermitidas.contains(tabla) && nombre != null && !nombre.trim().isEmpty()) {
        String sqlIns = "ciudad".equals(tabla)
            ? "INSERT INTO ciudad (nombre, departamento) VALUES (?, ?)"
            : "INSERT INTO " + tabla + " (nombre) VALUES (?)";
        try (Connection con = abrirConexion();
             PreparedStatement ps = con.prepareStatement(sqlIns)) {
            ps.setString(1, nombre.trim());
            if ("ciudad".equals(tabla)) {
                ps.setString(2, (departamento != null && !departamento.trim().isEmpty()) ? departamento.trim() : "Santander");
            }
            ps.executeUpdate();
            registrarAuditoria(con, idAdmin, "AGREGAR_CATALOGO", tabla, "Agrego '" + nombre.trim() + "'", request.getRemoteAddr());
            response.sendRedirect(ctx + "/admin/catalogos.jsp?msg=agregado");
            return;
        } catch (SQLIntegrityConstraintViolationException dup) {
            response.sendRedirect(ctx + "/admin/catalogos.jsp?error=duplicado");
            return;
        } catch (SQLException ex) { }
    }
    response.sendRedirect(ctx + "/admin/catalogos.jsp");
%>
