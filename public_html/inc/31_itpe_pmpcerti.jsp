<%@ page import="java.io.IOException" %>
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../init.jsp" %><%
	
	try {
		Process proc = Runtime.getRuntime().exec("pwd");
		BufferedReader br = new BufferedReader(new InputStreamReader(proc.getInputStream()));
		String line = br.readLine();
		br.close();

		String[] arr = line.split("\t");
		out.print(arr[0]);
	} catch(RuntimeException re) {
		out.print("RuntimeException - " + re.getMessage());
	} catch(IOException ioe) {
		out.print("IOException - " + ioe.getMessage());
	} catch(Exception e) {
		out.print("Exception - " + e.getMessage());
	}
	

%>