<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

String module = m.request("md");
int moduleId = m.reqInt("mid");
int w = m.reqInt("w");
int h = m.reqInt("h");

//객체
ClFileDao clFile = new ClFileDao();

//폼체크
f.addElement("filename", "", "hname:'파일', required:'Y', allow:'jpg|jpeg|gif|png'");
f.addElement("width", w == 0 ? "auto" : w + "", "hname:'가로크기', required:'Y'");
f.addElement("height", h == 0 ? "auto" : h + "", "hname:'세로크기', required:'Y'");

//등록
if(m.isPost() && f.validate()) {

	File attFile = f.saveFile("filename");

	if(null != attFile) {
		String orgname = f.getFileName("filename");
		String fileName = orgname;
		for(int i=1; i<100; i++) {
			if(clFile.findCount("module_id = " + moduleId + " AND filename = '" + m.addSlashes(fileName) + "' AND status = 1") > 0) {
				fileName = "(" + i + ")" + orgname;
			} else { break; }
		}

		clFile.item("site_id", siteId);
		clFile.item("module", module);
		clFile.item("module_id", moduleId);
		clFile.item("filename", fileName);
		clFile.item("filetype", f.getFileType("filename"));
		clFile.item("realname", attFile.getName());
		clFile.item("filesize", attFile.length());
		clFile.item("main_yn", "N");
		clFile.item("reg_date", m.time("yyyyMMddHHmmss"));
		clFile.item("status", 1);

		clFile.insert();

		out.print("<script>opener.iContent("
//			+ "'" + m.getUploadUrl(f.getFileName("filename")) + "'"
			+ "'" + Config.getDataUrl() + "/file/" + siteinfo.i("id") + "/" + (attFile.getName()) + "'"
			+ ", '" + (!"".equals(m.rs("tgt")) ? m.rs("tgt") : "content") + "'"
			+ ", '" + f.get("width") + "'"
			+ ", '" + f.get("height") + "'"
			+ ");</script>");

	}

	out.print("<script>opener.attach.location.href = opener.attach.location.href;</script>");
	out.print("<script>window.close();</script>");
	return;
}

//출력
p.setLayout("blank");
p.setBody("cpost.file_image");
p.setVar("p_title", "이미지 등록");
p.setVar("form_script", f.getScript());
p.setVar("list_query", m.qs("id"));
p.setVar("query", m.qs());

p.display();

%>
