<%@ page import="java.io.UnsupportedEncodingException" %>
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

String dir = m.rs("dir");
String folder = m.rs("folder");

//목록
FTPClient ftp = new FTPClient();
try{
    ftp.setControlEncoding("utf-8");
    ftp.connect(ftpHost, ftpPort);
    ftp.enterLocalPassiveMode();
    ftp.login(ftpId, ftpPw);
    if(!"".equals(dir)) ftp.changeWorkingDirectory(dir);

    boolean ret = ftp.makeDirectory(folder);

    ftp.logout();
    ftp.disconnect();

    out.print(ret ? "success" : "폴더 생성 실패");
}catch(UnsupportedEncodingException uee) {
    m.log("ftp", uee.toString());
    out.print("폴더 생성시 오류가 발생했습니다. " + uee.toString());
}catch(Exception e) {
    m.log("ftp", e.toString());
    out.print("폴더 생성시 오류가 발생했습니다. " + e.toString());
}

%>