<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//접근권한
if(!Menu.accessible(49, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//객체
CourseStepDao step = new CourseStepDao();
ClBoardDao clBoard = new ClBoardDao();
ClPostDao clPost = new ClPostDao();
CourseDao course = new CourseDao();
ClFileDao clFile = new ClFileDao();

//폼체크
f.addElement("s_course_id", null, "hname:'과정', required:'Y'");
f.addElement("s_year", null, "hname:'년도', required:'Y'");
f.addElement("s_step", null, "hname:'기수', required:'Y'");
f.addElement("subject", null, "hname:'제목', required:'Y'");
f.addElement("writer", userName, "hname:'작성자', required:'Y'");

//등록
if(m.isPost() && f.validate()) {
	DataSet binfo = clBoard.query(
		"SELECT a.*"
		+ " FROM " + clBoard.table + " a "
		+ " INNER JOIN " + step.table + " b ON a.step_id = b.id"
		+ " WHERE a.board_type = " + bType + " AND b.course_id = " + f.getInt("s_course_id") + " AND b.year = " + f.getInt("s_year") + " AND b.step = " + f.getInt("s_step")
	);
	if(!binfo.next()) { m.jsAlert("과정정보를 찾을 수 없습니다."); return; }

	int insertId = clPost.getSequence();

	clPost.item("id", insertId);
	clPost.item("site_id", siteId);
	clPost.item("thread", clPost.getLastThread());
	clPost.item("depth", "");
	clPost.item("step_id", binfo.i("step_id"));
	clPost.item("board_cd", binfo.s("code"));
	clPost.item("board_id", binfo.i("id"));
	clPost.item("user_id", userId);
	clPost.item("writer", f.get("writer"));
	clPost.item("subject", f.get("subject"));
	clPost.item("content", f.get("content"));
	clPost.item("point" , 0);
	clPost.item("public_yn", "Y");
	clPost.item("notice_yn", "N");
	clPost.item("hit_cnt", 0);
	clPost.item("comm_cnt", 0);
	clPost.item("mod_date", "");
	clPost.item("reg_date", m.time("yyyyMMddHHmmss"));
	clPost.item("status", 1);

	if(!clPost.insert()) {
		m.jsAlert("등록하는 중 오류가 발생했습니다.");
		return;
	}

	//파일의 게시물 임시아이디 업데이트
	clFile.updateTempFile(f.getInt("temp_id"), insertId);

	//게시물에 파일종류 업데이트
	//clFile.updateFtype(insertId);

	m.jsReplace("post_list.jsp", "parent");
	return;
}

//출력
p.setBody("cpost.post_insert");
p.setVar("list_query", m.qs("id"));
p.setVar("query", m.qs());
p.setVar("form_script", f.getScript());

p.setLoop("course_list", course.getCourseList(siteinfo.i("id")));
p.setVar("post_id", m.getRandInt(-2000000, 1990000));

p.display();

%>