<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//객체
LessonDao lesson = new LessonDao();
CourseLessonDao courseLesson = new CourseLessonDao();
CourseProgressDao courseProgress = new CourseProgressDao();
FileDao file = new FileDao();

ExamDao exam = new ExamDao();
HomeworkDao homework = new HomeworkDao();
ForumDao forum = new ForumDao();
SurveyDao survey = new SurveyDao();
ExamUserDao examUser = new ExamUserDao();
HomeworkUserDao homeworkUser = new HomeworkUserDao();
ForumUserDao forumUser = new ForumUserDao();
SurveyUserDao surveyUser = new SurveyUserDao();

//변수
boolean isPrev = false;
boolean isPrevExam = false;
boolean isPrevHomework = false;
boolean isPrevForum = false;
boolean isPrevSurvey = false;

//목록-시험
DataSet exams = courseModule.query(
	"SELECT a.*, e.exam_nm, u.user_id "
	+ " FROM " + courseModule.table + " a "
	+ " LEFT JOIN " + examUser.table + " u ON "
		+ " u.exam_id = a.module_id AND u.course_user_id = " + cuid + " AND u.user_id = " + userId + " "
		+ " AND u.submit_yn = 'Y' AND u.status = 1 "
	+ " LEFT JOIN " + exam.table + " e ON a.module_id = e.id "
	+ " WHERE a.course_id = " + courseId + " AND a.status = 1 "
	+ " AND a.apply_type = '2' AND a.module = 'exam' AND a.chapter = 0 "
);
while(exams.next()) {
	if("".equals(exams.s("user_id"))) {
		isPrev = true;
		isPrevExam = true;
	}
}

//목록-과제
DataSet homeworks = courseModule.query(
	"SELECT a.*, h.homework_nm, u.user_id "
	+ " FROM " + courseModule.table + " a "
	+ " LEFT JOIN " + homeworkUser.table + " u ON "
		+ " u.homework_id = a.module_id AND u.course_user_id = " + cuid + " AND u.user_id = " + userId + " "
		+ " AND u.submit_yn = 'Y' AND u.status = 1 "
	+ " LEFT JOIN " + homework.table + " h ON a.module_id = h.id "
	+ " WHERE a.course_id = " + courseId + " AND a.status = 1 "
	+ " AND a.apply_type = '2' AND a.module = 'homework' AND a.chapter = 0 "
);
while(homeworks.next()) {
	if("".equals(homeworks.s("user_id"))) {
		isPrev = true;
		isPrevHomework = true;
	}
}

//목록-토론
DataSet forums = courseModule.query(
	"SELECT a.*, f.forum_nm, u.user_id "
	+ " FROM " + courseModule.table + " a "
	+ " LEFT JOIN " + forumUser.table + " u ON "
		+ " u.forum_id = a.module_id AND u.course_user_id = " + cuid + " AND u.user_id = " + userId + " "
		+ " AND u.submit_yn = 'Y' AND u.status = 1 "
	+ " LEFT JOIN " + forum.table + " f ON a.module_id = f.id "
	+ " WHERE a.course_id = " + courseId + " AND a.status = 1 "
	+ " AND a.apply_type = '2' AND a.module = 'forum' AND a.chapter = 0 "
);
while(forums.next()) {
	if("".equals(forums.s("user_id"))) {
		isPrev = true;
		isPrevForum = true;
	}
}

//목록-설문
DataSet surveys = courseModule.query(
	"SELECT a.*, s.survey_nm, u.user_id "
	+ " FROM " + courseModule.table + " a "
	+ " LEFT JOIN " + surveyUser.table + " u ON "
		+ " u.survey_id = a.module_id AND u.course_user_id = " + cuid + " AND u.user_id = " + userId + " "
		+ " AND u.status = 1 "
	+ " LEFT JOIN " + survey.table + " s ON a.module_id = s.id "
	+ " WHERE a.course_id = " + courseId + " AND a.status = 1 "
	+ " AND a.apply_type = '2' AND a.module = 'survey' AND a.chapter = 0 "
);
while(surveys.next()) {
	if("".equals(surveys.s("user_id"))) {
		isPrev = true;
		isPrevSurvey = true;
	}
}

//변수
String limitDay = m.addDate("D", (cinfo.i("limit_day") - 1) * -1, today, "yyyyMMdd");

//목록
DataSet list = courseLesson.query(
	"SELECT a.* "
	+ ", l.onoff_type, l.lesson_nm, l.start_url, l.mobile_a, l.mobile_i, l.lesson_file, l.lesson_type, l.content_width, l.content_height "
	+ ", c.complete_yn, c.ratio, c.last_date "
	+ ", ( CASE WHEN c.last_date BETWEEN '" + limitDay + "000000' AND '" + today + "235959' THEN 'Y' ELSE 'N' END ) is_study "
	+ " FROM " + courseLesson.table + " a "
	+ " INNER JOIN " + lesson.table + " l ON a.lesson_id = l.id "
	+ " LEFT JOIN " + courseProgress.table + " c ON c.course_user_id = " + cuid + " AND a.lesson_id = c.lesson_id "
	+ " WHERE a.status = 1 AND a.course_id = " + courseId + " "
	+ " ORDER BY a.chapter ASC "
);

