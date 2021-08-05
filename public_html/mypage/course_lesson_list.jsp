<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//객체
TutorDao tutor = new TutorDao();
CourseDao course = new CourseDao();
CourseLessonDao courseLesson = new CourseLessonDao();
CourseTutorDao courseTutor = new CourseTutorDao();
LessonDao lesson = new LessonDao();
KtRemoteDao ktRemote = new KtRemoteDao(siteId);

//변수
DataSet tinfo = tutor.find("user_id = " + userId + " AND site_id = " + siteId);
if(!tinfo.next()){
    m.jsError("잘못된 접근입니다."); return;
}
String tutorId = tinfo.s("user_id");

String ord = m.rs("ord", "id desc");
ord = m.getItem(ord.toLowerCase(), new String[] {
    "id desc=>a.id desc", "id asc=>a.id asc", "cn asc=>c.course_nm asc", "cn desc=>c.course_nm desc"
    , "sd asc=>a.start_date asc", "sd desc=>a.start_date desc", "ed asc=>a.end_date asc", "ed desc=>a.end_date desc"
});
if("".equals(ord)) ord = "a.id desc";


//폼체크
f.addElement("ord", null, null);

//수강중인 과정
DataSet list = course.query(
    " SELECT c.course_nm, c.onoff_type, cl.chapter, cl.twoway_url, l.lesson_nm, l.lesson_type "
    + " FROM " + courseLesson.table + " cl "
    + " INNER JOIN " + course.table + " c ON cl.course_id = c.id "
    + " INNER JOIN " + lesson.table + " l ON l.id = cl.lesson_id "
    + " INNER JOIN " + courseTutor.table + " ct ON ct.course_id = c.id AND user_id = " + tutorId
    + " WHERE c.course_type = 'R' AND c.onoff_type IN ('N', 'F', 'B') AND l.onoff_type IN ('F', 'T') "
    + " AND l.lesson_type = '15'"
    + " AND CONCAT(cl.start_date, cl.start_time) <= '" +  sysNow + "' AND CONCAT(cl.end_date, cl.end_time) >= '" + sysNow + "' "
    + " AND cl.status = 1 "
    + " AND c.site_id = " + siteId
);

while(list.next()){
    String link = "";
    if("15".equals(list.s("lesson_type"))) { link = ktRemote.insertHost(list.s("twoway_url"), userId, userName); }
    list.put("link_url", link);

    list.put("type_conv", m.getValue(list.s("onoff_type"), course.onoffTypes));
    list.put("course_nm_conv", m.cutString(list.s("course_nm"), 40));
    list.put("lesson_nm_conv", m.cutString(list.s("lesson_nm"), 40));
    list.put("chapter_conv", list.i("chapter"));
}

//

//출력
p.setLayout(ch);
p.setBody("mypage.course_lesson_list");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs(""));
p.setVar("form_script", f.getScript());

p.setLoop("list", list);

p.display();

%>