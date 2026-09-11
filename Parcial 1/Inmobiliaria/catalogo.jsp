<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Catalogo de propiedades";

    String idCiudad   = request.getParameter("idCiudad");
    String idTipo     = request.getParameter("idTipo");
    String operacion  = request.getParameter("operacion");
    String precioMin  = request.getParameter("precioMin");
    String precioMax  = request.getParameter("precioMax");
    String q          = request.getParameter("q");
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-3"><i class="bi bi-search"></i> Catalogo de propiedades</h3>

<form class="row g-2 bg-white p-3 rounded-3 shadow-sm mb-4" method="get" action="<%= ctx %>/catalogo.jsp">
    <div class="col-md-3">
        <input type="text" class="form-control" name="q" placeholder="Buscar por titulo o direccion"
               value="<%= q != null ? escapar(q) : "" %>">
    </div>
    <div class="col-md-2">
        <select class="form-select" name="idCiudad">
            <option value="">Ciudad</option>
            <%
                try (Connection con = abrirConexion();
                     PreparedStatement ps = con.prepareStatement("SELECT id_ciudad, nombre FROM ciudad ORDER BY nombre");
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String sel = String.valueOf(rs.getInt("id_ciudad")).equals(idCiudad) ? "selected" : "";
            %>
            <option value="<%= rs.getInt("id_ciudad") %>" <%= sel %>><%= escapar(rs.getString("nombre")) %></option>
            <% } } catch (SQLException ex) { } %>
        </select>
    </div>
    <div class="col-md-2">
        <select class="form-select" name="idTipo">
            <option value="">Tipo</option>
            <%
                try (Connection con = abrirConexion();
                     PreparedStatement ps = con.prepareStatement("SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String sel = String.valueOf(rs.getInt("id_tipo")).equals(idTipo) ? "selected" : "";
            %>
            <option value="<%= rs.getInt("id_tipo") %>" <%= sel %>><%= escapar(rs.getString("nombre")) %></option>
            <% } } catch (SQLException ex) { } %>
        </select>
    </div>
    <div class="col-md-2">
        <select class="form-select" name="operacion">
            <option value="">Venta/Arriendo</option>
            <option value="VENTA" <%= "VENTA".equals(operacion) ? "selected" : "" %>>Venta</option>
            <option value="ARRIENDO" <%= "ARRIENDO".equals(operacion) ? "selected" : "" %>>Arriendo</option>
        </select>
    </div>
    <div class="col-md-1">
        <input type="number" class="form-control" name="precioMin" placeholder="Min"
               value="<%= precioMin != null ? escapar(precioMin) : "" %>">
    </div>
    <div class="col-md-1">
        <input type="number" class="form-control" name="precioMax" placeholder="Max"
               value="<%= precioMax != null ? escapar(precioMax) : "" %>">
    </div>
    <div class="col-md-1 d-grid">
        <button type="submit" class="btn btn-success"><i class="bi bi-filter"></i></button>
    </div>
</form>

<div class="row g-3">
<%
    StringBuilder sql = new StringBuilder(
        "SELECT p.id_propiedad, p.titulo, p.precio, p.operacion, p.estado, p.direccion, " +
        "       c.nombre AS ciudad, t.nombre AS tipo, " +
        "       (SELECT url_imagen FROM imagen_propiedad ip " +
        "          WHERE ip.id_propiedad = p.id_propiedad " +
        "          ORDER BY ip.es_principal DESC, ip.orden ASC LIMIT 1) AS imagen " +
        "FROM propiedad p " +
        "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
        "JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo " +
        "WHERE p.estado IN ('DISPONIBLE','RESERVADO') ");
    java.util.List<Object> parametros = new java.util.ArrayList<>();

    if (idCiudad != null && !idCiudad.isEmpty()) {
        sql.append(" AND p.id_ciudad = ? ");
        parametros.add(Integer.parseInt(idCiudad));
    }
    if (idTipo != null && !idTipo.isEmpty()) {
        sql.append(" AND p.id_tipo = ? ");
        parametros.add(Integer.parseInt(idTipo));
    }
    if (operacion != null && !operacion.isEmpty()) {
        sql.append(" AND p.operacion = ? ");
        parametros.add(operacion);
    }
    if (precioMin != null && !precioMin.isEmpty()) {
        sql.append(" AND p.precio >= ? ");
        parametros.add(Double.parseDouble(precioMin));
    }
    if (precioMax != null && !precioMax.isEmpty()) {
        sql.append(" AND p.precio <= ? ");
        parametros.add(Double.parseDouble(precioMax));
    }
    if (q != null && !q.trim().isEmpty()) {
        sql.append(" AND (p.titulo LIKE ? OR p.direccion LIKE ?) ");
        parametros.add("%" + q.trim() + "%");
        parametros.add("%" + q.trim() + "%");
    }
    sql.append(" ORDER BY p.fecha_publicacion DESC");

    try (Connection con = abrirConexion();
         PreparedStatement ps = con.prepareStatement(sql.toString())) {
        for (int i = 0; i < parametros.size(); i++) {
            ps.setObject(i + 1, parametros.get(i));
        }
        try (ResultSet rs = ps.executeQuery()) {
            boolean alguna = false;
            while (rs.next()) {
                alguna = true;
%>
    <div class="col-md-4">
        <div class="card tarjeta-propiedad shadow-sm">
            <img src="<%= escapar(rs.getString("imagen")) %>" class="card-img-top" alt="Propiedad">
            <div class="card-body">
                <span class="badge badge-estado-<%= rs.getString("estado") %>"><%= rs.getString("estado") %></span>
                <span class="badge text-bg-secondary"><%= rs.getString("operacion") %></span>
                <h6 class="mt-2"><%= escapar(rs.getString("titulo")) %></h6>
                <p class="text-muted mb-1"><i class="bi bi-geo-alt"></i> <%= escapar(rs.getString("ciudad")) %>
                    &middot; <%= escapar(rs.getString("tipo")) %></p>
                <p class="precio-destacado"><%= formatoCOP(rs.getDouble("precio")) %></p>
                <a class="btn btn-outline-success btn-sm w-100"
                   href="<%= ctx %>/detallePropiedad.jsp?id=<%= rs.getInt("id_propiedad") %>">
                    Ver detalle</a>
            </div>
        </div>
    </div>
<%
            }
            if (!alguna) {
%>
    <div class="col-12"><p class="text-muted">No se encontraron propiedades con esos filtros.</p></div>
<%
            }
        }
    } catch (SQLException ex) {
%>
    <div class="col-12"><p class="text-danger">Error al consultar el catalogo: <%= escapar(ex.getMessage()) %></p></div>
<% } %>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
