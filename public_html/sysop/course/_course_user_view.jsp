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
UserDao user = new UserDao();
CourseDao course = new CourseDao();
CourseUserDao courseUser = new CourseUserDao();
CourseLessonDao courseLesson = new CourseLessonDao();
CourseProgressDao courseProgress = new CourseProgressDao();
CourseModuleDao courseModule = new CourseModuleDao();
LessonDao lesson = new LessonDao();

ExamUserDao examUser = new ExamUserDao();
HomeworkUserDao homeworkUser = new HomeworkUserDao();
ForumUserDao forumUser = new ForumUserDao();
SurveyUserDao surveyUser = new SurveyUserDao();

//변수
String today = m.time("yyyyMMdd");
String now = m.time("yyyyMMddHHmmss");

//정보
DataSet cuinfo = courseUser.query(
	"SELECT a.* "
	+ ", (CASE WHEN '" + today + "' BETWEEN a.start_date AND a.end_date THEN 'Y' ELSE 'N' END) is_study "
	+ ", u.user_nm, u.login_id "
	+ ", m.user_nm close_user_nm "
	+ ", c.assign_progress, c.assign_exam, c.assign_homework, c.assign_forum, c.assign_etc "
	+ " FROM " + courseUser.table + " a "
	+ " INNER JOIN " + course.table + " c ON c.id = a.course_id "
	+ " INNER JOIN " + user.table + " u ON a.user_id = u.id "
	+ " LEFT JOIN " + user.table + " m ON a.close_user_id = m.id "
	+ " WHERE a.id = " + id + " "
	+ ("C".equals(userKind) ? " AND course_id IN (" + manageCourses + ") " : "")
);
if(!cuinfo.next()) { m.jsError("해당 정보가 없습니다."); return; }

//폼체크
f.addElement("start_date", null, "hname:'학습 시작일', required:'Y'");
f.addElement("end_date", null, "hname:'학습 종료일', required:'Y'");

//수강기간 수정
if(m.isPost() && f.validate()) {

	courseUser.item("start_date", m.time("yyyyMMdd", f.get("start_date")));
	courseUser.item("end_date", m.time("yyyyMMdd",f.get("end_date")));
	courseUser.item("mod_date", now);
	if(!courseUser.update("id = " + id + "")) { m.jsError("수정하는 중 오류가 발생했습니다."); return; }

	m.jsReplace("course_user_view.jsp?" + m.qs());
	return;
}


//목록-차시
DataSet lessons = courseLesson.query(
	"SELECT a.*"
	+ ", l.lesson_nm, l.lesson_type "
	+ ", p.course_user_id, p.complete_yn, p.study_time, p.ratio, p.complete_date, p.last_date "
	+ " FROM " + courseLesson.table + " a "
	+ " INNER JOIN " + lesson.table + " l ON a.lesson_id = l.id "
	+ " LEFT JOIN " + courseProgress.table + " p ON "
		+ " p.course_user_id = " + id + " AND p.lesson_id = a.lesson_id "
	+ " WHERE a.status = 1 AND a.course_id = " + courseId + " "
	+ " ORDER BY a.chapter ASC "
);



