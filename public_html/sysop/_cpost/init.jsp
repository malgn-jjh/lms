<%@ include file="../init.jsp" %><%

String ch = "sysop";

// 1. 공지사항, 2. 의견나눔 3. 방명록, 4. 수강후기, -100. 1:1상담신청, -200. 성적이의신청, -300. 콘텐츠오류신고
int bType = m.ri("bt", 1);

%>