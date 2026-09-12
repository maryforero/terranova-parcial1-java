<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Reportes";
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-1"><i class="bi bi-bar-chart"></i> Reportes</h3>
<p class="text-muted mb-4">Un vistazo rapido al estado del negocio, seguido de las consultas SQL
    que lo sustentan (INNER JOIN, relacion N:M, LEFT JOIN y agregaciones con GROUP BY/HAVING).</p>

<%!
    /** Una fila (etiqueta, valor) para graficas de barras u otros usos simples. */
    private static final class Fila {
        String etiqueta; long valor;
        Fila(String e, long v) { etiqueta = e; valor = v; }
    }

    /** Tarjeta KPI simple con un numero grande. */
    void pintarKpi(JspWriter out, String colorClase, String icono, long valor, String etiqueta)
            throws java.io.IOException {
        out.println("<div class=\"col-6 col-lg-3\"><div class=\"kpi-card " + colorClase + "\">"
            + "<i class=\"bi " + icono + "\"></i>"
            + "<div class=\"kpi-valor\">" + valor + "</div>"
            + "<div class=\"kpi-label\">" + etiqueta + "</div></div></div>");
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
                       String sql, String colorTexto) throws java.io.IOException {
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
        out.println("<details class=\"mt-2\"><summary class=\"small text-primary\" style=\"cursor:pointer;\">Ver consulta SQL</summary>"
            + "<pre class=\"small bg-light p-2 rounded mt-1\">" + sql.replace("<","&lt;") + "</pre></details>");
        out.println("</div>");
    }

    /** Pinta una tarjeta de reporte como tabla (para listados con varias columnas). */
    void pintarTabla(JspWriter out, Connection con, String numero, String titulo, String porQue,
                      String sql, int limiteFilas) throws java.io.IOException {
        out.println("<div class=\"reporte-card\">");
        out.println("<h5>" + numero + ". " + titulo + "</h5>");
        out.println("<p class=\"reporte-desc\">" + porQue + "</p>");
        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            ResultSetMetaData meta = rs.getMetaData();
            int cols = meta.getColumnCount();
            out.println("<div class=\"table-responsive\"><table class=\"table table-sm table-striped align-middle\"><thead><tr>");
            for (int i = 1; i <= cols; i++) out.println("<th>" + meta.getColumnLabel(i) + "</th>");
            out.println("</tr></thead><tbody>");
            boolean alguna = false;
            int n = 0;
            while (rs.next() && n < limiteFilas) {
                alguna = true; n++;
                out.println("<tr>");
                for (int i = 1; i <= cols; i++) {
                    Object v = rs.getObject(i);
                    out.println("<td>" + (v != null ? v.toString() : "<span class=\"text-muted\">-</span>") + "</td>");
                }
                out.println("</tr>");
            }
            if (!alguna) out.println("<tr><td colspan=\"" + cols + "\" class=\"text-center text-muted\">Sin datos</td></tr>");
            out.println("</tbody></table></div>");
        } catch (SQLException ex) {
            out.println("<p class=\"text-danger\">Error: " + ex.getMessage() + "</p>");
        }
        out.println("<details class=\"mt-2\"><summary class=\"small text-primary\" style=\"cursor:pointer;\">Ver consulta SQL</summary>"
            + "<pre class=\"small bg-light p-2 rounded mt-1\">" + sql.replace("<","&lt;") + "</pre></details>");
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

<!-- ================= Reportes de agregacion (graficas) ================= -->
<h5 class="mb-3 text-muted"><i class="bi bi-graph-up"></i> Paneles con agregacion (GROUP BY + HAVING)</h5>
<div class="row g-3 mb-4">
    <div class="col-lg-4">
<%      pintarBarras(out, con, "1", "Propiedades disponibles por ciudad",
            "¿En que ciudades tenemos mas inventario listo para vender o arrendar? " +
            "Ayuda a decidir donde reforzar la oferta o el mercadeo.",
            "SELECT c.nombre, COUNT(*) FROM propiedad p JOIN ciudad c ON c.id_ciudad=p.id_ciudad " +
            "WHERE p.estado='DISPONIBLE' GROUP BY c.nombre HAVING COUNT(*) >= 1 ORDER BY 2 DESC",
            "text-success"); %>
    </div>
    <div class="col-lg-4">
