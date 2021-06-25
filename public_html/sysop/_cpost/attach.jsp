<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

String module = m.request("md", "post");
int moduleId = m.reqInt("mid");

//객체
ClFileDao clFile = new ClFileDao();

//삭제
if("del".equals(m.rs("mode")) && m.ri("id") > 0) {
	DataSet info = clFile.get(m.ri("id"));
	if(!info.next()) {
		m.jsError("해당 정보가 없습니다.");
		return;
	}
	if(clFile.delete(info.i("id"))) {
		if(!"".equals(info.s("realname"))) m.delFile(f.uploadDir + "/" + info.s("realname"));
	}

	m.jsReplace("attach.jsp?" + m.qs("id, mode"));
	return;
}

//대표이미지변경
if("mod".equals(m.rs("mode")) && m.ri("id") > 0) {
	DataSet info = clFile.get(m.ri("id"));
	if(!info.next()) {
		m.jsError("해당 정보가 없습니다.");
		return;
	}
	if(-1 != clFile.execute("UPDATE " + clFile.table + " SET main_yn = 'N' WHERE module = '" + module + "' AND module_id = " + moduleId)) {
		clFile.item("main_yn", "Y");
		if(!clFile.update()) { }
	}
	m.jsReplace("attach.jsp?" + m.qs("id, mode"));
	return;
}

//게시물에 파일종류 업데이트
//if(module.equals("post") && moduleId > 0) clFile.updateFtype(moduleId);

//대표이미지존재검사
boolean exists = clFile.findCount("module = '" + module + "' AND module_id = " + moduleId + " AND main_yn = 'Y'") == 1;

//목록
DataSet list = clFile.query(
	"SELECT a.* "
	+ " FROM " + clFile.table + " a "
	+ " WHERE module = '" + module + "' AND module_id = " + moduleId
	+ " ORDER BY a.id ASC"
);

//포멧팅
int no = 0;
while(list.next()) {
	boolean isImage = list.s("filename").toLowerCase().matches("^(.+)\\.(jpg|jpeg|gif|png)$");
	if(!exists && isImage) { //대표이미지가 없는경우 첫 번째 이미지를 자동지정
		clFile.execute("UPDATE " + clFile.table + " SET main_yn = 'Y' WHERE id = " + list.i("id"));
		list.put("main_yn", "Y");
		exists = true;
	}
	list.put("__idx", ++no);
	list.put("reg_date_conv", m.time("yyyy.MM.dd HH:mm", list.s("reg_date")));
	list.put("checked", "Y".equals(list.s("main_yn")) ? "checked" : "");
	list.put("ext", clFile.getFileIcon(list.s("filename")));
	list.put("ek", m.encrypt(list.s("id")));
	list.put("filename_conv", m.urlencode(Base64Coder.encode(list.s("filename"))));
//	list.put("fileurl", m.getUploadUrl(list.s("filename")));
	list.put("fileurl", Config.getDataUrl() + "/file/" + siteinfo.i("id") + "/" + list.s("realname"));
	list.put("is_img", isImage);
}

//이미지, 동영상, 파일버튼 사용여부 설정
Hashtable types = new Hashtable();
types.put("image", "true"); types.put("movie", "true"); types.put("file", "true");
String[] deny = !"".equals(m.request("deny")) ? m.request("deny").split("\\,") : null;
if(null != deny) {
	for(int i=0; i<deny.length; i++) if(types.containsKey(deny[i])) types.put(deny[i], "false");
}

//출력
p.setLayout("blank");
p.setBody("cpost.attach");
p.setVar("list_query", m.getQueryString("id"));
p.setVar("query", m.getQueryString(""));
p.setVar("del_query", m.getQueryString("id, mode"));
p.setVar("mod_query", m.getQueryString("id, mode"));

p.setLoop("list", list);
p.setVar("use_img", (String)types.get("image"));
p.setVar("use_movie", (String)types.get("movie"));
p.setVar("use_file", (String)types.get("file"));

p.display();


%>