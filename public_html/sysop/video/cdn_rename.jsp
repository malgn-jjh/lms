<%@ page contentType="text/html; charset=utf-8" %><%@ page import="org.apache.commons.net.ftp.*" %>
<%@ page import="java.io.UnsupportedEncodingException" %>
<%@ include file="../../init.jsp" %><%

if("".equals(siteinfo.s("cdn_ftp"))) {
	out.print("FTP 정보가 없습니다.");
	return;
}

String dir = m.rs("dir");
String file = m.rs("file");
String name = m.rs("name");
String[] arr = m.split("|", siteinfo.s("cdn_ftp"));

//목록
FTPClient ftp = new FTPClient();
try{
	ftp.setControlEncoding("utf-8");
	ftp.connect(arr[0]);
	ftp.enterLocalPassiveMode();
	ftp.login(arr[1], arr[2]);
	if(!"".equals(dir)) ftp.changeWorkingDirectory(dir);

	boolean ret = ftp.rename(file, name);

	ftp.logout();
	ftp.disconnect();

	out.print(ret ? "success" : "폴더 생성 실패");
} catch(UnsupportedEncodingException uee) {
	m.log("ftp", uee.toString());
	out.print("폴더 생성시 오류가 발생했습니다. " + uee.toString());
}catch(Exception e) {
	m.log("ftp", e.toString());
	out.print("폴더 생성시 오류가 발생했습니다. " + e.toString());
}
%>