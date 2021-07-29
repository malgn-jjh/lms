<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %>
<%@ page import="malgnsoft.json.*" %>
<%@ page import="ua_parser.Parser" %>
<%@ page import="ua_parser.Client" %>
<%
    //String uaString = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B206 Safari/7534.48.3";

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

    DataSet test = new DataSet();
    test.addRow();
    test.put("hello", "world");
    test.put("foo", 1001);

    JSONObject json = new JSONObject();
    json.put("dataSet", test);
    out.println(json.toString());


%>