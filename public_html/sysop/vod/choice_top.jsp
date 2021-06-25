<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

if(!Menu.accessible(31, userId, userKind) && !Menu.accessible(30, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//출력
p.setLayout("blank");
p.setBody("vod.choice_top");
p.display(out);

%>