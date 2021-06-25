<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//접근권한
if(!Menu.accessible(49, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

int id = m.ri("id");
if(id == 0) { m.jsError("기본키는 반드시 있어야 합니다."); return; }

//객체
ClPostDao clPost = new ClPostDao();
ClFileDao clFile = new ClFileDao();

DataSet info = clPost.query(
	"SELECT a.* "
	+ " FROM " + clPost.table + " a"
	+ " WHERE a.id = " + id + " AND a.status != -1"
);
if(!info.next()) { m.jsError("해당 정보를 찾을 수 없습니다."); return; }

clPost.item("status", -1);
if(!clPost.update("id= " + id)) {
	m.jsAlert("삭제하는 중 오류가 발생했습니다.");
	return;
}

DataSet files = clFile.find("module = 'post' AND module_id = " + id);
while(files.next()) {
	if(clFile.delete("id = " + files.i("id"))) m.delFileRoot(f.uploadDir + "/" + files.s("realname"));
}

m.jsReplace("post_list.jsp?" + m.qs("id"));

%>