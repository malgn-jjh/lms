<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//MANAGER

//접근권한
if(!Menu.accessible(33, userId, userKind)) { m.jsErrClose("접근 권한이 없습니다."); return; }

//기본키
int courseId = m.ri("cid");
if(courseId == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

//객체
UserDao user = new UserDao();
UserDeptDao userDept = new UserDeptDao();
CourseDao course = new CourseDao();
CourseUserDao courseUser = new CourseUserDao();
TutorDao tutor = new TutorDao();

//정보
DataSet cinfo = course.find(
	"id = " + courseId + " AND site_id = " + siteId + " AND status != -1"
	+ ("C".equals(userKind) ? " AND id IN (" + manageCourses + ") " : "")
);
if(!cinfo.next()) { m.jsError("과정정보를 조회할 수 없습니다."); return; }

//추가
if(m.isPost() && !"".equals(f.get("uid"))) {

	//수강신청
	String[] idx = f.get("uid").split("\\,");
	for(int i=0; i<idx.length; i++) {
		courseUser.addUser(cinfo, m.parseInt(idx[i]), 1);
	}

	m.jsAlert("추가되었습니다.");
	out.print("<script> try { opener.location.reload(); } catch (e) { } </script>");
	m.jsReplace("course_user_add.jsp?" + m.qs("uid"));
	return;

}

//폼체크
f.addElement("s_dept", null, null);
f.addElement("s_field", null, null);
f.addElement("s_keyword", null, null);

//목록
ListManager lm = new ListManager();
//lm.d(out);
lm.setRequest(request);
lm.setListNum(100);
lm.setTable(
	user.table + " a "
	+ " LEFT JOIN " + userDept.table + " d ON a.dept_id = d.id "
);
lm.setFields("a.*, d.dept_nm");
lm.addWhere("a.status = 1");
lm.addWhere("a.user_kind = 'U'");
lm.addWhere("a.site_id = " + siteId + "");
//lm.addWhere("NOT EXISTS (SELECT 1 FROM " + courseUser.table + " WHERE course_id = " + courseId + " AND user_id = a.id)");
if(0 < f.getInt("s_dept")) lm.addWhere("a.dept_id IN (" + userDept.getSubIdx(siteId, f.getInt("s_dept")) + ")");
//lm.addSearch("a.dept_id", f.get("s_dept"));
if(!"".equals(f.get("s_field"))) lm.addSearch(f.get("s_field"), f.get("s_keyword"), "LIKE");
else lm.addSearch("a.user_nm,a.login_id", f.get("s_keyword"), "LIKE");
lm.setOrderBy(!"".equals(m.rs("ord")) ? m.rs("ord") : "a.user_nm ASC");

//포맷팅
DataSet list = lm.getDataSet();
while(list.next()) {
	if(0 < list.i("dept_id")) {	
		list.put("dept_nm_conv", userDept.getNames(list.i("dept_id")));
	} else {	
		list.put("dept_nm", "[미소속]");
		list.put("dept_nm_conv", "[미소속]");
	}	

	list.put("mobile_conv", "-");
	try { list.put("mobile_conv", !"".equals(list.s("mobile")) ? SimpleAES.decrypt(list.s("mobile")) : "-" );  } catch(Exception e) { m.errorLog(e.getMessage(), e); }
}

//출력
p.setLayout("pop");
p.setBody("course.course_user_add");
p.setVar("p_title", "수강생 추가");
p.setVar("form_script", f.getScript());

p.setLoop("list", list);
p.setVar("list_total", lm.getTotalString());
p.setVar("pagebar", lm.getPaging());

p.setLoop("dept_list", userDept.getList(siteId));

p.setVar("tab_user", "current");
p.display();

%>