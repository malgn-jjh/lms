<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

if(-1 == _session.execute("DELETE FROM " + _session.table + " WHERE id = '" + ssid + "'")) { }

out.print(_return.toString());

%>