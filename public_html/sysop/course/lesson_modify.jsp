<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
int lid = m.ri("id");
int cid = m.ri("cid");
if(lid == 0 || cid == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

//객체
CourseLessonDao courseLesson = new CourseLessonDao();
CourseDao course = new CourseDao();
LessonDao lesson = new LessonDao();
KtRemoteDao ktRemote = new KtRemoteDao(siteId);
CourseTutorDao courseTutor = new CourseTutorDao();
TutorDao tutor = new TutorDao();
UserDao user = new UserDao();
MCal mcal = new MCal();

DataSet courseInfo = course.find("site_id = " + siteId + " AND id = " + cid + " AND status = 1", "study_sdate, study_edate");
if(!courseInfo.next()) { m.jsError("해당 과정정보가 없습니다."); return; }

//정보
DataSet info = courseLesson.query(
    "SELECT a.*, l.onoff_type, l.lesson_type, l.lesson_nm FROM " + courseLesson.table + " a "
    + " INNER JOIN " + course.table + " c on a.course_id = c.id AND c.site_id = " + siteId + " AND c.status = 1 "
    + " INNER JOIN " + lesson.table + " l on a.lesson_id = l.id AND l.site_id = " + siteId + " AND l.status != -1 "
    + " WHERE a.status != -1 AND a.site_id = " + siteId + " AND l.onoff_type = 'T'"
    + " AND a.course_id = " + cid + " AND a.lesson_id = " + lid
);

if(!info.next()) { m.jsError("해당 정보가 없습니다."); return; }

//폼체크
String startHour = info.s("start_time").substring(0, 2);
String startMinute = info.s("start_time").substring(2, 4);
String endHour = info.s("end_time").substring(0, 2);;
String endMinute = info.s("end_time").substring(2, 4);

f.addElement("tutor_id", info.i("tutor_id"), "hname:'강사명', required:'Y'");
f.addElement("start_date", m.time("yyyy-MM-dd", info.s("start_date")), "hname:'시작일', required:'Y'");
f.addElement("end_date", m.time("yyyy-MM-dd", info.s("start_date")), "hname:'마감일', required:'Y'");
f.addElement("start_hour", startHour, "hname:'시작시', option:'number'");
f.addElement("start_min", startMinute, "hname:'시작분', option:'number'");
f.addElement("end_hour", endHour, "hname:'마감시', option:'number'");
f.addElement("end_min", endMinute, "hname:'마감분', option:'number'");

//등록
if(m.isPost() && f.validate()) {

    String startDate = m.time("yyyyMMdd", f.get("start_date"));
    String startTime = f.get("start_time_hour") + f.get("start_time_min") + "00";
    String endTime = f.get("end_time_hour") + f.get("end_time_min") + "59";

    courseLesson.item("tutor_id", f.getInt("tutor_id"));
    courseLesson.item("start_date", startDate);
    courseLesson.item("end_date", startDate);
    courseLesson.item("start_time", startTime);
    courseLesson.item("end_time", endTime);

    if("15".equals(info.s("lesson_type"))) {
        if(!ktRemote.updatePlan(info.s("twoway_url"), m.getUnixTime(startDate + startTime), m.getUnixTime(startDate + endTime))) {
            m.jsAlert("수정하는 중 오류가 발생했습니다[1].");
            return;
        }
    }

    if(!courseLesson.update("lesson_id = " + lid + " AND course_id = " + cid)) { m.jsAlert("수정하는 중 오류가 발생했습니다[2]."); return; }
    m.js("parent.location.href = parent.location.href;");
    return;
}

//포맷팅
//info.put("start_date_conv", m.time("yyyy-MM-dd", info.s("start_date")));
//info.put("end_date_conv", m.time("yyyy-MM-dd", info.s("end_date")));
info.put("lesson_type_conv", m.getItem(info.s("lesson_type"), lesson.allTypes));
info.put("start_time_hour", startHour);
info.put("start_time_min", startMinute);
info.put("end_time_hour", endHour);
info.put("end_time_min", endMinute);

//목록-강사
DataSet tutors = courseTutor.query(
    "SELECT a.*, t.*, u.login_id "
    + " FROM " + courseTutor.table + " a "
    + " INNER JOIN " + tutor.table + " t ON t.user_id = a.user_id "
    + " INNER JOIN " + user.table + " u ON t.user_id = u.id "
    + " WHERE a.course_id = " + cid + ""
);

//출력
p.setLayout("poplayer");
p.setBody("course.lesson_insert");
p.setVar("p_title", "화상강의관리");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setVar("modify", true);
p.setVar("study_sdate", courseInfo.s("study_sdate"));
p.setVar("study_edate", courseInfo.s("study_edate"));
p.setVar(info);

p.setLoop("hours", mcal.getHours());
p.setLoop("minutes", mcal.getMinutes(5));
p.setLoop("tutors", tutors);

p.display();

%>