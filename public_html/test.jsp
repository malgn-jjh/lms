<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%@ page import="malgnsoft.json.*" %><%
    SiteCookie siteCookie = new SiteCookie(request, response);
    m.p(siteCookie.getData());

%>