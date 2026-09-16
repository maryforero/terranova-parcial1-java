package com.terranova.filter;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Filtro de control de acceso por rol para el proyecto TerraNova
 * (Parcial Práctico - Programación Java).
 *
 * Se registra en /WEB-INF/web.xml con url-pattern "/Parcial 1/Inmobiliaria/*".
 * Es la unica fuente de verdad del control de acceso: la interfaz oculta
 * botones/menus segun el rol solo por comodidad visual, pero si alguien
 * escribe la URL directamente este filtro es quien realmente bloquea.
 *
 * Regla de negocio: cada ruta protegida exige que la sesion tenga un
 * usuario autenticado (atributo "idUsuario") y, opcionalmente, que el
 * conjunto de roles de sesion (atributo "roles") contenga al menos uno
 * de los roles permitidos para esa ruta.
 */
public class AccesoFilter implements Filter {

    private static final String BASE = "/Parcial 1/Inmobiliaria/";

    /** Una regla de acceso: prefijo o ruta exacta -> roles permitidos (null = solo exige login). */
    private static final class Regla {
        final String ruta;
        final boolean prefijo;
        final Set<String> roles; // null = cualquier usuario autenticado

        Regla(String ruta, boolean prefijo, String... roles) {
            this.ruta = ruta;
            this.prefijo = prefijo;
            this.roles = (roles == null || roles.length == 0)
                    ? null
                    : new HashSet<>(Arrays.asList(roles));
        }

        boolean coincide(String subRuta) {
            return prefijo ? subRuta.startsWith(ruta) : subRuta.equals(ruta);
        }
    }

    // El orden importa: la primera regla que coincida es la que aplica.
    private static final Regla[] REGLAS = new Regla[] {
        new Regla("citas/agendar.jsp",           false, "CLIENTE"),
        new Regla("citas/guardarCita.jsp",        false, "CLIENTE"),
        // cambiarEstado.jsp lo usan tanto el agente/admin (confirmar/rechazar/marcar
        // realizada) como el cliente (cancelar su propia cita): solo exige login,
        // la propiedad y el rol de cada quien se valida dentro de la pagina.
        new Regla("citas/cambiarEstado.jsp",      false),
        new Regla("citas/",                       true),

        new Regla("solicitudes/radicar.jsp",        false, "CLIENTE"),
        new Regla("solicitudes/guardarSolicitud.jsp", false, "CLIENTE"),
        new Regla("solicitudes/subirDocumento.jsp", false, "CLIENTE"),
        new Regla("solicitudes/cambiarEstado.jsp",  false, "ADMINISTRADOR", "INMOBILIARIA"),
        new Regla("solicitudes/",                   true),

        new Regla("propiedades/",  true, "ADMINISTRADOR", "INMOBILIARIA"),
        new Regla("favoritos/",    true, "CLIENTE"),
        new Regla("reportes/",     true, "ADMINISTRADOR", "INMOBILIARIA"),
        new Regla("admin/",        true, "ADMINISTRADOR"),
        new Regla("perfil/",       true),

        new Regla("panel/panelAdmin.jsp",        false, "ADMINISTRADOR"),
        new Regla("panel/panelInmobiliaria.jsp", false, "INMOBILIARIA"),
        new Regla("panel/panelCliente.jsp",      false, "CLIENTE"),
    };

    @Override
    public void init(FilterConfig filterConfig) { }

    @Override
    public void destroy() { }

    @Override
    @SuppressWarnings("unchecked")
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String servletPath = request.getServletPath();
        String subRuta = servletPath.startsWith(BASE)
                ? servletPath.substring(BASE.length())
                : servletPath;

        Regla regla = buscarRegla(subRuta);

        if (regla == null) {
            // Ruta publica (landing, catalogo, login, registro, css/js, etc.)
            chain.doFilter(req, res);
            return;
        }

        HttpSession sesion = request.getSession(false);
        Object idUsuario = (sesion != null) ? sesion.getAttribute("idUsuario") : null;

        if (idUsuario == null) {
            String destino = request.getContextPath() + BASE.replace(" ", "%20") + "login.jsp";
            response.sendRedirect(destino);
            return;
        }

        if (regla.roles != null) {
            Set<String> rolesSesion = (Set<String>) sesion.getAttribute("roles");
            boolean autorizado = rolesSesion != null && !java.util.Collections.disjoint(rolesSesion, regla.roles);
            if (!autorizado) {
                String destino = request.getContextPath() + BASE.replace(" ", "%20") + "accesoDenegado.jsp";
                response.sendRedirect(destino);
                return;
            }
        }

        chain.doFilter(req, res);
    }

    private Regla buscarRegla(String subRuta) {
        for (Regla r : REGLAS) {
            if (r.coincide(subRuta)) return r;
        }
        return null;
    }
}
