<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

String dir = m.rs("dir");
String file = m.rs("file");
String name = m.rs("name");

//목록
FTPClient ftp = new FTPClient();
try {
	ftp.setControlEncoding("utf-8");
	ftp.connect(ftpHost, ftpPort);
	ftp.enterLocalPassiveMode();
	ftp.login(ftpId, ftpPw);
	if(!"".equals(dir)) ftp.changeWorkingDirectory(dir);

	boolean ret = ftp.rename(file, name);

	ftp.logout();
	ftp.disconnect();

	out.print(ret ? "success" : "파일명 변경 실패");
} catch(Exception e) {
	m.log("ftp", e.toString());
	out.print("파일명 변경시 오류가 발생했습니다. " + e.toString());
}

%>