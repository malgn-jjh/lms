<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%@ page import="malgnsoft.json.*" %><%
KtRemoteDao ktremote = new KtRemoteDao(siteId);

//String serviceId = "DEV_TH_MALGNSOFT";
//String serviceIp = "0.0.0.0";
//String tokenTime = System.currentTimeMillis() + "";
//String authHash = "service_id=" + serviceId + "&time" + tokenTime + "&service_ip=" + serviceIp;
//
//JSONObject jsonObject = new JSONObject();
//jsonObject.put("serviceId", serviceId);
//jsonObject.put("tokenTime", tokenTime);
//jsonObject.put("authHash", m.sha256(authHash));
//
//Http http = new Http("https://211.253.11.217:30126/v2/link/auth");
//http.setHeader("Content-Type", "application/json");
//http.setData(jsonObject.toString());
//String jstr = http.send("POST");

out.print(ktremote.getAuthToken());
%>