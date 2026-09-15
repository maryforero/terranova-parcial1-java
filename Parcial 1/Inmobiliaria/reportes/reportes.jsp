<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Reportes";
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<div class="seccion-titulo text-start mb-4">
    <h3 class="panel-titulo mb-1"><i class="bi bi-bar-chart"></i> Reportes</h3>
    <p class="text-muted mb-0">Un vistazo rapido al estado del negocio: disponibilidad,
        actividad de citas y solicitudes, y desempeño por ciudad e inmobiliaria.</p>
</div>

<%!
    /** Una fila (etiqueta, valor) para graficas de barras u otros usos simples. */
    private static final class Fila {
        String etiqueta; long valor;
        Fila(String e, long v) { etiqueta = e; valor = v; }
    }

    /** Tarjeta KPI simple con un numero grande. */
    void pintarKpi(JspWriter out, String colorClase, String icono, long valor, String etiqueta)
            throws java.io.IOException {
        out.println("<div class=\"col-6 col-lg-3\"><div class=\"kpi-card " + colorClase + " d-flex align-items-center gap-3\">"
            + "<i class=\"bi " + icono + "\" style=\"font-size:1.7rem;opacity:0.85;\"></i>"
            + "<div><div class=\"kpi-valor\">" + valor + "</div>"
            + "<div class=\"kpi-label\">" + etiqueta + "</div></div></div></div>");
    }

    /** Ejecuta un SELECT de 2 columnas (etiqueta, valor) y arma la lista de filas. */
    java.util.List<Fila> obtenerFilas(Connection con, String sql) throws SQLException {
        java.util.List<Fila> filas = new java.util.ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) filas.add(new Fila(String.valueOf(rs.getObject(1)), rs.getLong(2)));
        }
        return filas;
    }

    /** Pinta una tarjeta de reporte con grafica de barras horizontales en CSS puro
     *  (nada de JS/librerias externas) y una frase de insight con el valor mas alto. */
    void pintarBarras(JspWriter out, Connection con, String numero, String titulo, String porQue,
                       String sql) throws java.io.IOException {
        out.println("<div class=\"reporte-card\">");
        out.println("<h5>" + numero + ". " + titulo + "</h5>");
        out.println("<p class=\"reporte-desc\">" + porQue + "</p>");
        try {
            java.util.List<Fila> filas = obtenerFilas(con, sql);
            long max = 1;
            for (Fila f : filas) max = Math.max(max, f.valor);
            if (filas.isEmpty()) {
                out.println("<p class=\"text-muted\">Sin datos todavia.</p>");
            } else {
                for (Fila f : filas) {
                    int pct = (int) Math.round((f.valor * 100.0) / max);
                    out.println("<div class=\"barra-fila\">"
                        + "<div class=\"barra-etiqueta\"><span>" + f.etiqueta + "</span><strong>" + f.valor + "</strong></div>"
                        + "<div class=\"barra-pista\"><div class=\"barra-relleno\" style=\"width:" + pct + "%\"></div></div>"
                        + "</div>");
                }
                Fila top = filas.get(0);
                for (Fila f : filas) if (f.valor > top.valor) top = f;
                out.println("<div class=\"reporte-insight\"><i class=\"bi bi-lightbulb\"></i> "
                    + top.etiqueta + " lidera con " + top.valor + ".</div>");
            }
        } catch (SQLException ex) {
            out.println("<p class=\"text-danger\">Error: " + ex.getMessage() + "</p>");
        }
        out.println("</div>");
    }

    String badgeEstadoPropiedad(String estado) {
        return "<span class=\"badge badge-estado-" + estado + "\">" + estado + "</span>";
    }
    String badgeEstadoCita(String estado) {
        return "<span class=\"badge badge-cita-" + estado + "\">" + estado + "</span>";
    }
    String badgeRol(String rol) {
        String clase = "ADMINISTRADOR".equals(rol) ? "text-bg-dark"
                     : "INMOBILIARIA".equals(rol) ? "text-bg-primary"
                     : "text-bg-secondary";
        return "<span class=\"badge " + clase + "\">" + rol + "</span>";
    }

    /** Reporte 4: catalogo de propiedades con ciudad, tipo e inmobiliaria. */
    void pintarReporte4(JspWriter out, Connection con) throws java.io.IOException {
        out.println("<div class=\"reporte-card\">");
        out.println("<h5>4. Propiedades por ciudad, tipo e inmobiliaria</h5>");
        out.println("<p class=\"reporte-desc\">Catalogo con la ciudad, el tipo de inmueble y la inmobiliaria responsable de cada propiedad.</p>");
        String sql = "SELECT p.titulo, c.nombre AS ciudad, t.nombre AS tipo, i.nombre AS inmobiliaria, p.precio, p.estado " +
                     "FROM propiedad p JOIN ciudad c ON c.id_ciudad=p.id_ciudad " +
                     "JOIN tipo_propiedad t ON t.id_tipo=p.id_tipo " +
                     "JOIN inmobiliaria i ON i.id_inmobiliaria=p.id_inmobiliaria " +
                     "ORDER BY p.fecha_publicacion DESC LIMIT 8";
        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            out.println("<div class=\"table-responsive\"><table class=\"table table-sm table-striped align-middle tabla-reporte\">"
                + "<thead><tr><th>Propiedad</th><th>Tipo</th><th>Inmobiliaria</th><th class=\"text-end\">Precio</th><th>Estado</th></tr></thead><tbody>");
            boolean alguna = false;
            while (rs.next()) {
                alguna = true;
                out.println("<tr><td><strong>" + escapar(rs.getString("titulo")) + "</strong><br>"
                    + "<span class=\"text-muted small\"><i class=\"bi bi-geo-alt\"></i> " + escapar(rs.getString("ciudad")) + "</span></td>"
                    + "<td>" + escapar(rs.getString("tipo")) + "</td>"
                    + "<td>" + escapar(rs.getString("inmobiliaria")) + "</td>"
                    + "<td class=\"text-end fw-semibold\">" + formatoCOP(rs.getDouble("precio")) + "</td>"
                    + "<td>" + badgeEstadoPropiedad(rs.getString("estado")) + "</td></tr>");
            }
            if (!alguna) out.println("<tr><td colspan=\"5\" class=\"text-center text-muted\">Sin datos</td></tr>");
            out.println("</tbody></table></div>");
        } catch (SQLException ex) {
            out.println("<p class=\"text-danger\">Error: " + ex.getMessage() + "</p>");
        }
        out.println("</div>");
    }

    /** Reporte 5: citas con propiedad, cliente e inmobiliaria. */
    void pintarReporte5(JspWriter out, Connection con) throws java.io.IOException {
        out.println("<div class=\"reporte-card\">");
        out.println("<h5>5. Citas agendadas</h5>");
        out.println("<p class=\"reporte-desc\">Quien agendo cada visita, a que propiedad y con que inmobiliaria.</p>");
        String sql = "SELECT DATE_FORMAT(c.fecha_hora, '%d/%m/%Y %H:%i') AS fecha, c.estado, p.titulo, " +
                     "pf.nombres, pf.apellidos, i.nombre AS inmobiliaria " +
                     "FROM cita c JOIN propiedad p ON p.id_propiedad=c.id_propiedad " +
                     "JOIN usuario u ON u.id_usuario=c.id_cliente " +
                     "JOIN perfil pf ON pf.id_usuario=u.id_usuario " +
                     "JOIN inmobiliaria i ON i.id_inmobiliaria=p.id_inmobiliaria " +
                     "ORDER BY c.fecha_hora DESC LIMIT 8";
        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            out.println("<div class=\"table-responsive\"><table class=\"table table-sm table-striped align-middle tabla-reporte\">"
                + "<thead><tr><th>Fecha</th><th>Propiedad</th><th>Cliente</th><th>Inmobiliaria</th><th>Estado</th></tr></thead><tbody>");
            boolean alguna = false;
            while (rs.next()) {
                alguna = true;
                out.println("<tr><td class=\"text-nowrap\">" + rs.getString("fecha") + "</td>"
                    + "<td>" + escapar(rs.getString("titulo")) + "</td>"
                    + "<td>" + escapar(rs.getString("nombres")) + " " + escapar(rs.getString("apellidos")) + "</td>"
                    + "<td>" + escapar(rs.getString("inmobiliaria")) + "</td>"
                    + "<td>" + badgeEstadoCita(rs.getString("estado")) + "</td></tr>");
            }
            if (!alguna) out.println("<tr><td colspan=\"5\" class=\"text-center text-muted\">Sin datos</td></tr>");
            out.println("</tbody></table></div>");
        } catch (SQLException ex) {
            out.println("<p class=\"text-danger\">Error: " + ex.getMessage() + "</p>");
        }
        out.println("</div>");
    }

    /** Reporte 6: roles asignados por usuario (relacion N:M usuario_rol). */
    void pintarReporte6(JspWriter out, Connection con) throws java.io.IOException {
        out.println("<div class=\"reporte-card\">");
        out.println("<h5>6. Roles por usuario</h5>");
        out.println("<p class=\"reporte-desc\">Cada usuario con el o los roles que tiene asignados (algunos tienen mas de uno).</p>");
        String sql = "SELECT pf.nombres, pf.apellidos, u.correo, r.nombre AS rol " +
                     "FROM usuario_rol ur JOIN usuario u ON u.id_usuario=ur.id_usuario " +
                     "JOIN perfil pf ON pf.id_usuario=u.id_usuario " +
                     "JOIN rol r ON r.id_rol=ur.id_rol ORDER BY pf.nombres LIMIT 10";
        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            out.println("<div class=\"table-responsive\"><table class=\"table table-sm table-striped align-middle tabla-reporte\">"
                + "<thead><tr><th>Usuario</th><th>Rol</th></tr></thead><tbody>");
            boolean alguna = false;
            while (rs.next()) {
                alguna = true;
                out.println("<tr><td><strong>" + escapar(rs.getString("nombres")) + " " + escapar(rs.getString("apellidos")) + "</strong><br>"
                    + "<span class=\"text-muted small\">" + escapar(rs.getString("correo")) + "</span></td>"
                    + "<td>" + badgeRol(rs.getString("rol")) + "</td></tr>");
            }
            if (!alguna) out.println("<tr><td colspan=\"2\" class=\"text-center text-muted\">Sin datos</td></tr>");
            out.println("</tbody></table></div>");
        } catch (SQLException ex) {
            out.println("<p class=\"text-danger\">Error: " + ex.getMessage() + "</p>");
        }
        out.println("</div>");
    }

    /** Reporte 7: propiedades sin citas agendadas. */
    void pintarReporte7(JspWriter out, Connection con) throws java.io.IOException {
        out.println("<div class=\"reporte-card\">");
        out.println("<h5>7. Propiedades sin visitas agendadas</h5>");
        out.println("<p class=\"reporte-desc\">Inventario que todavia no ha tenido ninguna visita; util para priorizar promocion.</p>");
        String sql = "SELECT p.titulo, p.direccion, p.estado FROM propiedad p " +
                     "LEFT JOIN cita c ON c.id_propiedad=p.id_propiedad " +
                     "WHERE c.id_cita IS NULL ORDER BY p.titulo LIMIT 10";
        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            out.println("<div class=\"table-responsive\"><table class=\"table table-sm table-striped align-middle tabla-reporte\">"
                + "<thead><tr><th>Propiedad</th><th>Direccion</th><th>Estado</th></tr></thead><tbody>");
            boolean alguna = false;
            while (rs.next()) {
                alguna = true;
                out.println("<tr><td>" + escapar(rs.getString("titulo")) + "</td>"
                    + "<td class=\"text-muted small\">" + escapar(rs.getString("direccion")) + "</td>"
                    + "<td>" + badgeEstadoPropiedad(rs.getString("estado")) + "</td></tr>");
            }
            if (!alguna) out.println("<tr><td colspan=\"3\" class=\"text-center text-muted\">Todas las propiedades tienen al menos una visita.</td></tr>");
            out.println("</tbody></table></div>");
        } catch (SQLException ex) {
            out.println("<p class=\"text-danger\">Error: " + ex.getMessage() + "</p>");
        }
        out.println("</div>");
    }
