<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../../init.jsp" %><%

//폼입력
String mid = m.rs("mid");
String md = m.rs("md", "post");

//객체
ClFileDao clFile = new ClFileDao();

//파일이 업로드된 경우
File attFile = f.saveFile("filename");

if(attFile != null) {

	String orgname = f.getFileName("filename");
	String fileName = orgname;
	for(int i=1; i<100; i++) {
		if(clFile.findCount("module_id = " + mid + " AND filename = '" + m.addSlashes(fileName) + "' AND status = 1") > 0) {
			fileName = "(" + i + ")" + orgname;
		} else { break; }
	}

	clFile.item("site_id", siteId);
	clFile.item("module", md);
	clFile.item("module_id", mid);
	clFile.item("filename", fileName);
	clFile.item("realname", attFile.getName());
	clFile.item("filetype", f.getFileType("filename"));
	clFile.item("filesize", attFile.length());
	clFile.item("main_yn", "N");
	clFile.item("reg_date", m.time("yyyyMMddHHmmss"));
	clFile.item("status", 1);
	clFile.insert();

	return;
}

//제한 확장자
String limitExt = "|exe|jsp|asp|aspx|php|php3|html";
String limitExtConv = "";
limitExt = !"".equals(limitExt)? m.replace(limitExt.substring(1), "|", ";") : "";
limitExtConv = m.replace(limitExt, ";", ", ");
limitExt += ";" + limitExt.toUpperCase();

//출력
p.setRoot(Config.getDocRoot() + "/sysop/html");
p.setLayout("blank");
p.setBody("cpost.file_upload");
p.setVar("p_title", "파일 첨부");
p.setVar("md", md);
p.setVar("mid", mid);
p.setVar("web_url", Config.getWebUrl());
p.setVar("max_file_size", Config.getInt("maxPostSize") * 1024);
p.setVar("limit_ext", limitExt);
p.setVar("limit_ext_conv", limitExtConv);
p.display();

%>