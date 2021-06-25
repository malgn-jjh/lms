<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//MANAGEMENT

//접근권한
if(!Menu.accessible(33, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//기본키
int id = m.ri("id");
if(id == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

int courseId = m.ri("cid");
if(courseId == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

//객체
CourseDao course = new CourseDao();
CourseUserDao courseUser = new CourseUserDao();
UserDao user = new UserDao();
CourseUserLogDao courseUserLog = new CourseUserLogDao();

//변수
String today = m.time("yyyyMMddHHmmss");

//정보
DataSet cuinfo = courseUser.query(
	"SELECT a.* "
	+ ", (CASE WHEN '" + today + "' BETWEEN a.start_date AND a.end_date THEN 'Y' ELSE 'N' END) is_study "
	+ ", u.user_nm, u.login_id "
	+ ", m.user_nm close_user_nm "
	+ " FROM " + courseUser.table + " a "
	+ " INNER JOIN " + user.table + " u ON a.user_id = u.id "
	+ " INNER JOIN " + course.table + " c ON c.id = a.course_id "
	+ " LEFT JOIN " + user.table + " m ON a.close_user_id = m.id "
	+ " WHERE a.id = " + id + " "
	+ ("C".equals(userKind) ? " AND course_id IN (" + manageCourses + ") " : "")
);
if(!cuinfo.next()) { m.jsError("해당 정보가 없습니다."); return; }
cuinfo.put("status_conv", m.getItem(cuinfo.s("status"), courseUser.statusList));
cuinfo.put("complete_conv", cuinfo.b("complete_yn") ? "수료" : "-");
cuinfo.put("close_conv", cuinfo.b("close_yn") ? "마감" : "미마감");

cuinfo.put("start_date_conv", m.time("yyyy.MM.dd", cuinfo.s("start_date")));
cuinfo.put("end_date_conv", m.time("yyyy.MM.dd", cuinfo.s("end_date")));
cuinfo.put("mod_date_conv", !"".equals(cuinfo.s("mod_date")) ? m.time("yyyy.MM.dd HH:mm", cuinfo.s("mod_date")) : "-");
cuinfo.put("reg_date_conv", m.time("yyyy.MM.dd HH:mm", cuinfo.s("reg_date")));


//목록
ListManager lm = new ListManager();
//lm.setDebug(out);
lm.setRequest(request);
lm.setListNum("excel".equals(m.rs("mode")) ? 20000 : 20);
lm.setTable(courseUserLog.table + " a");
lm.setFields("a.*");
lm.addWhere("a.status = 1");
lm.addWhere("a.course_user_id = " + id + "");
lm.addWhere("a.user_id = " + cuinfo.i("user_id") + "");
lm.setOrderBy("a.reg_date DESC");

DataSet list = lm.getDataSet();
while(list.next()) {
	list.put("progress_ratio_conv", m.nf(list.d("progress_ratio"), 1));
	list.put("browser", courseUserLog.getBrowser(list.s("user_agent")));
	list.put("reg_date_conv", m.time("yyyy.MM.dd HH:mm:ss", list.s("reg_date")));
}

//엑셀
if("excel".equals(m.request("mode"))) {
	ExcelWriter ex = new ExcelWriter(response, "수강기록(" + m.time("yyyy-MM-dd") + ").xls");
	ex.setData(list, new String[] { "__ord=>No", "user_nm=>회원명", "course_nm=>과정명", "lesson_subject=>차시명", "chapter=>차시", "user_ip_addr=>접속IP", "browser=>브라우저", "reg_date_conv=>접속일시" }, "수강기록(" + m.time("yyyy-MM-dd") + ")");
	ex.write();
	return;
}

//출력
p.setBody("course.course_user_log");
p.setVar("p_title", "강의창 접속이력");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));

p.setLoop("list", list);
p.setVar("list_total", lm.getTotalString());
p.setVar("pagebar", lm.getPaging());

p.setVar("cuinfo", cuinfo);
p.setVar("tab_user", "current");
p.display();

%>