<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../init.jsp" %><%

//출력
p.setLayout(null);
p.setBody("inc.66_itbc_rate");

p.setVar("SITE_CONFIG", SiteConfig.getArr("itbc_rate_"));
p.display();

%>