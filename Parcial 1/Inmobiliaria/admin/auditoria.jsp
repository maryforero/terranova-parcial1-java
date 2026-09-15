<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexionInmobiliaria.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidadesInmobiliaria.jspf" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    String tituloPagina = "Auditoria";
    String accionFiltro = request.getParameter("accion");
    String rango = request.getParameter("rango");
    if (rango == null || rango.isEmpty()) rango = "30";
%>
<%@ include file="/WEB-INF/jspf/cabeceraInmobiliaria.jspf" %>

<%!
    /** Traduce el codigo interno de la accion a texto + icono + color para
     *  que un administrador (no programador) entienda de un vistazo que paso. */
    String[] descripcionAccion(String accion) {
        // {texto amigable, icono bootstrap, clase de color}
        switch (accion) {
            case "LOGIN":                    return new String[]{"Inicio de sesion", "bi-box-arrow-in-right", "text-primary"};
            case "LOGIN_FALLIDO":            return new String[]{"Intento de inicio fallido", "bi-exclamation-triangle", "text-danger"};
            case "REGISTRO":                 return new String[]{"Registro de nueva cuenta", "bi-person-plus", "text-primary"};
            case "CAMBIAR_CLAVE":            return new String[]{"Cambio de clave", "bi-key", "text-secondary"};
            case "CREAR_PROPIEDAD":          return new String[]{"Publico una propiedad", "bi-house-add", "text-primary"};
            case "EDITAR_PROPIEDAD":         return new String[]{"Edito una propiedad", "bi-pencil-square", "text-primary"};
            case "BAJA_PROPIEDAD":           return new String[]{"Dio de baja una propiedad", "bi-trash", "text-danger"};
            case "AGENDAR_CITA":             return new String[]{"Agendo una visita", "bi-calendar-plus", "text-warning"};
            case "CAMBIAR_ESTADO_CITA":      return new String[]{"Actualizo una cita", "bi-calendar-check", "text-warning"};
            case "RADICAR_SOLICITUD":        return new String[]{"Radico una solicitud", "bi-file-earmark-plus", "text-primary"};
            case "CAMBIAR_ESTADO_SOLICITUD": return new String[]{"Actualizo una solicitud", "bi-file-earmark-check", "text-warning"};
            case "MARCAR_FAVORITO":          return new String[]{"Marco un favorito", "bi-heart", "text-danger"};
            case "CAMBIAR_ROL":              return new String[]{"Actualizo roles de un usuario", "bi-people", "text-dark"};
            case "CAMBIAR_ESTADO_USUARIO":   return new String[]{"Activo o inactivo una cuenta", "bi-person-gear", "text-dark"};
            case "AGREGAR_CATALOGO":         return new String[]{"Agrego un valor de catalogo", "bi-tags", "text-warning"};
            default:                         return new String[]{accion, "bi-info-circle", "text-secondary"};
        }
    }

    /** "hace 5 min" / "hace 3 h" / "hace 2 d" sin usar System.* (bug conocido
     *  de este Tomcat con JDK 17: cualquier JSP que referencie System no compila). */
    String tiempoRelativo(java.sql.Timestamp ts) {
        long ahora = new java.util.Date().getTime();
        long minutos = (ahora - ts.getTime()) / 60000;
        if (minutos < 1) return "justo ahora";
        if (minutos < 60) return "hace " + minutos + " min";
        long horas = minutos / 60;
        if (horas < 24) return "hace " + horas + " h";
        long dias = horas / 24;
        return "hace " + dias + " d";
    }
%>

<div class="seccion-titulo text-start mb-4">
    <h3 class="panel-titulo mb-1"><i class="bi bi-shield-check"></i> Auditoria de la aplicacion</h3>
    <p class="text-muted mb-0">Registro de accesos y cambios: quien hizo que y cuando.</p>
</div>

<%
    try (Connection con = abrirConexion()) {
%>
<!-- ================= KPIs ================= -->
<div class="row g-3 mb-4">
<%
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM auditoria");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            out.println("<div class=\"col-6 col-lg-3\"><div class=\"kpi-card kpi-verde d-flex align-items-center gap-3\">"
                + "<i class=\"bi bi-journal-text\" style=\"font-size:1.7rem;opacity:0.85;\"></i>"
                + "<div><div class=\"kpi-valor\">" + rs.getLong(1) + "</div><div class=\"kpi-label\">Eventos totales</div></div></div></div>");
        }
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM auditoria WHERE DATE(fecha_hora)=CURDATE()");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            out.println("<div class=\"col-6 col-lg-3\"><div class=\"kpi-card kpi-dorado d-flex align-items-center gap-3\">"
                + "<i class=\"bi bi-calendar-day\" style=\"font-size:1.7rem;opacity:0.85;\"></i>"
                + "<div><div class=\"kpi-valor\">" + rs.getLong(1) + "</div><div class=\"kpi-label\">Eventos hoy</div></div></div></div>");
        }
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM auditoria WHERE accion='LOGIN_FALLIDO'");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            out.println("<div class=\"col-6 col-lg-3\"><div class=\"kpi-card kpi-azul d-flex align-items-center gap-3\">"
                + "<i class=\"bi bi-shield-exclamation\" style=\"font-size:1.7rem;opacity:0.85;\"></i>"
                + "<div><div class=\"kpi-valor\">" + rs.getLong(1) + "</div><div class=\"kpi-label\">Intentos fallidos</div></div></div></div>");
        }
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(DISTINCT id_usuario) FROM auditoria");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            out.println("<div class=\"col-6 col-lg-3\"><div class=\"kpi-card kpi-gris d-flex align-items-center gap-3\">"
                + "<i class=\"bi bi-people\" style=\"font-size:1.7rem;opacity:0.85;\"></i>"
                + "<div><div class=\"kpi-valor\">" + rs.getLong(1) + "</div><div class=\"kpi-label\">Usuarios con actividad</div></div></div></div>");
        }