<%      pintarBarras(out, con, "2", "Solicitudes por inmobiliaria",
            "¿Que agencia aliada esta generando mas negocio (compras/arriendos radicados)? " +
            "Sirve para medir el desempeño de cada inmobiliaria aliada.",
            "SELECT i.nombre, COUNT(*) FROM solicitud s JOIN propiedad p ON p.id_propiedad=s.id_propiedad " +
            "JOIN inmobiliaria i ON i.id_inmobiliaria=p.id_inmobiliaria " +
            "GROUP BY i.nombre HAVING COUNT(*) >= 1 ORDER BY 2 DESC",
            "text-primary"); %>
    </div>
    <div class="col-lg-4">
<%      pintarBarras(out, con, "3", "Citas por estado",
            "¿Cuantas visitas terminan confirmadas, rechazadas o realizadas? Mide que tan " +
            "efectivo es el proceso de agendamiento.",
            "SELECT estado, COUNT(*) FROM cita GROUP BY estado ORDER BY 2 DESC",
            "text-warning"); %>
    </div>
</div>

<!-- ================= Reportes de cruces (JOIN) ================= -->
<h5 class="mb-3 text-muted"><i class="bi bi-diagram-3"></i> Cruces entre tablas (JOIN)</h5>
<div class="row g-3">
    <div class="col-lg-6">
<%      pintarTabla(out, con, "4", "Propiedades con ciudad, tipo e inmobiliaria",
            "Cruce (INNER JOIN) de 4 tablas: la vista base del catalogo administrativo.",
            "SELECT p.titulo, c.nombre AS ciudad, t.nombre AS tipo, i.nombre AS inmobiliaria, " +
            "p.precio, p.estado FROM propiedad p " +
            "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
            "JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo " +
            "JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
            "ORDER BY p.fecha_publicacion DESC", 8); %>
    </div>
    <div class="col-lg-6">
<%      pintarTabla(out, con, "5", "Citas con propiedad, cliente e inmobiliaria",
            "Cruce (INNER JOIN) de 5 tablas: quien agendo, que propiedad y con que agencia.",
            "SELECT c.fecha_hora, c.estado, p.titulo, pf.nombres, i.nombre AS inmobiliaria " +
            "FROM cita c JOIN propiedad p ON p.id_propiedad = c.id_propiedad " +
            "JOIN usuario u ON u.id_usuario = c.id_cliente " +
            "JOIN perfil pf ON pf.id_usuario = u.id_usuario " +
            "JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
            "ORDER BY c.fecha_hora DESC", 8); %>
    </div>
    <div class="col-lg-6">
<%      pintarTabla(out, con, "6", "Roles asignados por usuario (relacion N:M)",
            "Expande la tabla intermedia usuario_rol: un mismo usuario puede aparecer con mas " +
            "de un rol (por ejemplo, un director que tambien administra el sistema).",
            "SELECT pf.nombres, pf.apellidos, u.correo, r.nombre AS rol " +
            "FROM usuario_rol ur JOIN usuario u ON u.id_usuario = ur.id_usuario " +
            "JOIN perfil pf ON pf.id_usuario = u.id_usuario " +
            "JOIN rol r ON r.id_rol = ur.id_rol ORDER BY pf.nombres", 10); %>
    </div>
    <div class="col-lg-6">
<%      pintarTabla(out, con, "7", "Propiedades sin citas agendadas (LEFT JOIN)",
            "El LEFT JOIN conserva TODAS las propiedades aunque no tengan ninguna cita; " +
            "identifica inventario que necesita mas promocion.",
            "SELECT p.titulo, p.direccion, p.estado FROM propiedad p " +
            "LEFT JOIN cita c ON c.id_propiedad = p.id_propiedad " +
            "WHERE c.id_cita IS NULL ORDER BY p.titulo", 10); %>
    </div>
</div>

<% } catch (SQLException ex) { %>
    <p class="text-danger">Error de conexion: <%= escapar(ex.getMessage()) %></p>
<% } %>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