%>
<%
    try (Connection con = abrirConexion()) {
%>

<!-- ================= KPIs generales ================= -->
<div class="row g-3 mb-4">
<%
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM propiedad WHERE estado='DISPONIBLE'");
             ResultSet rs = ps.executeQuery()) { rs.next(); pintarKpi(out, "kpi-verde", "bi-house-check", rs.getLong(1), "Propiedades disponibles"); }
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM cita WHERE estado='PENDIENTE'");
             ResultSet rs = ps.executeQuery()) { rs.next(); pintarKpi(out, "kpi-dorado", "bi-calendar-event", rs.getLong(1), "Citas pendientes"); }
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM solicitud WHERE estado IN ('PENDIENTE','EN_REVISION')");
             ResultSet rs = ps.executeQuery()) { rs.next(); pintarKpi(out, "kpi-azul", "bi-file-earmark-text", rs.getLong(1), "Solicitudes en tramite"); }
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM solicitud WHERE estado='APROBADA'");
             ResultSet rs = ps.executeQuery()) { rs.next(); pintarKpi(out, "kpi-gris", "bi-check-circle", rs.getLong(1), "Solicitudes aprobadas"); }
%>
</div>

<!-- ================= Resumen por categoria ================= -->
<h6 class="text-uppercase text-muted mb-3" style="letter-spacing:0.04em;">
    <i class="bi bi-graph-up"></i> Resumen por categoria</h6>
