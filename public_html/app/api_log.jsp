<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../init.jsp" %><%

String file = "api_" + m.time("yyyyMMdd") + ".log";

out.print("<pre>");
out.print(m.readFile(dataDir + "/log/" + file));

%>