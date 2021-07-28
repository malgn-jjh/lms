<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../../init.jsp" %><%

//���Է�
String mid = m.rs("mid");
String md = m.rs("md", "post");
String allow = m.rs("allow", "image,media,file");

//��ü
BoardDao board = new BoardDao();
FileDao file = new FileDao();

//������ ���ε�� ���
File attFile = f.saveFile("filename");

if(attFile != null) {

	file.item("module", md);
	file.item("module_id", mid);
	file.item("site_id", siteId);
	file.item("filename", f.getFileName("filename"));
	file.item("filetype", f.getFileType("filename"));
	file.item("filesize", attFile.length());
	file.item("realname", attFile.getName());
	file.item("main_yn", "N");
	file.item("reg_date", m.time("yyyyMMddHHmmss"));
	file.item("status", 1);
	file.insert();

	//���ϸ�����¡
	try {
		if(f.getFileName("filename").matches("(?i)^.+\\.(jpg|png|gif|bmp)$")) {
			String imgPath = m.getUploadPath(f.getFileName("filename"));
			String cmd = "convert -resize 700x " + imgPath + " " + imgPath;
			Runtime.getRuntime().exec(cmd);
		}
	}
	catch(RuntimeException re) { m.errorLog("RuntimeException : " + re.getMessage(), re); }
	catch(Exception e) { m.errorLog("Exception : " + e.getMessage(), e); }

	return;
}

//���� Ȯ����
String limitExt = "|jpg|jpeg|gif|png|swf|mp4|flv|mov|qt|mpeg|wmv|wma|asf|mp3|avi|wmp|rmp|ra";
String limitExtConv = "";
String[] allows = !"".equals(allow) ? allow.split("\\,") : null;
if(null != allows) {
	for(int i=0; i<allows.length; i++) {
		if(!"file".equals(allows[i])) {
			limitExt = m.replace(limitExt, m.getItem(allows[i], board.extTypes), "");
		}
	}
	limitExt += "|exe|jsp|asp|aspx|php|php3|html";
	limitExt = !"".equals(limitExt)? m.replace(limitExt.substring(1), "|", ";") : "";
	if(!"".equals(limitExt)) {
		limitExtConv = m.replace(limitExt, ";", ", ");
		limitExt += ";" + limitExt.toUpperCase();
	}
}

//���
p.setRoot(Config.getDocRoot() + "/sysop/html");
p.setLayout("blank");
p.setBody("content.file_upload");
p.setVar("p_title", "���� ÷��");
p.setVar("md", md);
p.setVar("mid", mid);
p.setVar("web_url", webUrl);
//p.setVar("max_file_size", Config.getInt("maxPostSize") * 1024);
p.setVar("max_file_size", 100 * 1024);
p.setVar("limit_block", !"".equals(limitExt));
p.setVar("limit_ext", limitExt);
p.setVar("limit_ext_conv", limitExtConv);
p.display();

%>