<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%@ page import="malgnsoft.json.*" %><%
KtRemoteDao ktremote = new KtRemoteDao(siteId);
out.print(ktremote.getAuthToken());
%>