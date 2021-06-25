<%@ include file="../init.jsp" %><%@ page import="org.apache.commons.net.ftp.*" %><%

//접근권한
if(!Menu.accessible(47, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

String ch = "sysop";
String ftpHost = "192.168.10.214";
String ftpId = siteinfo.s("ftp_id");
String ftpPw = siteinfo.s("ftp_pw");
int ftpPort = 2121;

if(isDevServer) {
    ftpHost = "localhost";
    //ftpId = "intern";
    //ftpPw = "OHrXQqC0Y7";
    ftpPort = 21;
}

%>