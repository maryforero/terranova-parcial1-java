package com.terranova.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Conexion JDBC centralizada para los Servlets del proyecto TerraNova
 * (Parcial Practico Programacion Java). Replica exactamente la logica de
 * WEB-INF/jspf/conexionInmobiliaria.jspf, que sigue usando cualquier JSP
 * de solo-vista (un Servlet no puede incluir un .jspf, que se compila como
 * metodos del servlet generado por Jasper para cada JSP que lo incluye).
 */
public final class ConexionUtil {

    private ConexionUtil() { }

    public static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    public static final String DB_URL =
        "jdbc:mysql://localhost:3306/inmobiliaria_terranova"
        + "?useSSL=false&allowPublicKeyRetrieval=true"
        + "&serverTimezone=America/Bogota&characterEncoding=UTF-8";
    public static final String DB_USUARIO = "root";
    public static final String DB_CLAVE   = "";

    public static Connection abrirConexion() throws SQLException {
        try {
            Class.forName(DB_DRIVER);
        } catch (ClassNotFoundException ex) {
            throw new SQLException(
                "No se encontro el driver de MySQL. Agregue mysql-connector-j-x.x.x.jar "
                + "a la carpeta WEB-INF/lib del proyecto.", ex);
        }
        return DriverManager.getConnection(DB_URL, DB_USUARIO, DB_CLAVE);
    }

    public static void cerrar(AutoCloseable... recursos) {
        for (int i = recursos.length - 1; i >= 0; i--) {
            if (recursos[i] != null) {
                try { recursos[i].close(); } catch (Exception ignorada) { }
            }
        }
    }

    public static void deshacer(Connection con) {
        if (con != null) {
            try { con.rollback(); } catch (SQLException ignorada) { }
        }
    }
}
