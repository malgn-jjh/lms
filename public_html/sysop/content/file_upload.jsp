<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

//폼입력
String lid = m.rs("lid");
String allow = m.rs("allow", "media,file");

//객체
BoardDao board = new BoardDao();
FileDao file = new FileDao();

//파일이 업로드된 경우
File attFile = f.saveFile("filename");

if(m.isPost() && attFile != null) {

	file.item("module", "lesson");
	file.item("module_id", lid);
	file.item("site_id", siteId);
	file.item("file_nm", f.getFileName("filename"));
	file.item("filename", f.getFileName("filename"));
	file.item("filetype", f.getFileType("filename"));
	file.item("filesize", attFile.length());
	file.item("realname", attFile.getName());
	file.item("main_yn", "N");
	file.item("reg_date", m.time("yyyyMMddHHmmss"));
	file.item("status", 1);
	file.insert();

	out.print("{\"success\":true}");
	return;
}

//제한 확장자
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

//출력
p.setRoot(Config.getDocRoot() + "/sysop/html");
p.setLayout("blank");
p.setBody("content.file_upload");
p.setVar("p_title", "파일 첨부");
p.setVar("lid", lid);
p.setVar("web_url", webUrl);
//p.setVar("max_file_size", Config.getInt("maxPostSize") * 1024);
p.setVar("max_file_size", 100 * 1024);
p.setVar("limit_block", !"".equals(limitExt));
p.setVar("limit_ext", limitExt);
p.setVar("limit_ext_conv", limitExtConv);
p.display();

%>