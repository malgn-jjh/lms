<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//MANAGEMENT

//접근권한
if(!Menu.accessible(33, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//기본키
int courseId = m.ri("cid");
if(courseId == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

//객체
CourseDao course = new CourseDao();
CourseUserDao courseUser = new CourseUserDao();
UserDao user = new UserDao();
UserDeptDao userDept = new UserDeptDao();

CourseProgressDao courseProgress = new CourseProgressDao();
CourseUserLogDao courseUserLog = new CourseUserLogDao();
ExamUserDao examUser = new ExamUserDao();
HomeworkUserDao homeworkUser = new HomeworkUserDao();
ForumUserDao forumUser = new ForumUserDao();
SurveyUserDao surveyUser = new SurveyUserDao();

//삭제
if("del".equals(m.rs("mode"))) {
	//기본키
	int id = m.ri("id");
	if(id == 0) { m.jsAlert("기본키는 반드시 지정해야 합니다."); return; }

	//정보
	DataSet info = courseUser.find("id = " + id + " AND course_id = " + courseId + " AND status != -1");
	if(!info.next()) { m.jsAlert("해당 정보가 없습니다."); return; }

	//제한
	if(0 < courseProgress.findCount("course_id = " + courseId + " AND course_user_id = " + id + "")) {
		m.jsAlert("강의에 대한 진도내역이 있습니다. 삭제할 수 없습니다."); return;
	}
	if(0 < courseUserLog.findCount("course_user_id = " + id + "")) {
		m.jsAlert("학습내역이 있습니다. 삭제할 수 없습니다."); return;
	}
	if(0 < examUser.findCount("course_id = " + courseId + " AND course_user_id = " + id + "")) {
		m.jsAlert("시험응시내역이 있습니다. 삭제할 수 없습니다."); return;
	}
	if(0 < homeworkUser.findCount("course_id = " + courseId + " AND course_user_id = " + id + "")) {
		m.jsAlert("과제제출내역이 있습니다. 삭제할 수 없습니다."); return;
	}
	if(0 < forumUser.findCount("course_id = " + courseId + " AND course_user_id = " + id + "")) {
		m.jsAlert("토론참여내역이 있습니다. 삭제할 수 없습니다."); return;
	}
	if(0 < surveyUser.findCount("course_id = " + courseId + " AND course_user_id = " + id + "")) {
		m.jsAlert("설문참여내역이 있습니다. 삭제할 수 없습니다."); return;
	}

	//삭제
	if(!courseUser.delete("id = " + id + "")) { m.jsAlert("삭제하는 중 오류가 발생했습니다."); return; }

	//이동
	m.jsReplace("course_user_list.jsp?" + m.qs("id,mode"), "parent");
	return;
}

//처리
if(m.isPost()) {

	String[] idx = f.getArr("idx");
	if(idx.length == 0) { m.jsError("선택한 회원이 없습니다."); return; }

	if(-1 == courseUser.execute(
		"UPDATE " + courseUser.table + " SET "
		+ " status = " + f.get("a_status") + " "
		+ ", change_date = '" + m.time("yyyyMMddHHmmss") + "' "
		+ " WHERE id IN (" + m.join(",", idx) + ") "
	)) {
		m.jsError("변경처리하는 중 오류가 발생했습니다."); return;
	}

	m.jsReplace("course_user_list.jsp?" + m.qs("idx"));
	return;
}


//폼체크
f.addElement("s_status", null, null);
f.addElement("s_field", null, null);
f.addElement("s_keyword", null, null);

//목록
ListManager lm = new ListManager();
//lm.d(out);
lm.setRequest(request);
lm.setListNum("excel".equals(m.rs("mode")) ? 20000 : 20);
lm.setTable(
	courseUser.table + " a "
	+ " INNER JOIN " + course.table + " c ON a.course_id = c.id "
	+ " INNER JOIN " + user.table + " u ON a.user_id = u.id "
	+ " LEFT JOIN " + userDept.table + " d ON d.id = u.dept_id "
);
lm.setFields("a.*, u.user_nm, u.login_id, u.dept_id, d.dept_nm ");
lm.addWhere("a.status != -1");
lm.addWhere("a.course_id = " + courseId + "");
lm.addSearch("a.status", f.get("s_status"));
if("C".equals(userKind)) lm.addWhere("a.course_id IN (" + manageCourses + ")");
if(!"".equals(f.get("s_field"))) lm.addSearch(f.get("s_field"), f.get("s_keyword"), "LIKE");
else if("".equals(f.get("s_field")) && !"".equals(f.get("s_keyword"))) {
	lm.addSearch("u.user_nm, u.login_id", f.get("s_keyword"), "LIKE");
}
lm.setOrderBy(!"".equals(m.rs("ord")) ? m.rs("ord") : "a.id DESC");

//포멧팅
DataSet list = lm.getDataSet();
while(list.next()) {
	if(0 < list.i("dept_id")) {	
		list.put("dept_nm_conv", userDept.getNames(list.i("dept_id")));
	} else {	
		list.put("dept_nm", "[미소속]");
		list.put("dept_nm_conv", "[미소속]");
	}	

	list.put("start_date_conv", m.time("yyyy.MM.dd", list.s("start_date")));
	list.put("end_date_conv", m.time("yyyy.MM.dd", list.s("end_date")));
	list.put("reg_date_conv", m.time("yyyy.MM.dd", list.s("reg_date")));
	list.put("status_conv", m.getItem(list.s("status"), courseUser.statusList));

	list.put("progress_ratio_conv", m.nf(list.d("progress_ratio"), 1));
	list.put("total_score_conv", m.nf(list.d("total_score"), 1));
}

//출력
p.setBody("course.course_user_list");
p.setVar("p_title", "수강생 정보");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setLoop("list", list);
p.setVar("list_total", lm.getTotalString());
p.setVar("pagebar", lm.getPaging());
p.setLoop("status_list", m.arr2loop(courseUser.statusList));

p.setVar("tab_user", "current");
p.display();

%>