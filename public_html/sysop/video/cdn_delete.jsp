<%@ page contentType="text/html; charset=utf-8" %><%@ page import="org.apache.commons.net.ftp.*" %><%@ include file="../../init.jsp" %><%

if("".equals(siteinfo.s("cdn_ftp"))) {
	out.print("FTP 정보가 없습니다.");
	return;
}

String dir = m.rs("dir");
String file = m.rs("file");
String[] arr = m.split("|", siteinfo.s("cdn_ftp"));

//목록
FTPClient ftp = new FTPClient();
try {
	ftp.setControlEncoding("utf-8");
	ftp.connect(arr[0]);
	ftp.enterLocalPassiveMode();
	ftp.login(arr[1], arr[2]);
	if(!"".equals(dir)) ftp.changeWorkingDirectory(dir);

	boolean ret = file.indexOf(".") != -1 ? ftp.deleteFile(file) : ftp.removeDirectory(file);

	ftp.logout();
	ftp.disconnect();

	out.print(ret ? "success" : "파일 삭제 실패");
} catch(Exception e) {
	m.log("ftp", e.toString());
	out.print("파일 삭제시 오류가 발생했습니다. " + e.toString());
}

%>