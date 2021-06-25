<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%



//출력
p.setLayout("mobile");
p.setBody("mobile.index");
p.setVar("is_android", isAndroid);
p.setVar("is_ios", isIOS);
p.display();

%>