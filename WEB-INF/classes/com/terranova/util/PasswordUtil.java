package com.terranova.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

/**
 * Hash de contraseñas con SHA-256 + salt aleatorio por usuario
 * (cumple el requisito del parcial: "SHA-256 con salt", nunca texto plano).
 * hash = SHA256(salt + ":" + clave), representado en hexadecimal.
 */
public final class PasswordUtil {

    private static final SecureRandom RNG = new SecureRandom();

    private PasswordUtil() { }

    public static String generarSalt() {
        byte[] bytes = new byte[16];
        RNG.nextBytes(bytes);
        return aHex(bytes);
    }

    public static String calcularHash(String salt, String claveTextoPlano) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update((salt + ":" + claveTextoPlano).getBytes("UTF-8"));
            return aHex(md.digest());
        } catch (NoSuchAlgorithmException | java.io.UnsupportedEncodingException ex) {
            throw new RuntimeException("No se pudo calcular el hash de la clave", ex);
        }
    }

    public static boolean verificar(String claveTextoPlano, String salt, String hashEsperado) {
        String calculado = calcularHash(salt, claveTextoPlano);
        return constantTimeEquals(calculado, hashEsperado);
    }

    /** Comparacion en tiempo constante para evitar timing attacks sobre el hash. */
    private static boolean constantTimeEquals(String a, String b) {
        if (a == null || b == null || a.length() != b.length()) return false;
        int resultado = 0;
        for (int i = 0; i < a.length(); i++) {
            resultado |= a.charAt(i) ^ b.charAt(i);
        }
        return resultado == 0;
    }

    private static String aHex(byte[] datos) {
        StringBuilder sb = new StringBuilder(datos.length * 2);
        for (byte b : datos) {
            sb.append(Character.forDigit((b >> 4) & 0xF, 16));
            sb.append(Character.forDigit(b & 0xF, 16));
        }
        return sb.toString();
    }
}
