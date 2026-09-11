<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Reportes";
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<h3 class="mb-4"><i class="bi bi-bar-chart"></i> Reportes</h3>

<%!
    /** Ejecuta una consulta y la pinta como tabla HTML, mostrando tambien el SQL usado. */
    void pintarReporte(JspWriter out, Connection con, String titulo, String descripcion, String sql)
            throws java.io.IOException {
        out.println("<div class=\"card shadow-sm mb-4\"><div class=\"card-body\">");
        out.println("<h5>" + titulo + "</h5>");
        out.println("<p class=\"text-muted small\">" + descripcion + "</p>");
        out.println("<details class=\"mb-2\"><summary class=\"small text-primary\" style=\"cursor:pointer;\">Ver consulta SQL</summary>"
                + "<pre class=\"small bg-light p-2 rounded\">" + sql.replace("<","&lt;") + "</pre></details>");
        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            ResultSetMetaData meta = rs.getMetaData();
            int cols = meta.getColumnCount();
            out.println("<div class=\"table-responsive\"><table class=\"table table-sm table-striped\"><thead><tr>");
            for (int i = 1; i <= cols; i++) out.println("<th>" + meta.getColumnLabel(i) + "</th>");
            out.println("</tr></thead><tbody>");
            boolean alguna = false;
            while (rs.next()) {
                alguna = true;
                out.println("<tr>");
                for (int i = 1; i <= cols; i++) {
                    Object v = rs.getObject(i);
                    out.println("<td>" + (v != null ? v.toString() : "") + "</td>");
                }
                out.println("</tr>");
            }
            if (!alguna) out.println("<tr><td colspan=\"" + cols + "\" class=\"text-center text-muted\">Sin datos</td></tr>");
            out.println("</tbody></table></div>");
        } catch (SQLException ex) {
            out.println("<p class=\"text-danger\">Error: " + ex.getMessage() + "</p>");
        }
        out.println("</div></div>");
    }
%>
<%
    try (Connection con = abrirConexion()) {

        pintarReporte(out, con,
            "1. Propiedades con ciudad, tipo e inmobiliaria (INNER JOIN x3)",
            "Cruza propiedad, ciudad, tipo_propiedad e inmobiliaria.",
            "SELECT p.titulo, c.nombre AS ciudad, t.nombre AS tipo, i.nombre AS inmobiliaria, " +
            "p.precio, p.estado " +
            "FROM propiedad p " +
            "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
            "JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo " +
            "JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
            "ORDER BY p.fecha_publicacion DESC");

        pintarReporte(out, con,
            "2. Citas con propiedad, cliente e inmobiliaria (INNER JOIN x4)",
            "Cruza cita, propiedad, usuario/perfil del cliente e inmobiliaria.",
            "SELECT c.fecha_hora, c.estado, p.titulo, pf.nombres, pf.apellidos, i.nombre AS inmobiliaria " +
            "FROM cita c " +
            "JOIN propiedad p ON p.id_propiedad = c.id_propiedad " +
            "JOIN usuario u ON u.id_usuario = c.id_cliente " +
            "JOIN perfil pf ON pf.id_usuario = u.id_usuario " +
            "JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
            "ORDER BY c.fecha_hora DESC LIMIT 20");

        pintarReporte(out, con,
            "3. Roles asignados por usuario (resuelve la relacion N:M usuario_rol)",
            "Cada usuario puede tener uno o varios roles; esta consulta los expande.",
            "SELECT pf.nombres, pf.apellidos, u.correo, r.nombre AS rol " +
            "FROM usuario_rol ur " +
            "JOIN usuario u ON u.id_usuario = ur.id_usuario " +
            "JOIN perfil pf ON pf.id_usuario = u.id_usuario " +
            "JOIN rol r ON r.id_rol = ur.id_rol " +
            "ORDER BY pf.nombres");

        pintarReporte(out, con,
            "4. Propiedades sin citas agendadas (LEFT JOIN)",
            "Propiedades para las que ningun cliente ha agendado una visita todavia.",
            "SELECT p.titulo, p.direccion, p.estado " +
            "FROM propiedad p " +
            "LEFT JOIN cita c ON c.id_propiedad = p.id_propiedad " +
            "WHERE c.id_cita IS NULL " +
            "ORDER BY p.titulo");

        pintarReporte(out, con,
            "5. Propiedades disponibles por ciudad (GROUP BY + HAVING)",
            "Cuenta propiedades en estado DISPONIBLE agrupadas por ciudad.",
            "SELECT c.nombre AS ciudad, COUNT(*) AS total_disponibles " +
            "FROM propiedad p " +
            "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
            "WHERE p.estado = 'DISPONIBLE' " +
            "GROUP BY c.nombre " +
            "HAVING COUNT(*) >= 1 " +
            "ORDER BY total_disponibles DESC");

        pintarReporte(out, con,
            "6. Solicitudes por inmobiliaria (GROUP BY + HAVING, bonus)",
            "Cuenta solicitudes recibidas por cada inmobiliaria.",
            "SELECT i.nombre AS inmobiliaria, COUNT(*) AS total_solicitudes " +
            "FROM solicitud s " +
            "JOIN propiedad p ON p.id_propiedad = s.id_propiedad " +
            "JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
            "GROUP BY i.nombre " +
            "HAVING COUNT(*) >= 1 " +
            "ORDER BY total_solicitudes DESC");

        pintarReporte(out, con,
            "7. Citas por estado (GROUP BY, bonus)",
            "Distribucion de citas segun su estado actual.",
            "SELECT estado, COUNT(*) AS total FROM cita GROUP BY estado ORDER BY total DESC");

    } catch (SQLException ex) {
%>
    <p class="text-danger">Error de conexion: <%= escapar(ex.getMessage()) %></p>
<% } %>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
