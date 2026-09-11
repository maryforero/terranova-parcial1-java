<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    boolean esAdmin = tieneRol(session, "ADMINISTRADOR");
    int idUsuario = (Integer) session.getAttribute("idUsuario");

    Integer idPropiedad = null;
    try { idPropiedad = Integer.parseInt(request.getParameter("id")); } catch (Exception ex) { }
    boolean esEdicion = idPropiedad != null;
    String tituloPagina = esEdicion ? "Editar propiedad" : "Publicar propiedad";

    // Valores por defecto (creacion) o cargados (edicion)
    String matricula = "", titulo = "", descripcion = "", direccion = "", operacion = "VENTA", estado = "DISPONIBLE";
    int idTipoSel = 0, idCiudadSel = 0, idAgenteSel = idUsuario;
    double precio = 0; Double areaM2 = null; Integer habitaciones = null, banos = null;

    if (esEdicion) {
        String sqlCarga = "SELECT * FROM propiedad WHERE id_propiedad = ?" + (esAdmin ? "" : " AND id_agente = ?");
        try (Connection con = abrirConexion(); PreparedStatement ps = con.prepareStatement(sqlCarga)) {
            ps.setInt(1, idPropiedad);
            if (!esAdmin) ps.setInt(2, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    matricula = rs.getString("matricula_inmobiliaria");
                    titulo = rs.getString("titulo");
                    descripcion = rs.getString("descripcion");
                    direccion = rs.getString("direccion");
                    operacion = rs.getString("operacion");
                    estado = rs.getString("estado");
                    idTipoSel = rs.getInt("id_tipo");
                    idCiudadSel = rs.getInt("id_ciudad");
                    idAgenteSel = rs.getInt("id_agente");
                    precio = rs.getDouble("precio");
                    if (rs.getObject("area_m2") != null) areaM2 = rs.getDouble("area_m2");
                    if (rs.getObject("habitaciones") != null) habitaciones = rs.getInt("habitaciones");
                    if (rs.getObject("banos") != null) banos = rs.getInt("banos");
                } else {
                    esEdicion = false; // no encontrada o no es del agente -> tratar como no encontrada
                    idPropiedad = null;
                }
            }
        } catch (SQLException ex) { }
    }
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-3"><i class="bi bi-house-add"></i> <%= tituloPagina %></h3>

<%
    String errorForm = request.getParameter("error");
    if ("matricula_duplicada".equals(errorForm)) {
%>
<div class="alert alert-danger">Esa matricula inmobiliaria ya esta registrada en otra propiedad.</div>
<% } else if ("campos_invalidos".equals(errorForm)) { %>
<div class="alert alert-danger">Revisa los campos: hay datos obligatorios, numericos o de precio invalidos.</div>
<% } %>

