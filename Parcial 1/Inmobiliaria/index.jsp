<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Inicio";
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<div class="hero-terranova mb-4">
    <div class="row align-items-center">
        <div class="col-lg-7">
            <h1 class="fw-bold">Encuentra el inmueble que estas buscando</h1>
            <p class="lead">TerraNova reune las mejores propiedades en venta y arriendo
                del area metropolitana de Bucaramanga, publicadas por varias
                inmobiliarias aliadas.</p>
        </div>
    </div>
    <form class="row g-2 bg-white p-3 rounded-3 shadow-sm mt-3" method="get"
          action="<%= ctx %>/catalogo.jsp">
        <div class="col-md-3">
            <select class="form-select" name="idCiudad">
                <option value="">Cualquier ciudad</option>
                <%
                    try (Connection con = abrirConexion();
                         PreparedStatement ps = con.prepareStatement(
                             "SELECT id_ciudad, nombre FROM ciudad ORDER BY nombre");
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                %>
                <option value="<%= rs.getInt("id_ciudad") %>"><%= escapar(rs.getString("nombre")) %></option>
                <%
                        }
                    } catch (SQLException ex) {
                %>
                <option value="">(no se pudieron cargar las ciudades)</option>
                <% } %>
            </select>
        </div>
        <div class="col-md-3">
            <select class="form-select" name="idTipo">
                <option value="">Cualquier tipo</option>
                <%
                    try (Connection con = abrirConexion();
                         PreparedStatement ps = con.prepareStatement(
                             "SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                %>
                <option value="<%= rs.getInt("id_tipo") %>"><%= escapar(rs.getString("nombre")) %></option>
                <%
                        }
                    } catch (SQLException ex) {
                %>
                <option value="">(no se pudieron cargar los tipos)</option>
                <% } %>
            </select>
        </div>
        <div class="col-md-3">
            <select class="form-select" name="operacion">
                <option value="">Comprar o arrendar</option>
                <option value="VENTA">Venta</option>
                <option value="ARRIENDO">Arriendo</option>
            </select>
        </div>
        <div class="col-md-3 d-grid">
            <button type="submit" class="btn btn-warning text-dark fw-semibold">
                <i class="bi bi-search"></i> Buscar propiedades</button>
        </div>
    </form>
</div>

<h4 class="mb-3"><i class="bi bi-star-fill text-warning"></i> Propiedades destacadas</h4>
<div class="row g-3">
<%
    String sqlDestacadas =
        "SELECT p.id_propiedad, p.titulo, p.precio, p.operacion, p.estado, " +
        "       c.nombre AS ciudad, t.nombre AS tipo, " +
        "       (SELECT url_imagen FROM imagen_propiedad ip " +
        "          WHERE ip.id_propiedad = p.id_propiedad " +
        "          ORDER BY ip.es_principal DESC, ip.orden ASC LIMIT 1) AS imagen " +
        "FROM propiedad p " +
        "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
        "JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo " +
        "WHERE p.estado = 'DISPONIBLE' " +
        "ORDER BY p.fecha_publicacion DESC LIMIT 6";
    try (Connection con = abrirConexion();
         PreparedStatement ps = con.prepareStatement(sqlDestacadas);
         ResultSet rs = ps.executeQuery()) {
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
    <div class="col-12"><p class="text-muted">Aun no hay propiedades disponibles.</p></div>
<% } } catch (SQLException ex) { %>
    <div class="col-12"><p class="text-danger">No se pudieron cargar las propiedades destacadas.</p></div>
<% } %>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