//학습제한-속진여부
boolean limitFlag = false;
if(cinfo.b("limit_lesson_yn")) {
	int limitLessonCnt = courseProgress.findCount("course_user_id = " + cuid + " AND (last_date BETWEEN '" + limitDay + "000000' AND '" + today + "235959')");
	limitFlag = (cinfo.i("limit_day") <= 0 || cinfo.i("limit_lesson") <= 0 ? 0 : cinfo.i("limit_lesson")) <= limitLessonCnt;
}

//수강대기, 종료
boolean isWait = "W".equals(cuinfo.s("progress"));
boolean isEnd = "E".equals(cuinfo.s("progress"));
//boolean isRestudy = "R".equals(cuinfo.s("progress"));

int lastChapter = 1;
while(list.next()) {
	if(list.b("complete_yn")) lastChapter = list.i("chapter") + 1;
	list.put("lesson_nm_conv", m.cutString(list.s("lesson_nm"), 30));
	list.put("study_date", !"".equals(list.s("last_date")) ? m.time("yyyy.MM.dd HH:mm", list.s("last_date")) : "-");
	list.put("complete_conv", list.b("complete_yn") ? "Y" : "N");
	//list.put("attend_cnt", list.i("attend_cnt"));
	list.put("lesson_type_conv", m.getItem(list.s("lesson_type"), lesson.offlineTypes));

	list.put("ratio_conv", m.nf(list.d("ratio"), 1));

	if("N".equals(list.s("onoff_type"))) {
		list.put("online_block", true);
		list.put("start_date_conv", m.time("yyyy.MM.dd", list.s("start_date")));
		list.put("end_date_conv", m.time("yyyy.MM.dd", list.s("end_date")));
		list.put("date_conv", list.s("start_date_conv") + " - " + list.s("end_date_conv"));
	} else if("F".equals(list.s("onoff_type"))) {
		list.put("online_block", false);
		list.put("start_date_conv", m.time("yyyy.MM.dd HH:mm", list.s("start_date") + list.s("start_time")));
		list.put("end_date_conv", m.time("HH:mm", list.s("start_date") + list.s("end_time")));
		list.put("date_conv", list.s("start_date_conv") + " - " + list.s("end_date_conv"));
	}

	list.put("lesson_file_conv", m.encode(list.s("lesson_file")));
	list.put("lesson_file_path", m.getUploadUrl(list.s("lesson_file")));
	list.put("lesson_file_ext", file.getFileIcon(list.s("lesson_file")));
	list.put("lesson_file_ek", m.encrypt(list.s("lesson_file") + m.time("yyyyMMdd")));

	boolean isOpen = true;

	if(isOpen && limitFlag) { //속진제한
		isOpen = "Y".equals(list.s("is_study"));
		list.put("msg", cinfo.i("limit_day") + "일 " +  cinfo.i("limit_lesson") + "차시로 학습이 제한되어있습니다.\\n관리자에게 문의하십시오.");
	}
	if(isOpen && cinfo.b("period_yn")) { //수강기간 제한
		isOpen = list.i("start_date") <= m.parseInt(today) && list.i("end_date") >= m.parseInt(today);
		list.put("msg", "학습기간이 아닙니다.\\n관리자에게 문의하십시오.");
	}
	if(isOpen && cinfo.b("lesson_order_yn")) { //순차적용
		isOpen = lastChapter >= list.i("chapter");
		list.put("msg", (list.i("chapter") - 1) + "장을 학습하셔야 합니다.\\n(순차학습 과정입니다.)\\n관리자에게 문의하십시오.");
	}

	if("Y".equals(list.s("complete_yn"))) isOpen = true;

	if(isEnd || isWait) { //수강 대기, 종료
		isOpen = false;
		list.put("msg", "수강기간이 아닙니다.");
	}


	if(isPrev) {
		isOpen = false;
		if(isPrevExam) list.put("msg", "선행해야 하는 시험이 있습니다.");
		else if(isPrevHomework) list.put("msg", "선행해야 하는 과제가 있습니다.");
		else if(isPrevForum) list.put("msg", "선행해야 하는 토론이 있습니다.");
		else if(isPrevSurvey) list.put("msg", "선행해야 하는 설문이 있습니다.");
	}

	list.put("open_block", isOpen);

}

//선행
DataSet prev = new DataSet(); prev.addRow();
if(isPrev) {
	if(isPrevExam) {
		prev.put("msg", "선행해야 하는 시험이 있습니다. 시험방으로 이동합니다.");
		prev.put("link", "exam.jsp?cuid=" + cuid);
	} else if(isPrevHomework) {
		prev.put("msg", "선행해야 하는 과제가 있습니다. 과제방으로 이동합니다.");
		prev.put("link", "homework.jsp?cuid=" + cuid);
	} else if(isPrevForum) {
		prev.put("msg", "선행해야 하는 토론이 있습니다. 토론방으로 이동합니다.");
		prev.put("link", "forum.jsp?cuid=" + cuid);
	} else if(isPrevSurvey) {
		prev.put("msg", "선행해야 하는 설문이 있습니다. 설문방으로 이동합니다.");
		prev.put("link", "survey.jsp?cuid=" + cuid);
	}
}


//출력
p.setLayout(ch);
p.setBody("classroom.curriculum");
p.setVar("query", m.qs());

p.setLoop("list", list);

p.setVar("prev_block", isPrev);
p.setVar("prev", prev);
p.display();

%>