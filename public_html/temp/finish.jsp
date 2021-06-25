<%@ page contentType = "text/html;charset=utf-8"%>
<%@ page import="java.util.*" %>
<%
	request.setCharacterEncoding("utf-8");
	
	//결제 응답 파라미터
	String rescode = request.getParameter("rescode");
	String resmsg = request.getParameter("resmsg");

	
	out.println("rescode : " + rescode + "<br/>");
	out.println("resmsg : " + resmsg + "<br/>");


	
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<body>
Done<br/>
<input type=button value="Retry" onclick="javascript:document.location.href='payment.html';">
</body>
</html>