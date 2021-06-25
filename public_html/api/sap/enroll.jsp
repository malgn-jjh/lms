<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
String companyKey = f.get("companyIDX");
String userLoginId = f.get("userID");
String courseKey = f.get("enterpriseCourseKey");

String startDate = m.time("yyyyMMdd", f.get("courseStartDate"));
String endDate = m.time("yyyyMMdd", f.get("courseEndDate"));
String email = f.get("userEMail");
String userNm = f.get("userName");
String mobile = f.get("userPhone");
String zipcode = f.get("zipcode");
String newAddr = f.get("address");
String addrDtl = f.get("addressDetail");
if(!error && ("".equals(userLoginId) || "".equals(courseKey))) {
	_ret.put("error", "Invalid information");
	Malgn.errorLog("{SAP} Invalid information");
	error = true;
}

//변수
String today = m.time("yyyyMMdd");
String now = m.time("yyyyMMddHHmmss");

//제한-기업코드
if(!error && !"6Prgl2oHoQ1wWXSExRa51A==".equals(companyKey)) {
	_ret.put("error", "Invalid companyIDX : " + companyKey);
	Malgn.errorLog("{SAP} Invalid companyIDX : " + companyKey);
	error = true;
}

//객체
UserDao user = new UserDao();
CourseDao course = new CourseDao();
CourseUserDao courseUser = new CourseUserDao();

//정보-과정
DataSet cinfo = null;
if(!error) {
	cinfo = course.find("etc2 = ? AND site_id = " + siteId + " AND status = 1", new String[] { courseKey });
	if(!cinfo.next()) {
		_ret.put("error", "Invalid enterpriseCourseKey : " + courseKey);
		Malgn.errorLog("{SAP} Invalid enterpriseCourseKey : " + courseKey);
		error = true;
	}
}

//수강일자처리
if(!error) {
	if("R".equals(cinfo.s("course_type"))) {
		startDate = cinfo.s("study_sdate");
		endDate = cinfo.s("study_edate");
	} else if("A".equals(cinfo.s("course_type"))) {
		if("".equals(startDate)) startDate = m.time("yyyyMMdd");
		if("".equals(endDate)) endDate = m.time("yyyyMMdd", m.addDate("D", cinfo.i("lesson_day") > 0 ? cinfo.i("lesson_day") - 1 : 0, startDate));
	}
}

//정보-회원
int uid = 0;
if(!error) {
	uid = user.getOneInt("SELECT id FROM " + user.table + " WHERE login_id = ? AND site_id = " + siteId + " AND status = 1", new String[] { userLoginId });
	if(1 > uid) {
		if(!error && "".equals(userLoginId)) {
			//기본키-회원가입
			_ret.put("error", "Invalid user information : " + userNm);
			Malgn.errorLog("{SAP} Invalid user information : " + userNm);
			error = true;
		} else {
			//회원가입
			//user.d(out);
			if("".equals(userNm)) userNm = userLoginId;
			int newId = user.getSequence();
			user.item("id", newId);
			user.item("site_id", siteId);
			user.item("login_id", userLoginId);
			user.item("dept_id", "919");
			user.item("user_nm", userNm);
			user.item("email", email);
			user.item("zipcode", zipcode);
			user.item("new_addr", newAddr);
			user.item("addr_dtl", addrDtl);
			if(!"".equals(mobile)) user.item("mobile", SimpleAES.encrypt(mobile));
			user.item("reg_date", now);
			user.item("status", 1);
			if(!user.insert()) {
				_ret.put("error", "cannot add user");
				error = true;
			} else {
				uid = newId;
			}
		}
	}
}

if(cinfo != null && courseUser.findCount("course_id = ? AND user_id = ? AND start_date = ? AND end_date = ? AND status = 1", new Object[] { cinfo.s("id"), uid, startDate, endDate}) > 0) {
	_ret.put("error", "already enrolled");
	error = true;
}

//입과처리
if(!error && !courseUser.addUser(cinfo, uid, 1, startDate, endDate)) {
	_ret.put("error", "cannot enrol");
	error = true;
}

//수정
if(!apiLog.updateLog(!error ? "000" : "-1")) {
	_ret.put("error", "cannot modify db");
	error = true;
}

//출력
_ret.put("result", !error ? 1 : 0);
apiLog.printList(out, _ret, "utf-8");

%>