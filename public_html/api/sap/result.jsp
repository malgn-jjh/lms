<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
String companyKey = m.rs("companyIDX");
String userLoginId = m.rs("userId");
String courseKey = m.rs("enterpriseCourseKey");

//변수
String today = m.time("yyyyMMdd");

//제한-기업코드
if(!error && !"6Prgl2oHoQ1wWXSExRa51A==".equals(companyKey)) {
	_ret.put("error", "Invalid companyIDX");
	error = true;
}

//객체
UserDao user = new UserDao();
CourseDao course = new CourseDao();
CourseUserDao courseUser = new CourseUserDao();

//목록
DataSet list = new DataSet();
if(!error) {
	ArrayList<String> qs = new ArrayList<String>();
	if(!"".equals(courseKey)) qs.add(courseKey);
	if(!"".equals(userLoginId)) qs.add(userLoginId);
	
	//courseUser.d(out);
	DataSet temp = courseUser.query(
		" SELECT c.etc2, u.login_id, a.progress_ratio, a.start_date, a.end_date "
		+ " FROM " + courseUser.table + " a "
		+ " INNER JOIN " + course.table + " c ON a.course_id = c.id AND c.etc2 != '' AND c.etc2 IS NOT NULL " + (!"".equals(courseKey) ? " AND c.etc2 = ? " : "") + " AND c.status != -1 "
		+ " INNER JOIN " + user.table + " u ON a.user_id = u.id " + (!"".equals(userLoginId) ? " AND u.login_id = ? " : "") + " AND u.dept_id = 919 AND u.status != -1 "
		+ " AND a.end_date >= '" + m.addDate("M", -3, today, "yyyyMMdd") + "' "
		+ " AND a.site_id = " + siteId + " AND a.status IN (1, 3) "
		, qs.toArray()
	);
	while(temp.next()) {
		list.addRow();
		list.put("enterpriseCourseKey", temp.s("etc2"));
		list.put("userId", temp.s("login_id"));
		list.put("progress", (int)temp.d("progress_ratio"));
		list.put("courseStartDate", m.time("yyyy-MM-dd", temp.s("start_date")));
		list.put("courseEndDate", m.time("yyyy-MM-dd", temp.s("end_date")));
	}
}

//수정
if(!apiLog.updateLog(!error ? "000" : "-1")) {
	_ret.put("error", "cannot modify db");
	list = null;
	error = true;
}

//출력
try {
	_ret.put("result", list.size());
	apiLog.printList(out, _ret, "utf-8", list, "data");
} catch (NullPointerException npe){
	m.errorLog("NullPointerException : " + npe.getMessage(), npe);
	out.print("정보를 가져오는 중 오류가 발생했습니다.");
}

%>