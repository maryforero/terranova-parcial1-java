<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Inicio";

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

<!-- ================= Hero + buscador rapido ================= -->
<div class="hero-terranova mb-4">
    <div class="container-inner">
    <div class="row align-items-center">
        <div class="col-lg-8">
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
            <button type="submit" class="btn btn-warning fw-semibold">
                <i class="bi bi-search"></i> Buscar propiedades</button>
        </div>
    </form>
    </div>
</div>

<!-- ================= Estadisticas ================= -->
<div class="stats-strip mb-5">
    <div class="row g-0 text-center">
    <%
        String[][] stats = {
            {"SELECT COUNT(*) FROM propiedad WHERE estado <> 'INACTIVO'", "Propiedades publicadas", "bi-houses"},
            {"SELECT COUNT(DISTINCT id_ciudad) FROM propiedad", "Ciudades cubiertas", "bi-geo-alt"},
            {"SELECT COUNT(*) FROM inmobiliaria", "Inmobiliarias aliadas", "bi-building"},
            {"SELECT COUNT(*) FROM usuario u JOIN usuario_rol ur ON ur.id_usuario=u.id_usuario " +
             "JOIN rol r ON r.id_rol=ur.id_rol WHERE r.nombre='CLIENTE'", "Clientes registrados", "bi-people"}
        };
        try (Connection con = abrirConexion()) {
            for (String[] s : stats) {
                int valor = 0;
                try (PreparedStatement ps = con.prepareStatement(s[0]); ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) valor = rs.getInt(1);
                }
    %>
        <div class="col-6 col-md-3 stat-item">
            <div class="stat-numero"><i class="bi <%= s[2] %>"></i><%= valor %></div>
            <div class="stat-label"><%= s[1] %></div>
        </div>
    <%      }
        } catch (SQLException ex) { } %>
    </div>
</div>

<!-- ================= Por que elegirnos ================= -->
<div class="seccion-titulo">
    <h4>¿Por que elegir TerraNova?</h4>
    <p>Un marketplace pensado para que buscar, agendar y tramitar tu proximo inmueble sea simple.</p>
</div>
<div class="row g-4 mb-5">
    <div class="col-md-3 feature-card">
        <div class="feature-icono"><i class="bi bi-buildings"></i></div>
        <h6>Varias inmobiliarias</h6>
        <p class="text-muted small">Comparamos propiedades de distintas agencias aliadas en un
            solo lugar, sin favorecer a ninguna.</p>
    </div>
    <div class="col-md-3 feature-card">
        <div class="feature-icono"><i class="bi bi-patch-check"></i></div>
        <h6>Publicaciones verificadas</h6>
        <p class="text-muted small">Cada inmueble tiene una matricula inmobiliaria unica y un
            agente responsable identificado.</p>
    </div>
    <div class="col-md-3 feature-card">
        <div class="feature-icono"><i class="bi bi-shield-lock"></i></div>
        <h6>Cuentas seguras</h6>
        <p class="text-muted small">Contraseñas cifradas y control de acceso por rol en cada
            paso del proceso.</p>
    </div>
    <div class="col-md-3 feature-card">
        <div class="feature-icono"><i class="bi bi-calendar2-check"></i></div>
        <h6>Agenda en minutos</h6>
        <p class="text-muted small">Solicita una visita o radica tu tramite de compra/arriendo
            sin llamadas ni filas.</p>
    </div>
</div>

<!-- ================= Propiedades destacadas ================= -->
<div class="seccion-titulo">
    <h4><i class="bi bi-star-fill text-warning"></i> Propiedades destacadas</h4>
    <p>Las publicaciones mas recientes disponibles ahora mismo.</p>
</div>
<div class="row g-4 mb-5">
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
            int idProp = rs.getInt("id_propiedad");
            boolean esFav = misFavoritos.contains(idProp);
%>
    <div class="col-md-6 col-lg-4">
        <div class="card tarjeta-propiedad shadow-sm">
            <div class="tarjeta-img-wrap">
                <img src="<%= escapar(rs.getString("imagen")) %>" class="card-img-top" alt="<%= escapar(rs.getString("tipo")) %>">
                <span class="ribbon-destacado">Destacado</span>
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
                    <span class="badge badge-estado-<%= rs.getString("estado") %>"><%= rs.getString("estado") %></span>
                    <span class="badge text-bg-secondary"><%= rs.getString("operacion") %></span>
                </div>
                <h6 class="mt-2 titulo-propiedad"><%= escapar(rs.getString("titulo")) %></h6>
                <p class="text-muted mb-1"><i class="bi bi-geo-alt"></i> <%= escapar(rs.getString("ciudad")) %>
                    &middot; <%= escapar(rs.getString("tipo")) %></p>
                <p class="precio-destacado"><%= formatoCOP(rs.getDouble("precio")) %></p>
                <a class="btn btn-outline-success btn-sm w-100"
                   href="<%= ctx %>/detallePropiedad.jsp?id=<%= idProp %>">
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

<!-- ================= CTA de cierre ================= -->
<div class="cta-terranova text-center mb-4">
    <h4 class="fw-bold">¿Eres agente inmobiliario?</h4>
    <p class="mb-3">Registrate, publica tus propiedades y gestiona citas y solicitudes desde un
        solo panel.</p>
    <a class="btn btn-warning fw-semibold" href="<%= ctx %>/registro.jsp">
        <i class="bi bi-person-plus"></i> Crear una cuenta</a>
</div>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
