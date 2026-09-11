<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath() + "/Parcial%201/Inmobiliaria";
    session.invalidate();
    response.sendRedirect(ctx + "/index.jsp");
%>
