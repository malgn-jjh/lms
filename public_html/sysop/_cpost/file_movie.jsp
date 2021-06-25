<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

String module = m.request("md");
int moduleId = m.reqInt("mid");
int w = m.reqInt("w");
int h = m.reqInt("h");

//객체
ClFileDao clFile = new ClFileDao();

//폼체크
f.addElement("filename", "", "hname:'파일', required:'Y', allow:'swf|mp4|flv|mov|qt|mpeg|wmv|wma|asf|mp3|avi|wmp|rmp|ra'");
f.addElement("width", w, "hname:'가로크기', required:'Y', option:'number'");
f.addElement("height", h, "hname:'세로크기', required:'Y', option:'number'");

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
p.setBody("cpost.file_movie");
p.setVar("p_title", "동영상 등록");
p.setVar("form_script", f.getScript());
p.setVar("list_query", m.qs("id"));
p.setVar("query", m.qs());

p.display();

%>
