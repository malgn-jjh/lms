<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//변수
String mode = m.rs("mode");
String dir = m.rs("dir", "");
String parentDir = (!"".equals(dir) ? dir.substring(0, dir.lastIndexOf("/")) : "");

//폼체크
f.addElement("s_field", null, null);
f.addElement("s_keyword", null, null);

//변수
String[] ord = m.split(" ", !"".equals(m.rs("ord")) ? m.rs("ord") : "type DESC");
boolean layoutEditBlock = Menu.accessible(45, userId, userKind, false) && dir.equals("/html/layout");
boolean cssEditBlock = Menu.accessible(46, userId, userKind, false) && dir.equals("/html/css");

if("C".equals(userKind) && !dir.startsWith("/" + userId)) dir = "/" + userId;

//목록
DataSet list = new DataSet();
FTPClient ftp = new FTPClient();
//FTPSClient ftp = new FTPSClient();

try {
	ftp.setControlEncoding("utf-8");
	ftp.connect(ftpHost, ftpPort);
	ftp.enterLocalPassiveMode();
	ftp.login(ftpId, ftpPw);
	if(!ftp.changeWorkingDirectory(dir) && !"".equals(dir)) {
		m.jsError(dir + " 폴더에 접근할 수 없습니다.");
		return;
	}

	FTPFile[] files = ftp.listFiles(dir);

	for(int i = 0; i < files.length; i++) {
		String fileName = files[i].getName();
		if(fileName.startsWith(".")) continue;

		if(!"".equals(f.get("s_keyword"))) {
			if("name".equals(f.get("s_field"))) {
				if(!files[i].isDirectory() && 0 > fileName.toLowerCase().indexOf(f.get("s_keyword").toLowerCase())) continue;
			}
		}

		list.addRow();
		list.put("idx", i+1);
		list.put("path", dir + "/" + fileName);
		list.put("path_conv", m.replace(list.s("path"), "/public_html", ""));
		list.put("name", fileName);
		list.put("pname", fileName.replace(".html", "").replace(".css", ""));
		list.put("ext", m.getFileExt(fileName));
		list.put("title", list.s("name").replace("." + list.s("ext"), ""));
		list.put("size", m.getFileSize(files[i].getSize()));
		list.put("reg_date", m.time("yyyy-MM-dd HH:mm", files[i].getTimestamp().getTime()));
		list.put("is_folder", files[i].isDirectory());
		list.put("is_mp4", "mp4".equals(list.s("ext")));
		list.put("is_link", !files[i].isDirectory() && !"mp4".equals(list.s("ext")));
		list.put("type", files[i].isDirectory() ? "폴더" : "파일");
		list.put("edit_block", (layoutEditBlock && list.s("ext").equals("html")) || (cssEditBlock && list.s("ext").equals("css")));
	}
	list.sort(ord[0], ord[1]);

	ftp.logout();
	ftp.disconnect();
} catch(IOException e) {
	m.jsAlert("FTP에 접속하는 중 IO오류가 발생했습니다.1\\n" + m.replace(e.getMessage(), new String[] { "\r\n", "\r", "\n" }, "\\n"));
	return;
} catch(Exception e) {
	m.jsAlert("FTP에 접속하는 중 오류가 발생했습니다.2\\n" + m.replace(e.getMessage(), new String[] { "\r\n", "\r", "\n" }, "\\n"));
	return;
}

//출력
//p.setLayout(ch);
p.setBody("webftp.ftp_list");
p.setLoop("list", list);
//p.setVar("p_title", "디자인파일관리");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("dir,s_field,s_keyword"));
p.setVar("form_script", f.getScript());
p.setVar("list_total", list.size());
p.setVar("dir", dir);
p.setVar("parent_dir", parentDir);
p.display();

%>