<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//변수
DataSet rinfo = new DataSet();
rinfo.addRow();
boolean isError = false;

//기본키
String mid = f.get("mid");
String md = f.get("md", "post");
String fileUuid = f.get("fileuuid");
if("".equals(mid) || "".equals(md) || "".equals(fileUuid)) {
	rinfo.put("success", "false");
	rinfo.put("error", "기본키는 반드시 지정해야 합니다.");
	rinfo.put("reset", "true");
	isError = true;
}

//메소드
if(!isError && !m.isPost()) {
	rinfo.put("success", "false");
	rinfo.put("error", "올바른 접근이 아닙니다.");
	rinfo.put("reset", "true");
	isError = true;
}

//정보
DataSet info = file.find("module = ? AND module_id = ? AND site_id = ? AND file_uuid = ? ORDER BY id DESC", new String[] {md, mid, siteId + "", fileUuid}, 1);
if(!isError && !info.next()) {
	rinfo.put("success", "false");
	rinfo.put("error", "해당 정보가 없습니다.");
	rinfo.put("reset", "true");
	isError = true;
}

//삭제-파일정보
file.item("status", -1);
if(!isError && !file.update("id = " + info.i("id") + " AND site_id = " + siteId)) {
	rinfo.put("success", "false");
	rinfo.put("error", "파일정보를 수정하는 중 오류가 발생했습니다.");
	rinfo.put("reset", "true");
	isError = true;
}

//삭제-파일
if(!isError) {
	m.delFileRoot(m.getUploadPath(info.s("filename")));
	rinfo.put("success", "true");
}

//출력
response.setContentType("application/json;charset=utf-8");
String result = rinfo.serialize();
out.print(result.substring(1, result.length() - 1));

%>