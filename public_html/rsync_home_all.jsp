<%@ page contentType="text/html; charset=utf-8" %><%@ page import="java.util.*,java.io.*,java.net.*" %><%
//IP
if(!"115.91.52.203".equals(request.getRemoteAddr())
	&& !"125.128.232.145".equals(request.getRemoteAddr())
	&& !"39.117.181.5".equals(request.getRemoteAddr())
	&& !"116.121.14.96".equals(request.getRemoteAddr())
	&& !"118.37.156.250".equals(request.getRemoteAddr())
	&& !"59.5.222.106".equals(request.getRemoteAddr())
) {
	return;
}
%><!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<title>싱크</title>
</head>
<body>
<%
if("POST".equals(request.getMethod())) {
	if(!"floz09!@".equals(request.getParameter("password"))) {
		out.println("<p>암호가 올바르지 않습니다.</p>");
	} else {

		String path;
		path = "/root/rsync_home_all.sh";

		InetAddress addr = InetAddress.getLocalHost();
		String hostname = addr.getHostName();

		out.print(hostname + "<br>");

		try {
			String line;
			Process proc = Runtime.getRuntime().exec(path);
			BufferedReader input = new BufferedReader(new InputStreamReader(proc.getInputStream()));

			while((line = input.readLine()) != null) {
				out.println(line + "<br>");
			}

			input.close();
		} catch(Exception ex) {
			out.println(ex.getMessage());
		}
	}
}
%>
<form name="form1" method="post">
<hr>
싱크암호<br>
<input type="password" name="password" required="required">
<button type="submit">싱크</button>
</form>
</body>
</html>