<div class="row g-3 mb-5">
    <div class="col-lg-4">
<%      pintarBarras(out, con, "1", "Propiedades disponibles por ciudad",
            "¿En que ciudades tenemos mas inventario listo para vender o arrendar? " +
            "Ayuda a decidir donde reforzar la oferta o el mercadeo.",
            "SELECT c.nombre, COUNT(*) FROM propiedad p JOIN ciudad c ON c.id_ciudad=p.id_ciudad " +
            "WHERE p.estado='DISPONIBLE' GROUP BY c.nombre HAVING COUNT(*) >= 1 ORDER BY 2 DESC"); %>
    </div>
    <div class="col-lg-4">
<%      pintarBarras(out, con, "2", "Solicitudes por inmobiliaria",
            "¿Que agencia aliada esta generando mas negocio (compras/arriendos radicados)? " +
            "Sirve para medir el desempeño de cada inmobiliaria aliada.",
            "SELECT i.nombre, COUNT(*) FROM solicitud s JOIN propiedad p ON p.id_propiedad=s.id_propiedad " +
            "JOIN inmobiliaria i ON i.id_inmobiliaria=p.id_inmobiliaria " +
            "GROUP BY i.nombre HAVING COUNT(*) >= 1 ORDER BY 2 DESC"); %>
    </div>
    <div class="col-lg-4">
<%      pintarBarras(out, con, "3", "Citas por estado",
            "¿Cuantas visitas terminan confirmadas, rechazadas o realizadas? Mide que tan " +
            "efectivo es el proceso de agendamiento.",
            "SELECT estado, COUNT(*) FROM cita GROUP BY estado ORDER BY 2 DESC"); %>
    </div>
</div>

<!-- ================= Detalle y actividad ================= -->
<h6 class="text-uppercase text-muted mb-3" style="letter-spacing:0.04em;">
    <i class="bi bi-list-ul"></i> Detalle y actividad</h6>
<div class="row g-3 mb-3">
    <div class="col-12"><% pintarReporte4(out, con); %></div>
</div>
<div class="row g-3 mb-3">
    <div class="col-12"><% pintarReporte5(out, con); %></div>
</div>
<div class="row g-3">
    <div class="col-lg-6"><% pintarReporte6(out, con); %></div>
    <div class="col-lg-6"><% pintarReporte7(out, con); %></div>
</div>

<% } catch (SQLException ex) { %>
    <p class="text-danger">Error de conexion: <%= escapar(ex.getMessage()) %></p>
<% } %>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
