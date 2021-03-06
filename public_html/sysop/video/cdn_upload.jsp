<%@ page contentType="text/html; charset=utf-8" %><%@ page import="org.apache.commons.net.ftp.*" %>
<%@ page import="java.io.IOException" %>
<%@ include file="../../init.jsp" %><%

if("".equals(siteinfo.s("cdn_ftp"))) {
	m.redirect("choice.jsp?" + m.qs());
	return;
}

String dir = m.rs("dir");
String parentDir = (!"".equals(dir) ? dir.substring(0, dir.lastIndexOf("/")) : "");
String[] arr = m.split("|", siteinfo.s("cdn_ftp"));

f.uploadDir = Config.getDataDir() + "/ftp";
f.denyExt(new String[] {"jsp", "jspx", "php", "asp", "aspx"});
File attFile = f.saveFile("filename");
if(attFile != null) {

	//목록
	FTPClient ftp = new FTPClient();
	try{
		ftp.setControlEncoding("utf-8");
		ftp.connect(arr[0]);
		ftp.enterLocalPassiveMode();
		ftp.login(arr[1], arr[2]);
		if(!"".equals(dir)) ftp.changeWorkingDirectory(dir);

		ftp.setFileType(FTP.BINARY_FILE_TYPE);

		FileInputStream fis = new FileInputStream(attFile);
		ftp.storeFile(m.replace(f.getFileName("filename"), " ", "_"), fis);

		ftp.logout();
		ftp.disconnect();
	}catch(IOException ioe) {
		out.print("{\"success\":false, \"error\":\"파일을 업로드 하는 중 오류가 발생했습니다.\", \"reset\":true}");
		m.log("ftp", ioe.toString());
		return;
	}catch(Exception e) {
		out.print("{\"success\":false, \"error\":\"파일을 업로드 하는 중 오류가 발생했습니다.\", \"reset\":true}");
		m.log("ftp", e.toString());
		return;
	}
	attFile.delete();
	out.print("{\"success\":true}");
	return;
}

//제한 확장자
String limitExt = "|exe|jsp|asp|aspx|php|php3";
String limitExtConv = "";
limitExt = !"".equals(limitExt)? m.replace(limitExt.substring(1), "|", ";") : "";
if(!"".equals(limitExt)) {
	limitExtConv = m.replace(limitExt, ";", ", ");
	limitExt += ";" + limitExt.toUpperCase();
}

//출력
p.setRoot(Config.getDocRoot() + "/sysop/html");
p.setLayout("poplayer");
p.setBody("video.cdn_upload");
p.setVar("p_title", "파일 업로드");
p.setVar("query", m.qs());
p.setVar("max_file_size", Config.getInt("maxPostSize") * 1024);
p.setVar("limit_block", !"".equals(limitExt));
p.setVar("limit_ext", limitExt);
p.setVar("limit_ext_conv", limitExtConv);
p.display();

%>