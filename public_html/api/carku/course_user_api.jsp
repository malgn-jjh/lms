<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
String userNm = m.rs("user_nm");
String birthday = m.rs("birthday");
String mobile = m.rs("mobile");
if(!error && ("".equals(userNm) || "".equals(birthday) || "".equals(mobile))) {
	_ret.put("ret_code", "310");
	_ret.put("ret_msg", "required parameters not specified");
	error = true;
}

if(!error && (8 != birthday.length() || 0 > mobile.indexOf("-"))) {
	_ret.put("ret_code", "320");
	_ret.put("ret_msg", "not valid information");
	error = true;
}

//객체
UserDao user = new UserDao();
CourseDao course = new CourseDao();
CourseUserDao courseUser = new CourseUserDao();

//정보
DataSet info = null;
if(!error) {
	info = user.find(
		"site_id = " + siteId + " AND user_nm = ? AND birthday = ? AND mobile = ? AND status != -1"
		, new String[] {userNm, birthday, SimpleAES.encrypt(mobile)}
	);
	if(!info.next()) {
		_ret.put("ret_code", "410");
		_ret.put("ret_msg", "no user information");
		error = true;
	}
}

//목록
DataSet list = null;
if(!error) {
	list = courseUser.query(
		" SELECT c.course_nm, a.complete_yn, a.complete_date "
		+ " FROM " + courseUser.table + " a "
		+ " INNER JOIN " + course.table + " c ON a.course_id = c.id AND c.status != -1 "
		+ " WHERE a.user_id = " + info.i("id") + " AND a.site_id = " + siteId + " AND a.status != -1 "
		+ " ORDER BY a.id ASC "
	);
	_ret.put("ret_size", list.size());
}

//수정
if(!apiLog.updateLog(_ret.get("ret_code").toString())) {
	_ret.put("ret_code", "-1");
	_ret.put("ret_msg", "cannot modify db");
	list = null;
	error = true;
};

//출력
apiLog.printList(out, _ret, list);

%>