<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%@ page import="malgnsoft.json.*" %><%

//폼체크
f.addElement("url", "ㅁㄴㅇㅁㄴ", null);
f.addElement("token", null, null);
f.addElement("data", null, null);

String serviceId = "DEV_TH_MALGNSOFT";
String tokenTime = System.currentTimeMillis() + "";
String serviceIp = "0.0.0.0";
String authHash = "service_id=" + serviceId + "&time" + tokenTime + "&service_ip=" + serviceIp;

JSONObject jsonObject = new JSONObject();
jsonObject.put("serviceId", serviceId);
jsonObject.put("tokenTime", tokenTime);
jsonObject.put("authHash", m.sha256(authHash));

Http http = new Http("https://211.253.11.217:30126/v2/link/auth");
http.setDebug(out);
http.setHeader("Content-Type", "application/json");
http.setData(jsonObject.toString());
String jstr = http.send("POST");

if(m.isPost()) {
    p.setVar("result", jstr);
}

//출력
p.setLayout(null);
p.setBody("test.kt_remote");

p.setVar("p_title", "랜선에듀 API");
p.setVar("form_script", f.getScript());

p.display();
%>