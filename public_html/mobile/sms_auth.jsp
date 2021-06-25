<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//로그인
if("".equals(userId)) { m.redirect("login.jsp"); return; }

//기본키
int cuid = m.ri("cuid");
int lid = m.ri("lid");
int chapter = m.ri("chapter");
if(cuid == 0 || lid == 0 || chapter == 0) { m.jsErrClose(_message.get("alert.common.required_key")); return; }

//객체
UserDao user = new UserDao();
CourseDao course = new CourseDao();
CourseUserDao courseUser = new CourseUserDao();
CourseLessonDao courseLesson = new CourseLessonDao();
CourseProgressDao courseProgress = new CourseProgressDao();
CourseSessionDao courseSession = new CourseSessionDao(siteId);
LessonDao lesson = new LessonDao();
SmsDao sms = new SmsDao(siteId);
sms.setAccount(siteinfo.s("sms_id"), siteinfo.s("sms_pw"));

//변수
String today = m.time("yyyyMMdd");
String now = m.time("yyyyMMddHHmmss");

//정보
DataSet cuinfo = courseUser.query(
	"SELECT a.*, c.course_nm, c.course_type, c.onoff_type, c.sms_yn, t.user_nm tutor_name, c.subject_id, u.id user_id, u.user_nm, u.mobile "
	+ " FROM " + courseUser.table + " a "
	+ " INNER JOIN " + course.table + " c ON a.course_id = c.id AND c.site_id = " + siteId + " AND c.mobile_yn = 'Y' "
	+ " LEFT JOIN " + user.table + " t ON a.tutor_id = t.id"
	+ " INNER JOIN " + user.table + " u ON a.user_id = u.id"
	+ " WHERE a.id = " + cuid + " AND a.user_id = '" + userId + "' AND a.status IN (1,3)"
);
if(!cuinfo.next()) { m.jsError(_message.get("alert.course_user.nodata")); return; }

//정보-과정
String courseId = cuinfo.s("course_id");
DataSet cinfo = course.find("id = " + courseId + " AND site_id = " + siteId + "");
if(!cinfo.next()) { m.jsError(_message.get("alert.course.nodata")); return; }

//제한-수강가능여부
if(0 < m.diffDate("D", cuinfo.s("restudy_edate"), today)) { m.jsErrClose(_message.get("alert.course_user.noperiod_study")); return; }

//목록
DataSet info = courseLesson.query(
	"SELECT a.*, p.ratio p_ratio, p.complete_yn "
	+ " FROM " + courseLesson.table + " a"
	+ " INNER JOIN " + lesson.table + " l ON l.id = a.lesson_id"
	+ " LEFT JOIN " + courseProgress.table + " p ON p.course_user_id = " + cuid + " AND p.lesson_id = a.lesson_id"
	+ " WHERE a.status = 1 AND a.course_id = " + courseId + " AND a.lesson_id = " + lid
);
if(!info.next()) { m.jsErrClose(_message.get("alert.course_lesson.nodata")); return; }

//SMS인증
if(info.d("p_ratio") >= 100.0 || !cuinfo.b("sms_yn") || courseSession.verifySession(cuid, lid, userSessionId)) {
	m.jsReplace("../classroom/viewer.jsp?" + m.qs());
	return;
}

//폼입력
f.addElement("auth_no", null, "hname:'인증번호', required:'Y'");

//인증확인
if(m.isPost() && f.validate()) {
	if(!f.get("auth_no").equals(m.getSession("VIEWER_AUTH_NO_" + cuid + "_" + lid))) {
		m.jsAlert(_message.get("alert.classroom.incorrect_authno")); return;
	}

	//등록
	if(!courseSession.updateSession(cuid, lid, userSessionId)) {
		m.jsErrClose(_message.get("alert.classroom.error_auth"), "parent.window");
		return;
	}

	//세션삭제
	m.setSession("VIEWER_AUTH_NO_" + cuid + "_" + lid, "");
	m.setSession("VIEWER_AUTH_DATE_" + cuid + "_" + lid, "");

	//이동
	m.jsReplace("../mobile/viewer.jsp?" + m.qs(), "parent");
	return;
}

//발송
if(!siteinfo.b("sms_yn")) { m.jsErrClose(_message.get("alert.sms.error_send")); return; }

//변수
String mobile = cuinfo.s("mobile");
try { mobile = SimpleAES.decrypt(mobile); } catch(Exception e) { }
DataSet uinfo = new DataSet();
uinfo.addRow();
uinfo.put("id", cuinfo.s("user_id"));
uinfo.put("user_nm", cuinfo.s("user_nm"));
uinfo.put("mobile", mobile);

//SMS
if(!sms.isMobile(mobile)) { m.jsErrClose(_message.get("alert.member.unvalid_mobile")); return; }

//제한-2분
boolean limitBlock = false;
int gapLimit = 2;
int gapMinutes = !"".equals(m.getSession("VIEWER_AUTH_DATE_" + cuid + "_" + lid)) ? m.diffDate("I", m.getSession("VIEWER_AUTH_DATE_" + cuid + "_" + lid), now) : 999;
int gapWait = gapLimit - gapMinutes;

if(gapMinutes < gapLimit) {
	limitBlock = true;
} else {
	//변수
	int authNo = m.getRandInt(123456, 864198);
	String scontent = "[" + info.s("chapter") + "차시 수강 본인인증] 인증번호 : " + authNo;

	//SMS
	//m.js("prompt('인증번호', '" + authNo + "');");
	sms.send(mobile, siteinfo.s("sms_sender"), scontent, m.time("yyyyMMddHHmm59"));
	sms.insertSms(siteId, -9, siteinfo.s("sms_sender"), scontent, uinfo);
	m.setSession("VIEWER_AUTH_NO_" + cuid + "_" + lid, authNo);
	m.setSession("VIEWER_AUTH_DATE_" + cuid + "_" + lid, now);
}

//출력
p.setLayout(null);
p.setBody("mobile.sms_auth");
p.setVar("query", m.qs("id"));
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setVar("limit_block", limitBlock);
p.setVar("gap_wait", gapWait);
p.setVar("gap_minutes", gapMinutes);
p.setVar("mobile", mobile);
p.display();

%>