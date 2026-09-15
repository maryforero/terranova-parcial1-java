<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Detalle de propiedad";
    int idPropiedad = 0;
    try { idPropiedad = Integer.parseInt(request.getParameter("id")); } catch (Exception ex) { }

    boolean esCliente = tieneRol(session, "CLIENTE");
    boolean esFavorito = false;
    if (esCliente) {
        int idUsuarioFav = (Integer) session.getAttribute("idUsuario");
        try (Connection con = abrirConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT COUNT(*) FROM favorito WHERE id_usuario=? AND id_propiedad=?")) {
            ps.setInt(1, idUsuarioFav);
            ps.setInt(2, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) esFavorito = rs.getInt(1) > 0; }
        } catch (SQLException ex) { }
    }
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<%
    String sql =
        "SELECT p.*, c.nombre AS ciudad, t.nombre AS tipo, i.nombre AS inmobiliaria, " +
        "       i.telefono AS telefono_inmobiliaria, " +
        "       pf.nombres AS agente_nombres, pf.apellidos AS agente_apellidos, pf.telefono AS telefono_agente " +
        "FROM propiedad p " +
        "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
        "JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo " +
        "JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
        "JOIN usuario u ON u.id_usuario = p.id_agente " +
        "JOIN perfil pf ON pf.id_usuario = u.id_usuario " +
        "WHERE p.id_propiedad = ?";
    boolean encontrada = false;
    try (Connection con = abrirConexion();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, idPropiedad);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                encontrada = true;
%>
<div class="row g-4">
    <div class="col-lg-7">
        <div id="carrusel" class="carousel slide shadow-sm rounded-3 overflow-hidden" data-bs-ride="carousel">
            <div class="carousel-inner">
                <%
                    try (PreparedStatement psImg = con.prepareStatement(
                            "SELECT url_imagen FROM imagen_propiedad WHERE id_propiedad=? ORDER BY es_principal DESC, orden ASC")) {
                        psImg.setInt(1, idPropiedad);
                        try (ResultSet rsImg = psImg.executeQuery()) {
                            boolean primero = true;
                            while (rsImg.next()) {
                %>
                <div class="carousel-item <%= primero ? "active" : "" %>">
                    <img src="<%= escapar(rsImg.getString("url_imagen")) %>" class="d-block w-100" style="height:380px;object-fit:cover;">
                </div>
                <% primero = false; } } } %>
            </div>
            <button class="carousel-control-prev" type="button" data-bs-target="#carrusel" data-bs-slide="prev">
                <span class="carousel-control-prev-icon"></span></button>
            <button class="carousel-control-next" type="button" data-bs-target="#carrusel" data-bs-slide="next">
                <span class="carousel-control-next-icon"></span></button>
        </div>

        <h4 class="mt-3"><%= escapar(rs.getString("titulo")) %></h4>
        <p class="text-muted"><i class="bi bi-geo-alt"></i> <%= escapar(rs.getString("direccion")) %>,
            <%= escapar(rs.getString("ciudad")) %></p>
        <p><%= escapar(rs.getString("descripcion")) %></p>

        <h6 class="mt-3">Características</h6>
        <div class="d-flex flex-wrap gap-2 mb-3">
            <%
                try (PreparedStatement psCar = con.prepareStatement(
                        "SELECT ca.nombre FROM propiedad_caracteristica pc " +
                        "JOIN caracteristica ca ON ca.id_caracteristica = pc.id_caracteristica " +
                        "WHERE pc.id_propiedad = ? ORDER BY ca.nombre")) {
                    psCar.setInt(1, idPropiedad);
                    try (ResultSet rsCar = psCar.executeQuery()) {
                        boolean alguna = false;
                        while (rsCar.next()) {
                            alguna = true;
            %>
            <span class="badge text-bg-light border"><i class="bi bi-check2-circle text-success"></i> <%= escapar(rsCar.getString("nombre")) %></span>
            <% } if (!alguna) { %>
            <span class="text-muted">Sin características registradas.</span>
            <% } } } %>
        </div>
    </div>

    <div class="col-lg-5">
        <div class="card shadow-sm">
            <div class="card-body">
                <span class="badge badge-estado-<%= rs.getString("estado") %>"><%= rs.getString("estado") %></span>
                <span class="badge text-bg-secondary"><%= rs.getString("operacion") %></span>
                <h3 class="precio-destacado mt-2"><%= formatoCOP(rs.getDouble("precio")) %></h3>
                <ul class="list-unstyled small text-muted">
                    <li><i class="bi bi-rulers"></i> Área: <%= rs.getObject("area_m2") != null ? rs.getDouble("area_m2") + " m2" : "N/D" %></li>
                    <li><i class="bi bi-door-closed"></i> Habitaciones: <%= rs.getObject("habitaciones") != null ? rs.getInt("habitaciones") : "N/D" %></li>
                    <li><i class="bi bi-droplet"></i> Baños: <%= rs.getObject("banos") != null ? rs.getInt("banos") : "N/D" %></li>
                    <li><i class="bi bi-hash"></i> Matrícula: <%= escapar(rs.getString("matricula_inmobiliaria")) %></li>
                </ul>
                <hr>
                <p class="mb-1"><strong><i class="bi bi-building"></i> <%= escapar(rs.getString("inmobiliaria")) %></strong></p>
                <% if (estaAutenticado(session)) { %>
                    <p class="mb-1">Agente: <%= escapar(rs.getString("agente_nombres")) %> <%= escapar(rs.getString("agente_apellidos")) %></p>
                    <p class="mb-3"><i class="bi bi-telephone"></i> <%= escapar(rs.getString("telefono_agente")) %>
                        &middot; <%= escapar(rs.getString("telefono_inmobiliaria")) %></p>
                <% } else { %>
                    <p class="text-muted small mb-3">
                        <i class="bi bi-lock"></i> Inicia sesión para ver los datos de contacto completos del agente.</p>
                <% } %>

                <% if (tieneRol(session, "CLIENTE")) { %>
                    <div class="d-grid gap-2">
                        <a class="btn btn-success" href="<%= ctx %>/citas/agendar.jsp?idPropiedad=<%= idPropiedad %>">
                            <i class="bi bi-calendar-plus"></i> Agendar visita</a>
                        <a class="btn btn-outline-success" href="<%= ctx %>/solicitudes/radicar.jsp?idPropiedad=<%= idPropiedad %>">
                            <i class="bi bi-file-earmark-plus"></i> Solicitar compra/arriendo</a>
                        <button type="button" class="btn btn-favorito-detalle <%= esFavorito ? "btn-danger" : "btn-outline-danger" %>"
                                data-id="<%= idPropiedad %>">
                            <i class="bi <%= esFavorito ? "bi-heart-fill" : "bi-heart" %>"></i><%= esFavorito ? " Quitar de favoritos" : " Agregar a favoritos" %></button>
                    </div>
                <% } else if (!estaAutenticado(session)) { %>
                    <a class="btn btn-success w-100" href="<%= ctx %>/login.jsp">
                        <i class="bi bi-box-arrow-in-right"></i> Inicia sesión para agendar o solicitar</a>
                <% } %>
            </div>
        </div>
    </div>
</div>
<%
            }
        }
    } catch (SQLException ex) {
%>
        <p class="text-danger">Error al consultar la propiedad: <%= escapar(ex.getMessage()) %></p>
<%
    }
    if (!encontrada) {
%>
        <div class="alert alert-warning">La propiedad solicitada no existe o ya no esta disponible.
            <a href="<%= ctx %>/catalogo.jsp">Volver al catálogo</a></div>
<% } %>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
