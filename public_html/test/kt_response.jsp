<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%@ page import="malgnsoft.json.*" %><%

KtRemoteDao ktRemote = new KtRemoteDao();

if(m.isPost() && f.validate()) {

    Http http = new Http(f.get("url"));
    http.setDebug(out);
    http.setHeader("Content-Type", "application/json");
    if(!"".equals(f.get("token"))) http.setHeader("Authorization", "Bearer " + f.get("token"));
    http.setData(f.get("data"));
    String jstr = http.send("POST");

    out.print(jstr);
}

%>