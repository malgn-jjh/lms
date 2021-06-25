<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

String dir = m.rs("dir");
String file = m.rs("file");
if(dir.startsWith("/public_html")) dir = dir.replace("/public_html", "");

String path = siteinfo.s("doc_root") + dir + "/" + file;
File f1 = new File(path);
if(f1.exists()) m.download(path, file, 500);
else if(new File(m.replace(path, "/public_html", "")).exists()) m.download(m.replace(path, "/public_html", ""), file, 500);
else m.jsAlert(_message.get("alert.common.nofile"));

%>