<form method="post" action="<%= ctx %>/propiedades/guardar.jsp" data-validar novalidate>
    <% if (idPropiedad != null) { %><input type="hidden" name="id" value="<%= idPropiedad %>"><% } %>
    <div class="row g-3">
        <div class="col-md-4">
            <label class="form-label">Matricula inmobiliaria</label>
            <input type="text" name="matricula" class="form-control" required value="<%= escapar(matricula) %>">
            <div class="invalid-feedback"></div>
        </div>
        <div class="col-md-8">
            <label class="form-label">Titulo</label>
            <input type="text" name="titulo" class="form-control" required value="<%= escapar(titulo) %>">
            <div class="invalid-feedback"></div>
        </div>
        <div class="col-12">
            <label class="form-label">Descripcion</label>
            <textarea name="descripcion" class="form-control" rows="3"><%= escapar(descripcion) %></textarea>
        </div>
        <div class="col-md-4">
            <label class="form-label">Direccion</label>
            <input type="text" name="direccion" class="form-control" required value="<%= escapar(direccion) %>">
            <div class="invalid-feedback"></div>
        </div>
        <div class="col-md-4">
            <label class="form-label">Ciudad</label>
            <select name="idCiudad" class="form-select" required>
                <% try (Connection con = abrirConexion();
                        PreparedStatement ps = con.prepareStatement("SELECT id_ciudad, nombre FROM ciudad ORDER BY nombre");
                        ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String sel = rs.getInt("id_ciudad") == idCiudadSel ? "selected" : ""; %>
                <option value="<%= rs.getInt("id_ciudad") %>" <%= sel %>><%= escapar(rs.getString("nombre")) %></option>
                <% } } catch (SQLException ex) { } %>
            </select>
        </div>
        <div class="col-md-4">
            <label class="form-label">Tipo de propiedad</label>
            <select name="idTipo" class="form-select" required>
                <% try (Connection con = abrirConexion();
                        PreparedStatement ps = con.prepareStatement("SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
                        ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String sel = rs.getInt("id_tipo") == idTipoSel ? "selected" : ""; %>
                <option value="<%= rs.getInt("id_tipo") %>" <%= sel %>><%= escapar(rs.getString("nombre")) %></option>
                <% } } catch (SQLException ex) { } %>
            </select>
        </div>

        <div class="col-md-3">
            <label class="form-label">Precio (COP)</label>
            <input type="number" name="precio" class="form-control" data-tipo="precio" required
                   value="<%= precio > 0 ? precio : "" %>">
            <div class="invalid-feedback"></div>
        </div>
        <div class="col-md-3">
            <label class="form-label">Area (m2)</label>
            <input type="number" step="0.01" name="areaM2" class="form-control" value="<%= areaM2 != null ? areaM2 : "" %>">
        </div>
        <div class="col-md-3">
            <label class="form-label">Habitaciones</label>
            <input type="number" name="habitaciones" class="form-control" value="<%= habitaciones != null ? habitaciones : "" %>">
        </div>
        <div class="col-md-3">
            <label class="form-label">Banos</label>
            <input type="number" name="banos" class="form-control" value="<%= banos != null ? banos : "" %>">
        </div>

        <div class="col-md-4">
            <label class="form-label">Operacion</label>
            <select name="operacion" class="form-select">
                <option value="VENTA" <%= "VENTA".equals(operacion) ? "selected" : "" %>>Venta</option>
                <option value="ARRIENDO" <%= "ARRIENDO".equals(operacion) ? "selected" : "" %>>Arriendo</option>
            </select>
        </div>
        <div class="col-md-4">
            <label class="form-label">Estado</label>
            <select name="estado" class="form-select">
                <% for (String e : new String[]{"DISPONIBLE","RESERVADO","VENDIDO","ARRENDADO","INACTIVO"}) { %>
                <option value="<%= e %>" <%= e.equals(estado) ? "selected" : "" %>><%= e %></option>
                <% } %>
            </select>
        </div>
        <% if (esAdmin) { %>
        <div class="col-md-4">
            <label class="form-label">Agente responsable</label>
            <select name="idAgente" class="form-select">
                <% try (Connection con = abrirConexion();
                        PreparedStatement ps = con.prepareStatement(
                            "SELECT u.id_usuario, pf.nombres, pf.apellidos, i.nombre AS inmob " +
                            "FROM usuario u JOIN perfil pf ON pf.id_usuario=u.id_usuario " +
                            "JOIN usuario_rol ur ON ur.id_usuario=u.id_usuario JOIN rol r ON r.id_rol=ur.id_rol " +
                            "JOIN inmobiliaria i ON i.id_inmobiliaria=u.id_inmobiliaria " +
                            "WHERE r.nombre='INMOBILIARIA' ORDER BY pf.nombres");
                        ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String sel = rs.getInt("id_usuario") == idAgenteSel ? "selected" : ""; %>
                <option value="<%= rs.getInt("id_usuario") %>" <%= sel %>>
                    <%= escapar(rs.getString("nombres")) %> <%= escapar(rs.getString("apellidos")) %>
                    (<%= escapar(rs.getString("inmob")) %>)</option>
                <% } } catch (SQLException ex) { } %>
            </select>
        </div>
        <% } %>
    </div>
    <button type="submit" class="btn btn-success mt-4"><i class="bi bi-check-circle"></i> Guardar</button>
    <a class="btn btn-outline-secondary mt-4" href="<%= ctx %>/propiedades/listar.jsp">Cancelar</a>
</form>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
