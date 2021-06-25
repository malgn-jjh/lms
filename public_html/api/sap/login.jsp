<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
String companyKey = m.rs("companyIDX");
String userLoginId = m.rs("userID");
String courseKey = m.rs("enterpriseCourseKey");
String qq = m.rs("qq");
String ts = m.rs("ts");
String sno = m.rs("sno");

if(!"".equals(qq)) {
	String ret = m.replace(m.exec("/home/talkit/bin/sap_api.sh " + qq + " " + ts + " " + sno), "\n", "");
	if(!ret.startsWith("[")) {
		m.p(ret); return;
	}

	DataSet rs = Json.decode(ret);
	if(!rs.next()) {
		m.p(ret); return;
	}

	companyKey = rs.s("companyIDX");
	userLoginId = rs.s("userID");
	courseKey = rs.s("enterpriseCourseKey");
}

if(!error && ("".equals(companyKey) || "".equals(userLoginId))) {
	_ret.put("error", "Invalid information");
	error = true;
}

//변수
String today = m.time("yyyyMMdd");

//제한-기업코드
/*
if(!error && !"6Prgl2oHoQ1wWXSExRa51A==".equals(companyKey) ) {
	_ret.put("error", "Invalid companyIDX");
	error = true;
}
*/

//객체
UserDao user = new UserDao();
GroupDao group = new GroupDao();
UserDeptDao userDept = new UserDeptDao();
UserLoginDao userLogin = new UserLoginDao();

CourseDao course = new CourseDao();
CourseUserDao courseUser = new CourseUserDao();

//목록
DataSet info = null;
if(!error) {
	//user.d(out);
	info = user.find("login_id = ? AND site_id = " + siteId + " AND dept_id = 919 AND status = 1", new String[] { userLoginId });
	if(!info.next()) {
		_ret.put("error", "Invalid userID");
		error = true;
	}
}

//수강정보
int cuid = 0;
if(!error) {
	//courseUser.d(out);
	cuid = courseUser.getOneInt(
		" SELECT a.id "
		+ " FROM " + courseUser.table + " a "
		+ " INNER JOIN " + course.table + " c ON a.course_id = c.id AND c.etc2 != '' AND c.etc2 IS NOT NULL AND c.etc2 = ? AND c.status = 1 "
		+ " WHERE a.user_id = ? AND a.site_id = " + siteId + " AND a.status IN (1, 3) "
		+ " AND a.start_date <= ? AND a.end_date >= ? "
		+ " ORDER BY a.id DESC "
		, new String[] { courseKey, info.s("id"), today, today }
	);
}

//수정
if(!apiLog.updateLog(!error ? "000" : "-1")) {
	_ret.put("error", "cannot modify db");
	info = null;
	error = true;
}

//출력
if(error) { apiLog.printList(out, _ret, "utf-8", info); return; }

//로그인
UserSession.setUserId(info.i("id"));
UserSession.setSession(mSession.s("id"));

String tmpGroups = group.getUserGroup(info);
auth.put("ID", info.s("id"));
auth.put("LOGINID", info.s("login_id"));
auth.put("KIND", info.s("user_kind"));
auth.put("NAME", info.s("user_nm"));
auth.put("EMAIL", info.s("email"));
auth.put("DEPT", info.i("dept_id"));
auth.put("SESSIONID", mSession.s("id"));
auth.put("GROUPS", tmpGroups);
auth.put("GROUPS_DISC", group.getMaxDiscRatio());
//auth.put("ALOGIN_YN", "N");
auth.setAuthInfo();

//로그
userLogin.item("id", userLogin.getSequence());
userLogin.item("site_id", siteId);
userLogin.item("user_id", info.i("id"));
userLogin.item("admin_yn", "N");
userLogin.item("login_type", "I");
userLogin.item("ip_addr", request.getRemoteAddr());
userLogin.item("agent", request.getHeader("user-agent"));
userLogin.item("device", userLogin.getDeviceType(request.getHeader("user-agent")));
userLogin.item("log_date", m.time("yyyyMMdd"));
userLogin.item("reg_date", m.time("yyyyMMddHHmmss"));
if(!userLogin.insert()) { }

m.redirect(1 > cuid ? "/mypage/index.jsp" : "/classroom/index.jsp?cuid=" + cuid);

%>