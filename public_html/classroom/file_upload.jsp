<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

//로그인
if(0 == userId) { auth.loginForm(); return; }

//폼입력
String mid = m.rs("mid");
String md = m.rs("md", "post");
if("".equals(mid)) { m.jsAlert("기본키는 반드시 지정해야 합니다."); return; }

//객체
BoardDao board = new BoardDao();
ClFileDao file = new ClFileDao();

//변수
String allowExt = "jpg|jpeg|gif|png|pdf|hwp|txt|doc|docx|xls|xlsx|ppt|pptx|zip|alz|7z|rar|egg|mp3"; //file.allowExt;
int maxPostSize = 100; //Config.getInt("maxPostSize");

//폼체크
f.addElement("filename", "", "hname:'파일', required:'Y', allow:'" + allowExt + "'");

//업로드
if(m.isPost()) {

	//제한-파일유형
	if(!f.validate()) { out.print("{\"success\":false, \"error\":\"" + f.errMsg + "\", \"reset\":true}"); return; }
	
	//제한-파일크기
	if((maxPostSize * 1024 * 1024) < f.getLong("filesize")) { out.print("{\"success\":false, \"error\":\"100MB를 초과하여 업로드 할 수 없습니다.\", \"reset\":true}"); return; }

	//등록
	File attFile = f.saveFile("filename");
	if(attFile == null) { out.print("{\"success\":false, \"error\":\"파일이 정상적으로 업로드되지 않았습니다.\", \"reset\":true}"); return; }

	file.item("module", md);
	file.item("module_id", mid);
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

	//파일리사이징
	try {
		if(f.getFileName("filename").matches("(?i)^.+\\.(jpg|jpeg|png|gif|bmp)$")) {
			if(300 * 1024 < attFile.length()) { //300KB
				String imgPath = m.getUploadPath(f.getFileName("filename"));
				String cmd = "convert -resize 700x " + imgPath + " " + imgPath;
				Runtime.getRuntime().exec(cmd);

			}
		}
	} catch(Exception e) { }

	out.print("{\"success\":true}");
	return;
}

//제한확장자-NFUploader deprecated
String limitExt = "swf;mp4;flv;mov;qt;mpeg;wmv;wma;asf;mp3;avi;wmp;rmp;ra;exe;jsp;asp;aspx;php;php3;html";
String limitExtConv = m.replace(limitExt, ";", ", ");
limitExt += ";" + limitExt.toUpperCase();

//출력
//p.setRoot(Config.getDocRoot() + "/sysop/html");
p.setLayout("blank");
p.setBody("classroom.file_upload");
p.setVar("p_title", "파일 첨부");
p.setVar("md", md);
p.setVar("mid", mid);
p.setVar("web_url", webUrl);
p.setVar("max_file_size", maxPostSize * 1024);

//NFUploader deprecated
p.setVar("limit_block", !"".equals(limitExt));
p.setVar("limit_ext", limitExt);
p.setVar("limit_ext_conv", limitExtConv);

p.display();

%>