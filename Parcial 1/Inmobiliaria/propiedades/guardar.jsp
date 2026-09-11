<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    request.setCharacterEncoding("UTF-8");
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    int idUsuario = (Integer) session.getAttribute("idUsuario");

    Integer idPropiedad = null;
    try { idPropiedad = Integer.parseInt(request.getParameter("id")); } catch (Exception ex) { }

    String matricula   = request.getParameter("matricula");
    String titulo      = request.getParameter("titulo");
    String descripcion = request.getParameter("descripcion");
    String direccion   = request.getParameter("direccion");
    String operacion   = request.getParameter("operacion");
    String estado      = request.getParameter("estado");

    int idAgente = idUsuario;
    if (esAdmin) {
        try { idAgente = Integer.parseInt(request.getParameter("idAgente")); } catch (Exception ex) { }
    }

    boolean invalido = matricula == null || matricula.trim().isEmpty()
            || titulo == null || titulo.trim().isEmpty()
            || direccion == null || direccion.trim().isEmpty();

    int idTipo = 0, idCiudad = 0;
    double precio = 0;
    Double areaM2 = null; Integer habitaciones = null, banos = null;
    try {
        idTipo = Integer.parseInt(request.getParameter("idTipo"));
        idCiudad = Integer.parseInt(request.getParameter("idCiudad"));
        precio = Double.parseDouble(request.getParameter("precio"));
        String s;
        s = request.getParameter("areaM2"); if (s != null && !s.isEmpty()) areaM2 = Double.parseDouble(s);
        s = request.getParameter("habitaciones"); if (s != null && !s.isEmpty()) habitaciones = Integer.parseInt(s);
        s = request.getParameter("banos"); if (s != null && !s.isEmpty()) banos = Integer.parseInt(s);
    } catch (NumberFormatException nfe) {
        invalido = true;
    }
    if (precio <= 0) invalido = true;

    String volver = ctx + "/propiedades/formulario.jsp" + (idPropiedad != null ? "?id=" + idPropiedad : "");
    if (invalido) {
        response.sendRedirect(volver + (idPropiedad != null ? "&" : "?") + "error=campos_invalidos");
        return;
    }

    Connection con = null;
    try {
        con = abrirConexion();

        int idInmobiliaria;
        try (PreparedStatement psInmob = con.prepareStatement("SELECT id_inmobiliaria FROM usuario WHERE id_usuario = ?")) {
            psInmob.setInt(1, idAgente);
            try (ResultSet rs = psInmob.executeQuery()) {
                rs.next();
                idInmobiliaria = rs.getInt("id_inmobiliaria");
            }
        }

        if (idPropiedad == null) {
            String sqlIns = "INSERT INTO propiedad (matricula_inmobiliaria, titulo, descripcion, id_tipo, id_ciudad, " +
                            "id_inmobiliaria, id_agente, direccion, precio, area_m2, habitaciones, banos, operacion, estado) " +
                            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
            try (PreparedStatement ps = con.prepareStatement(sqlIns)) {
                ps.setString(1, matricula.trim());
                ps.setString(2, titulo.trim());
                ps.setString(3, descripcion);
                ps.setInt(4, idTipo);
                ps.setInt(5, idCiudad);
                ps.setInt(6, idInmobiliaria);
                ps.setInt(7, idAgente);
                ps.setString(8, direccion.trim());
                ps.setDouble(9, precio);
                if (areaM2 != null) ps.setDouble(10, areaM2); else ps.setNull(10, Types.DECIMAL);
                if (habitaciones != null) ps.setInt(11, habitaciones); else ps.setNull(11, Types.TINYINT);
                if (banos != null) ps.setInt(12, banos); else ps.setNull(12, Types.TINYINT);
                ps.setString(13, operacion);
                ps.setString(14, estado);
                ps.executeUpdate();
            }
            registrarAuditoria(con, idUsuario, "CREAR_PROPIEDAD", "propiedad", "Publico " + matricula, request.getRemoteAddr());
        } else {
            String sqlUpd = "UPDATE propiedad SET matricula_inmobiliaria=?, titulo=?, descripcion=?, id_tipo=?, id_ciudad=?, " +
                            "id_agente=?, id_inmobiliaria=?, direccion=?, precio=?, area_m2=?, habitaciones=?, banos=?, operacion=?, estado=? " +
                            "WHERE id_propiedad=?" + (esAdmin ? "" : " AND id_agente=?");
            try (PreparedStatement ps = con.prepareStatement(sqlUpd)) {
                ps.setString(1, matricula.trim());
                ps.setString(2, titulo.trim());
                ps.setString(3, descripcion);
                ps.setInt(4, idTipo);
                ps.setInt(5, idCiudad);
                ps.setInt(6, idAgente);
                ps.setInt(7, idInmobiliaria);
                ps.setString(8, direccion.trim());
                ps.setDouble(9, precio);
                if (areaM2 != null) ps.setDouble(10, areaM2); else ps.setNull(10, Types.DECIMAL);
                if (habitaciones != null) ps.setInt(11, habitaciones); else ps.setNull(11, Types.TINYINT);
                if (banos != null) ps.setInt(12, banos); else ps.setNull(12, Types.TINYINT);
                ps.setString(13, operacion);
                ps.setString(14, estado);
                ps.setInt(15, idPropiedad);
                if (!esAdmin) ps.setInt(16, idUsuario);
                ps.executeUpdate();
            }
            registrarAuditoria(con, idUsuario, "EDITAR_PROPIEDAD", "propiedad", "Edito " + matricula, request.getRemoteAddr());
        }

        response.sendRedirect(ctx + "/propiedades/listar.jsp?msg=guardado");
    } catch (SQLIntegrityConstraintViolationException dup) {
        response.sendRedirect(volver + (idPropiedad != null ? "&" : "?") + "error=matricula_duplicada");
    } catch (SQLException ex) {
        response.sendRedirect(volver + (idPropiedad != null ? "&" : "?") + "error=campos_invalidos");
    } finally {
        cerrar(con);
    }
%>
