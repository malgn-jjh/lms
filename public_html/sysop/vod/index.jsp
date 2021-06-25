<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

if(!Menu.accessible(31, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

%><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%= Config.get("windowTitle") %></title>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<meta http-equiv="imagetoolbar" content="no">
<meta http-equiv="Expires" content="-1" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Cache-Control" content="no-cache" />

<frameset rows="50,*" frameborder="0" border="0" bordercolor="#eeeeee">
	<frame src="top.jsp" name="_TOP" id="_TOP" scrolling="no" noresize></frame>
	<frameset cols="300,*">
		<frame src="left.jsp" name="_LEFT" id="_LEFT" scrolling="auto" noresize></frame>
		<frameset id="_RIGHT_FRAMESET" name="_RIGHT_FRAMESET" rows="*,0">
			<frame src="<%= !"".equals(m.getCookie("PREPAGE10")) ? m.getCookie("PREPAGE10") : "right.jsp" %>" name="_RIGHT" id="_RIGHT" scrolling="auto"></frame>
			<frame src="upload.jsp" name="_UPLOAD" id="_UPLOAD" scrolling="no" noresize></frame>
		</frameset>
	</frameset>
</frameset>