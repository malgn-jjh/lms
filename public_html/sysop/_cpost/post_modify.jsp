<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//접근권한
if(!Menu.accessible(49, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

int id = m.ri("id");
if(id == 0) { m.jsError("기본키는 반드시 있어야 합니다."); return; }

//객체
CourseStepDao step = new CourseStepDao();
ClBoardDao clBoard = new ClBoardDao();
ClPostDao clPost = new ClPostDao();
CourseDao course = new CourseDao();
ClFileDao clFile = new ClFileDao();

DataSet info = clPost.query(
	"SELECT a.*, b.step_nm, b.year, b.step"
	+ " FROM " + clPost.table + " a"
	+ " INNER JOIN " + step.table + " b ON a.step_id = b.id"
	+ " WHERE a.id = " + id + " AND a.status != -1"
);
if(!info.next()) { m.jsError("해당 정보를 찾을 수 없습니다."); return; }

//폼체크
f.addElement("subject", info.s("subject"), "hname:'제목', required:'Y'");
f.addElement("writer", info.s("writer"), "hname:'작성자', required:'Y'");

//등록
if(m.isPost() && f.validate()) {

	clPost.item("writer", f.get("writer"));
	clPost.item("subject", f.get("subject"));
	clPost.item("content", f.get("content"));
	clPost.item("mod_date", m.getTimeString("yyyyMMddHHmmss"));

	if(!clPost.update("id=" + id)) {
		m.jsAlert("수정하는 중 오류가 발생했습니다.");
		return;
	}

	//게시물에 파일종류 업데이트
	//clFile.updateFtype(id);

	m.jsReplace("post_list.jsp?" + m.qs("id"), "parent");
	return;
}

//출력
p.setBody("cpost.post_insert");
p.setVar("list_query", m.qs("id"));
p.setVar("query", m.qs());
p.setVar("form_script", f.getScript());

p.setVar(info);
p.setVar("post_id", id);
p.setVar("modify", true);

p.display();

%>