//처리-전체완료
if("all".equals(m.rs("mode"))) {
	lessons.first();
	while(lessons.next()) {
		if(lessons.i("course_user_id") != 0) {
			if(!lessons.b("complete_yn")) {
				courseProgress.item("ratio", 100);
				courseProgress.item("complete_yn", "Y");
				//courseProgress.item("last_date", now);
				courseProgress.item("complete_date", now);
				courseProgress.item("change_user_id", userId);
				if(!courseProgress.update("course_id = " + courseId + " AND lesson_id = " + lessons.s("lesson_id") + " AND course_user_id = " + id + "" )) { }
			}
		} else {
			courseProgress.item("course_id", courseId);
			courseProgress.item("lesson_id", lessons.i("lesson_id"));
			courseProgress.item("chapter", lessons.i("chapter"));
			courseProgress.item("course_user_id", id);

			courseProgress.item("user_id", cuinfo.i("user_id"));
			courseProgress.item("lesson_type", lessons.s("lesson_type"));
			courseProgress.item("study_page", 0);
			courseProgress.item("study_time", 0);
			courseProgress.item("curr_page", "");
			courseProgress.item("curr_time", 0);
			courseProgress.item("last_time", 0);
			courseProgress.item("paragraph", "");
			courseProgress.item("ratio", 100);
			courseProgress.item("complete_yn", "Y");
			courseProgress.item("complete_date", now);
			courseProgress.item("view_cnt", 1);
			//courseProgress.item("last_date", now);
			courseProgress.item("change_user_id", userId);
			courseProgress.item("reg_date", now);
			courseProgress.item("status", 1);
			courseProgress.item("site_id", siteId);

			if(!courseProgress.insert()) { }
		}
	}

	courseUser.setProgressRatio(id);
	courseUser.setCourseUserScore(id, "progress"); //점수일괄업데이트

	m.jsReplace("course_user_view.jsp?" + m.qs("mode,chapter,lid"));
	return;


//처리-완료
} else if("complete".equals(m.rs("mode"))) {

	//기본키
	int chapter = m.ri("chapter");
	int lid = m.ri("lid");
	if(chapter == 0 || lid == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

	DataSet linfo = courseLesson.query(
		"SELECT a.*"
		+ ", l.lesson_nm, l.lesson_type "
		+ ", p.course_user_id, p.complete_yn, p.ratio, p.complete_date, p.last_date "
		+ " FROM " + courseLesson.table + " a "
		+ " INNER JOIN " + lesson.table + " l ON a.lesson_id = l.id "
		+ " LEFT JOIN " + courseProgress.table + " p ON "
			+ " p.course_id = a.course_id AND p.lesson_id = a.lesson_id AND p.course_user_id = " + id + " "
		+ " WHERE a.status = 1 AND a.course_id = " + courseId + " AND a.lesson_id = " + lid
	);
	if(!linfo.next()) { m.jsError("해당 정보가 없습니다."); return; }

	//제한
	if(linfo.b("complete_yn")) { m.jsError("이미 완료된 차시입니다."); return; }

	if(linfo.i("course_user_id") != 0) {

		if(!linfo.b("complete_yn")) {
			courseProgress.item("ratio", 100);
			courseProgress.item("complete_yn", "Y");
			courseProgress.item("complete_date", now);
			courseProgress.item("change_user_id", userId);
			if(!courseProgress.update("course_user_id = " + id + " AND lesson_id = " + lid)) {
				m.jsError("완료 처리하는 하는 중 오류가 발생했습니다.");
				return;
			}
		}

	} else {
		courseProgress.item("course_id", courseId);
		courseProgress.item("lesson_id", linfo.i("lesson_id"));
		courseProgress.item("chapter", linfo.i("chapter"));
		courseProgress.item("course_user_id", id);

		courseProgress.item("user_id", cuinfo.i("user_id"));
		courseProgress.item("lesson_type", linfo.s("lesson_type"));
		courseProgress.item("study_page", 0);
		courseProgress.item("study_time", 0);
		courseProgress.item("curr_page", "");
		courseProgress.item("curr_time", 0);
		courseProgress.item("last_time", 0);
		courseProgress.item("paragraph", "");
		courseProgress.item("ratio", 100);
		courseProgress.item("complete_yn", "Y");
		courseProgress.item("complete_date", now);
		courseProgress.item("view_cnt", 1);
		courseProgress.item("change_user_id", userId);
		courseProgress.item("reg_date", now);
		courseProgress.item("status", 1);
		courseProgress.item("site_id", siteId);

		if(!courseProgress.insert()) { m.jsError("완료 처리하는 하는 중 오류가 발생했습니다.");	return;	}
	}

	courseUser.setProgressRatio(id);
	courseUser.setCourseUserScore(id, "progress"); //점수일괄업데이트

	m.jsReplace("course_user_view.jsp?" + m.qs("mode,chapter,lid"));
	return;

//처리-진도삭제
} else if("undo".equals(m.rs("mode"))) {

	//기본키
	int chapter = m.ri("chapter");
	int lid = m.ri("lid");
	if(chapter == 0 || lid == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

	DataSet linfo = courseLesson.query(
		"SELECT a.*"
		+ ", l.lesson_nm, l.lesson_type "
		+ ", p.course_user_id, p.complete_yn, p.ratio, p.complete_date, p.last_date "
		+ " FROM " + courseLesson.table + " a "
		+ " INNER JOIN " + lesson.table + " l ON a.lesson_id = l.id "
		+ " INNER JOIN " + courseProgress.table + " p ON "
			+ " p.course_id = a.course_id AND p.lesson_id = a.lesson_id AND p.course_user_id = " + id + " "
		+ " WHERE a.status = 1 AND a.course_id = " + courseId + " AND a.lesson_id = " + lid
	);
	if(!linfo.next()) { m.jsError("해당 정보가 없습니다."); return; }

	//제한
	if(!linfo.b("complete_yn")) { m.jsError("완료된 차시가 아닙니다."); return; }

	courseProgress.item("study_page", 0);
	courseProgress.item("study_time", 0);
	courseProgress.item("curr_page", "");
	courseProgress.item("curr_time", 0);
	courseProgress.item("last_time", 0);
	courseProgress.item("paragraph", "");
	courseProgress.item("ratio", 0);
	courseProgress.item("complete_yn", "N");
	courseProgress.item("complete_date", "");
	courseProgress.item("last_date", "");
	courseProgress.item("change_user_id", userId);
	if(!courseProgress.update("course_user_id = " + id + " AND lesson_id = " + lid)) {
		m.jsError("진도삭제 처리하는 하는 중 오류가 발생했습니다.");
		return;
	}

	courseUser.setProgressRatio(id);
	courseUser.setCourseUserScore(id, "progress"); //점수일괄업데이트

	m.jsReplace("course_user_view.jsp?" + m.qs("mode,chapter,lid"));
	return;

}


//포맷팅
cuinfo.put("status_conv", m.getItem(cuinfo.s("status"), courseUser.statusList));
cuinfo.put("period_block", "Y".equals(cuinfo.s("period_yn")));
cuinfo.put("total_score_conv", m.nf(cuinfo.d("total_score"), 1));
cuinfo.put("progress_ratio_conv", m.nf(cuinfo.d("progress_ratio"), 1));
cuinfo.put("exam_value_conv", m.nf(cuinfo.d("exam_value"), 1));
cuinfo.put("homework_value_conv", m.nf(cuinfo.d("homework_value"), 1));
cuinfo.put("forum_value_conv", m.nf(cuinfo.d("forum_value"), 1));
cuinfo.put("etc_value_conv", m.nf(cuinfo.d("etc_value"), 1));

cuinfo.put("progress_score_conv", m.nf(cuinfo.d("progress_score"), 1));
cuinfo.put("exam_score_conv", m.nf(cuinfo.d("exam_score"), 1));
cuinfo.put("homework_score_conv", m.nf(cuinfo.d("homework_score"), 1));
cuinfo.put("forum_score_conv", m.nf(cuinfo.d("forum_score"), 1));
cuinfo.put("etc_score_conv", m.nf(cuinfo.d("etc_score"), 1));

cuinfo.put("complete_conv", cuinfo.b("complete_yn") ? "수료" : "-");
cuinfo.put("close_conv", cuinfo.b("close_yn") ? "마감" : "미마감");

cuinfo.put("start_date_conv", m.time("yyyy-MM-dd", cuinfo.s("start_date")));
cuinfo.put("end_date_conv", m.time("yyyy-MM-dd", cuinfo.s("end_date")));
cuinfo.put("mod_date_conv", !"".equals(cuinfo.s("mod_date")) ? m.time("yyyy.MM.dd HH:mm", cuinfo.s("mod_date")) : "-");
cuinfo.put("reg_date_conv", m.time("yyyy.MM.dd HH:mm", cuinfo.s("reg_date")));
cuinfo.put("close_date_conv", !"".equals(cuinfo.s("close_date")) ? m.time("yyyy.MM.dd HH:mm", cuinfo.s("close_date")) : "-");
cuinfo.put("close_user_nm", !"".equals(cuinfo.s("close_user_nm")) ? cuinfo.s("close_user_nm") : "-");

//평가항목
DataSet evaluations = m.arr2loop(courseModule.evaluations);
while(evaluations.next()) {
	cuinfo.put(evaluations.s("id") + "_cnt", 0);
	cuinfo.put(evaluations.s("id") + "_join_cnt", 0);
}
DataSet evalCounts = courseModule.query(
	"SELECT a.module, COUNT(*) cnt "
	+ " FROM " + courseModule.table + " a "
	+ " WHERE a.course_id = " + courseId + " AND status = 1 "
	+ " GROUP BY a.module "
);
while(evalCounts.next()) {
	cuinfo.put(evalCounts.s("module") + "_cnt", evalCounts.i("cnt"));
}


//참여
cuinfo.put("exam_join_cnt", examUser.findCount("course_user_id = " + id + " AND status = 1 AND submit_yn = 'Y'"));
cuinfo.put("homework_join_cnt", homeworkUser.findCount("course_user_id = " + id + " AND status = 1 AND submit_yn = 'Y'"));
cuinfo.put("forum_join_cnt", forumUser.findCount("course_user_id = " + id + " AND status = 1 AND submit_yn = 'Y'"));
cuinfo.put("survey_join_cnt", surveyUser.findCount("course_user_id = " + id + " AND status = 1"));


//포맷팅
while(lessons.next()) {
	lessons.put("subject_conv", m.cutString(lessons.s("subject"), 60));
	lessons.put("last_date_conv", !"".equals(lessons.s("last_date")) ? m.time("yyyy.MM.dd HH:mm", lessons.s("last_date")) : "-");
	lessons.put("complete_date_conv", !"".equals(lessons.s("complete_date")) ? m.time("yyyy.MM.dd HH:mm", lessons.s("complete_date")) : "-");
	lessons.put("ratio_conv", m.nf(lessons.d("ratio"), 1));
	lessons.put("complete_conv", lessons.b("complete_yn") ? "완료" : "-");
}

//출력
p.setBody("course.course_user_view");
p.setVar("p_title", "수강상세정보");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id, mode, cp, pchapter"));
p.setVar("form_script", f.getScript());

p.setVar("cuinfo", cuinfo);
p.setLoop("lessons", lessons);

p.setVar("tab_user", "current");
p.display();

%>