%>
</div>

<!-- ================= Filtros ================= -->
<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
    <div class="btn-group">
        <a class="btn btn-sm <%= "1".equals(rango) ? "btn-success" : "btn-outline-success" %>"
           href="<%= ctx %>/admin/auditoria.jsp?rango=1<%= accionFiltro != null ? "&accion="+accionFiltro : "" %>">Hoy</a>
        <a class="btn btn-sm <%= "7".equals(rango) ? "btn-success" : "btn-outline-success" %>"
           href="<%= ctx %>/admin/auditoria.jsp?rango=7<%= accionFiltro != null ? "&accion="+accionFiltro : "" %>">7 dias</a>
        <a class="btn btn-sm <%= "30".equals(rango) ? "btn-success" : "btn-outline-success" %>"
           href="<%= ctx %>/admin/auditoria.jsp?rango=30<%= accionFiltro != null ? "&accion="+accionFiltro : "" %>">30 dias</a>
        <a class="btn btn-sm <%= "todo".equals(rango) ? "btn-success" : "btn-outline-success" %>"
           href="<%= ctx %>/admin/auditoria.jsp?rango=todo<%= accionFiltro != null ? "&accion="+accionFiltro : "" %>">Todo</a>
    </div>
    <form method="get" action="<%= ctx %>/admin/auditoria.jsp" class="d-flex align-items-center gap-2">
        <input type="hidden" name="rango" value="<%= escapar(rango) %>">
        <label class="small text-muted mb-0">Tipo de evento</label>
        <select name="accion" class="form-select form-select-sm" style="width:auto;" onchange="this.form.submit()">
            <option value="">Todos</option>
            <%
                String[] acciones = {"LOGIN","LOGIN_FALLIDO","REGISTRO","CAMBIAR_CLAVE","CREAR_PROPIEDAD",
                    "EDITAR_PROPIEDAD","BAJA_PROPIEDAD","AGENDAR_CITA","CAMBIAR_ESTADO_CITA","RADICAR_SOLICITUD",
                    "CAMBIAR_ESTADO_SOLICITUD","MARCAR_FAVORITO","CAMBIAR_ROL","CAMBIAR_ESTADO_USUARIO","AGREGAR_CATALOGO"};
                for (String a : acciones) {
                    String sel = a.equals(accionFiltro) ? "selected" : "";
                    String[] info = descripcionAccion(a);
            %>
            <option value="<%= a %>" <%= sel %>><%= info[0] %></option>
            <% } %>
        </select>
    </form>
</div>

<!-- ================= Lista de eventos ================= -->
<div class="reporte-card">
<%
        StringBuilder sql = new StringBuilder(
            "SELECT a.*, pf.nombres, pf.apellidos FROM auditoria a " +
            "LEFT JOIN perfil pf ON pf.id_usuario = a.id_usuario WHERE 1=1 ");
        java.util.List<Object> params = new java.util.ArrayList<>();
        if (!"todo".equals(rango)) {
            sql.append(" AND a.fecha_hora >= DATE_SUB(NOW(), INTERVAL ? DAY) ");
            params.add(Integer.parseInt(rango));
        }
        if (accionFiltro != null && !accionFiltro.isEmpty()) {
            sql.append(" AND a.accion = ? ");
            params.add(accionFiltro);
        }
        sql.append(" ORDER BY a.fecha_hora DESC LIMIT 200");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                boolean alguna = false;
                while (rs.next()) {
                    alguna = true;
                    String usuarioTexto = rs.getString("nombres") != null
                        ? escapar(rs.getString("nombres")) + " " + escapar(rs.getString("apellidos"))
                        : "(usuario eliminado)";
                    String[] info = descripcionAccion(rs.getString("accion"));
                    java.sql.Timestamp ts = rs.getTimestamp("fecha_hora");
%>
    <div class="auditoria-item">
        <div class="auditoria-icono <%= info[2] %>"><i class="bi <%= info[1] %>"></i></div>
        <div class="auditoria-cuerpo">
            <div class="d-flex justify-content-between flex-wrap gap-2">
                <div>
                    <strong><%= info[0] %></strong>
                    <span class="text-muted">&middot; <%= usuarioTexto %></span>
                </div>
                <div class="text-end">
                    <span class="text-muted small" title="<%= ts %>"><%= tiempoRelativo(ts) %></span>
                </div>
            </div>
            <div class="text-muted small"><%= escapar(rs.getString("detalle")) %></div>
        </div>
    </div>
<%
                }
                if (!alguna) {
%>
    <p class="text-center text-muted py-4 mb-0">No hay eventos con estos filtros.</p>
<%
                }
            }
        } catch (SQLException ex) {
%>
    <p class="text-danger">Error: <%= escapar(ex.getMessage()) %></p>
<% } %>
</div>

<% } catch (SQLException ex) { %>
    <p class="text-danger">Error de conexion: <%= escapar(ex.getMessage()) %></p>
<% } %>

<%@ include file="/WEB-INF/jspf/pieInmobiliaria.jspf" %>
