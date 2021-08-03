<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %>
<%@ page import="malgnsoft.json.*" %>
<%@ page import="ua_parser.Parser" %>
<%@ page import="ua_parser.Client" %>
<%
    String uaString = request.getHeader("user-agent");
    Parser uaParser = new Parser();
    Client c = uaParser.parse(uaString);

    m.p(uaString);

    out.println("UA-FAMILY : " + c.userAgent.family + "<br>");
    out.println("UA-MAJOR : " + c.userAgent.major + "<br>");
    out.println("UA-MINOR : " + c.userAgent.minor + "<br>");
    out.println("OS-FAMILY : " + c.os.family + "<br>");
    out.println("OS-MAJOR : " + c.os.major + "<br>");
    out.println("OS-MINOR : " + c.os.minor + "<br>");
    out.println("DEVICE-FAMILY : " + c.device.family);
%>