<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

if(!Menu.accessible(31, userId, userKind) && !Menu.accessible(30, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

String prePage = m.getCookie("PREPAGE20");
String rCD =  m.rs("cd");
String query = "";
if("".equals(rCD)) rCD = "MEDIA";

if(!"".equals(prePage)) {
	String tmpStr = m.split("\\?", prePage, 2)[1];
	String[] queries = m.replace(m.replace(tmpStr, "<", "&lt;"), ">", "&gt;").split("\\&");

	for(int i=0; i<queries.length; i++) {
		String[] attributes = queries[i].split("\\=");
		if(attributes.length > 0 && m.inArray(attributes[0], "cd")) continue;
		query += "&" + queries[i];
	}
}
prePage = "choice_right.jsp?cd=" + m.rs("cd") + query;


%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%= Config.get("windowTitle") %></title>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<meta http-equiv="imagetoolbar" content="no">
<meta http-equiv="Expires" content="-1" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Cache-Control" content="no-cache" />

<frameset rows="50,*" frameborder="0" border="0" bordercolor="#eeeeee">
	<frame src="choice_top.jsp" name="_TOP" id="_TOP" scrolling="no" noresize></frame>
	<frameset cols="250,*">
		<frame src="<%= "choice_left.jsp?cd=" + m.rs("cd") %>" name="_LEFT" id="_LEFT" scrolling="auto" noresize></frame>
		<frame src="<%= prePage %>" name="_RIGHT" id="_RIGHT" scrolling="auto"></frame>
	</frameset>
</frameset>