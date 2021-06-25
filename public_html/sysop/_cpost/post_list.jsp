<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//접근권한
if(!Menu.accessible(49, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//객체
CourseStepDao step = new CourseStepDao();
ClBoardDao clBoard = new ClBoardDao();
ClPostDao clPost = new ClPostDao();
CourseDao course = new CourseDao();

//폼체크
f.addElement("s_field", null, null);
f.addElement("s_keyword", null, null);
f.addElement("s_year", null, null);
f.addElement("s_course_id", null, null);
f.addElement("s_step", null, null);

//목록
ListManager lm = new ListManager(jndi);
//lm.setDebug(out);
lm.setRequest(request);
lm.setListNum(20);
lm.setTable(
	clPost.table + " a"
	+ " INNER JOIN " + clBoard.table + " b ON a.board_id = b.id"
	+ " INNER JOIN " + step.table + " d ON a.step_id = d.id "
	+ " INNER JOIN " + course.table + " c ON d.course_id = c.id AND c.site_id = " + siteinfo.i("id")
);
lm.setFields(
	"a.*"
	+ " , b.board_nm, b.step_id"
	+ ", d.step_nm, d.year, d.step, d.course_id"
);
lm.addWhere("a.status != -1 AND b.board_type = " + bType);

lm.addSearch("d.step", f.get("s_step"));
lm.addSearch("d.course_id", f.get("s_course_id"));
lm.addSearch("d.year", f.get("s_year"));
if(!"".equals(f.get("s_field"))) lm.addSearch(f.get("s_field"), f.get("s_keyword"), "LIKE");
else if("".equals(f.get("s_field")) && !"".equals(f.get("s_keyword"))) {
	lm.addSearch("a.subject, a.content, a.writer", f.get("s_keyword"), "LIKE");
}
lm.setOrderBy(!"".equals(m.rs("ord")) ? m.rs("ord") : "a.thread, a.depth, a.id DESC");

DataSet list = lm.getDataSet();

while(list.next()) {
	list.put("subject_conv", m.cutString(list.s("subject"), 50));
	list.put("reg_date_conv", m.getTimeString("yyyy.MM.dd", list.s("reg_date")));
	list.put("hit_cnt_conv", m.nf(list.i("hit_cnt")));
}

//출력
p.setBody("cpost.post_list");
p.setVar("list_query", m.qs("id"));
p.setVar("query", m.qs());
p.setVar("form_script", f.getScript());

p.setVar("list_total", lm.getTotalString());
p.setVar("pagebar", lm.getPaging());
p.setLoop("course_list", course.getCourseList(siteinfo.i("id")));
p.setLoop("list", list);

p.display();

%>