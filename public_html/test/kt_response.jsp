<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%@ page import="malgnsoft.json.*" %><%
//폼체크

f.setDebug(out);

if(m.isPost() && f.validate()) {

    return;
}
%>