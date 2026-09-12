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
    String orden      = request.getParameter("orden");
    if (orden == null || orden.isEmpty()) orden = "recientes";

    boolean esCliente = tieneRol(session, "CLIENTE");
    Integer idUsuario = esCliente ? (Integer) session.getAttribute("idUsuario") : null;
    java.util.Set<Integer> misFavoritos = new java.util.HashSet<>();
    if (esCliente) {
        try (Connection con = abrirConexion();
             PreparedStatement ps = con.prepareStatement("SELECT id_propiedad FROM favorito WHERE id_usuario=?")) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) misFavoritos.add(rs.getInt(1)); }
        } catch (SQLException ex) { }
    }
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<div class="row g-4">
<div class="col-lg-3">
    <div class="card shadow-sm filtros-catalogo">
        <div class="card-header"><i class="bi bi-filter"></i> Filtrar propiedades</div>
        <div class="card-body">
            <form method="get" action="<%= ctx %>/catalogo.jsp">
                <input type="hidden" name="orden" value="<%= escapar(orden) %>">
                <div class="mb-3">
                    <label class="form-label small fw-semibold">Buscar</label>
                    <input type="text" class="form-control" name="q" placeholder="Titulo o direccion"
                           value="<%= q != null ? escapar(q) : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label small fw-semibold">Ciudad</label>
                    <select class="form-select" name="idCiudad">
                        <option value="">Cualquiera</option>
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
                <div class="mb-3">
                    <label class="form-label small fw-semibold">Tipo de inmueble</label>
                    <select class="form-select" name="idTipo">
                        <option value="">Cualquiera</option>
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
                <div class="mb-3">
                    <label class="form-label small fw-semibold">Operacion</label>
                    <select class="form-select" name="operacion">
                        <option value="">Venta o arriendo</option>
                        <option value="VENTA" <%= "VENTA".equals(operacion) ? "selected" : "" %>>Venta</option>
                        <option value="ARRIENDO" <%= "ARRIENDO".equals(operacion) ? "selected" : "" %>>Arriendo</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label small fw-semibold">Rango de precio (COP)</label>
                    <div class="d-flex gap-2">
                        <input type="number" class="form-control" name="precioMin" placeholder="Min"
                               value="<%= precioMin != null ? escapar(precioMin) : "" %>">
                        <input type="number" class="form-control" name="precioMax" placeholder="Max"
                               value="<%= precioMax != null ? escapar(precioMax) : "" %>">
                    </div>
                </div>
                <button type="submit" class="btn btn-success w-100"><i class="bi bi-search"></i> Aplicar filtros</button>
                <a href="<%= ctx %>/catalogo.jsp" class="btn btn-outline-secondary w-100 mt-2">Limpiar</a>
            </form>
        </div>
    </div>
</div>

<div class="col-lg-9">
<%
    StringBuilder sql = new StringBuilder(
        "SELECT p.id_propiedad, p.titulo, p.precio, p.operacion, p.estado, p.direccion, p.fecha_publicacion, " +
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
    if ("precio_asc".equals(orden)) sql.append(" ORDER BY p.precio ASC");
    else if ("precio_desc".equals(orden)) sql.append(" ORDER BY p.precio DESC");
    else sql.append(" ORDER BY p.fecha_publicacion DESC");

    java.util.List<java.util.Map<String,Object>> resultados = new java.util.ArrayList<>();
    try (Connection con = abrirConexion();
         PreparedStatement ps = con.prepareStatement(sql.toString())) {
        for (int i = 0; i < parametros.size(); i++) ps.setObject(i + 1, parametros.get(i));
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String,Object> fila = new java.util.HashMap<>();
                fila.put("id", rs.getInt("id_propiedad"));
                fila.put("titulo", rs.getString("titulo"));
                fila.put("precio", rs.getDouble("precio"));
                fila.put("operacion", rs.getString("operacion"));
                fila.put("estado", rs.getString("estado"));
                fila.put("ciudad", rs.getString("ciudad"));
                fila.put("tipo", rs.getString("tipo"));
                fila.put("imagen", rs.getString("imagen"));
                resultados.add(fila);
            }
        }
    } catch (SQLException ex) {
%>
    <div class="alert alert-danger">Error al consultar el catalogo: <%= escapar(ex.getMessage()) %></div>
<%  } %>

<div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
    <span class="resultado-contador"><strong><%= resultados.size() %></strong> propiedad<%= resultados.size() == 1 ? "" : "es" %> encontrada<%= resultados.size() == 1 ? "" : "s" %></span>
    <form method="get" action="<%= ctx %>/catalogo.jsp" class="d-flex align-items-center gap-2">
        <% for (String p : new String[]{"q","idCiudad","idTipo","operacion","precioMin","precioMax"}) {
               String v = request.getParameter(p);
               if (v != null && !v.isEmpty()) { %>
        <input type="hidden" name="<%= p %>" value="<%= escapar(v) %>">
        <% } } %>
        <label class="small text-muted mb-0">Ordenar por</label>
        <select name="orden" class="form-select form-select-sm" style="width:auto;" onchange="this.form.submit()">
            <option value="recientes" <%= "recientes".equals(orden) ? "selected" : "" %>>Mas recientes</option>
            <option value="precio_asc" <%= "precio_asc".equals(orden) ? "selected" : "" %>>Precio: menor a mayor</option>
            <option value="precio_desc" <%= "precio_desc".equals(orden) ? "selected" : "" %>>Precio: mayor a menor</option>
        </select>
    </form>
</div>

<div class="row g-3">
<% if (resultados.isEmpty()) { %>
    <div class="col-12"><p class="text-muted">No se encontraron propiedades con esos filtros.</p></div>
<% }
   for (java.util.Map<String,Object> f : resultados) {
       int idProp = (Integer) f.get("id");
       boolean esFav = misFavoritos.contains(idProp);
%>
    <div class="col-md-6 col-xl-4">
        <div class="card tarjeta-propiedad shadow-sm">
            <div class="tarjeta-img-wrap">
                <img src="<%= escapar((String) f.get("imagen")) %>" class="card-img-top" alt="<%= escapar((String) f.get("tipo")) %>">
                <% if (esCliente) { %>
                <button type="button" class="btn-favorito-card <%= esFav ? "es-favorito" : "" %>"
                        data-id="<%= idProp %>"
                        title="<%= esFav ? "Quitar de favoritos" : "Agregar a favoritos" %>">
                    <i class="bi <%= esFav ? "bi-heart-fill" : "bi-heart" %>"></i>
                </button>
                <% } %>
            </div>
            <div class="card-body">
                <div>
                <span class="badge badge-estado-<%= f.get("estado") %>"><%= f.get("estado") %></span>
                <span class="badge text-bg-secondary"><%= f.get("operacion") %></span>
                </div>
                <h6 class="mt-2 titulo-propiedad"><%= escapar((String) f.get("titulo")) %></h6>
                <p class="text-muted mb-1"><i class="bi bi-geo-alt"></i> <%= escapar((String) f.get("ciudad")) %>
                    &middot; <%= escapar((String) f.get("tipo")) %></p>
                <p class="precio-destacado"><%= formatoCOP((Double) f.get("precio")) %></p>
                <a class="btn btn-outline-success btn-sm w-100"
                   href="<%= ctx %>/detallePropiedad.jsp?id=<%= idProp %>">
                    Ver detalle</a>
            </div>
        </div>
    </div>
<% } %>
</div>
</div>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
