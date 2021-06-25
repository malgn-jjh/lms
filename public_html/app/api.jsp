<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//폼입력
int cuid = m.ri("cuid");
int chapter = m.ri("chapter");
int lid = m.ri("lid");
int currTime = m.parseInt(m.replace(m.nf(m.parseDouble(m.rs("curr_time")), 0), ",", ""));
int currPage = m.parseInt(m.replace(m.nf(m.parseDouble(m.rs("curr_page")), 0), ",", ""));
int studyTime = m.parseInt(m.replace(m.nf(m.parseDouble(m.rs("study_time")), 0), ",", ""));
int lastTime = m.parseInt(m.replace(m.nf(m.parseDouble(m.rs("last_time")), 0), ",", ""));		//진행된 최대 위치

//기본키
/*
if(cuid == 0 || lid == 0  || chapter == 0 || currTime <= 0) {
	p.setVar("error_code", "0001");
	p.setVar("error_msg", "기본키는 반드시 지정해야 합니다.");
	p.print(out, "../html/mobile/api.xml");
	return;
}
*/


Vector<String> logVec = new Vector<String>();
logVec.add("cuid : " + cuid);
logVec.add("chapter : " + chapter);
logVec.add("lesson_id : " + lid);
logVec.add("curr_time : " + currTime);
logVec.add("curr_page : " + currPage);
logVec.add("study_time : " + studyTime);
logVec.add("user_id : " + userId);

//객체
DataObject course = new DataObject("LM_COURSE");
DataObject courseLesson = new DataObject("LM_COURSE_LESSON");
DataObject courseProgress = new DataObject("LM_COURSE_PROGRESS"); courseProgress.PK = "course_id,lesson_id,chapter,course_user_id";
DataObject courseUser = new DataObject("LM_COURSE_USER");
DataObject lesson = new DataObject("LM_LESSON");

//정보-수강생
DataSet cuinfo = courseUser.find("id = " + cuid + " AND status IN (1, 3)");
if(!cuinfo.next()) return;
userId = cuinfo.i("user_id");

//정보-과정
DataSet cinfo = course.find("id = " + cuinfo.i("course_id") + " AND site_id = " + siteId + "");
if(!cinfo.next()) return;

//제한-학습종료일 경우 진도율을 저장하지 않음
if(0 < m.diffDate("D", cuinfo.s("end_date"), m.time("yyyyMMdd"))) return;

//if("Y".equals(cuinfo.s("end_yn"))) return;
//if(cuinfo.d("progress_ratio") >= 100.0) return;

//정보-차시
DataSet linfo = courseLesson.query(
	"SELECT b.* "
	+ " FROM " + courseLesson.table + " a "
	+ " INNER JOIN " + lesson.table + " b ON a.lesson_id = b.id"
	+ " WHERE a.status = 1 "
	+ " AND a.course_id = " + cuinfo.i("course_id") + " AND a.lesson_id = " + lid + " "
	+ " AND a.chapter = " + chapter + " "
);
if(!linfo.next()) return;

//진도저장
int viewcnt = 1;
String completeYn = "N";
String preCompleteYn = "N";				//이전 진도 정보 완료여부

//정보-진도
boolean exists = false;				//처음 수강 여부
DataSet cpinfo = courseProgress.find(
	"course_id = " + cuinfo.i("course_id") + " AND lesson_id = " + lid + " "
	+ " AND chapter = " + chapter + " AND course_user_id = " + cuid + " "
);
if(cpinfo.next()) {
	exists = true;
	preCompleteYn = cpinfo.s("complete_yn");

	//진도100이고 수강완료면...
	if(cpinfo.d("ratio") >= 100.0 && cpinfo.b("complete_yn")) return;

	studyTime = cpinfo.i("study_time") + studyTime;
	if(lastTime < cpinfo.i("last_time")) lastTime = cpinfo.i("last_time");
}

//진행시간 보다 최대위치가 클경우 오류로 인정하여 최대위치를 진행 시간으로 대체
//if(studyTime < lastTime) { lastTime = studyTime; }

double ratio = Math.min(100.0, (lastTime / (linfo.d("total_time") * 60)) * 100);			//진도
//boolean isTime = ((linfo.i("complete_time") == 0 ? linfo.d("total_time") : linfo.i("complete_time")) * 60) <= lastTime;									//이수 충족여부
boolean isTime = (linfo.i("complete_time") * 60) <= lastTime;									//이수 충족여부
double climit = 100.0;	//이수기준비율

if(isTime || ratio >= climit) completeYn = "Y";

courseProgress.item("course_id", cuinfo.i("course_id"));
courseProgress.item("lesson_id", linfo.i("id"));
courseProgress.item("chapter", chapter);
courseProgress.item("course_user_id", cuid);

courseProgress.item("user_id", cuinfo.i("user_id"));
courseProgress.item("lesson_type", linfo.s("lesson_type"));
courseProgress.item("study_page", 0);
courseProgress.item("study_time", studyTime);
courseProgress.item("curr_page", "");
courseProgress.item("curr_time", currTime);
courseProgress.item("last_time", lastTime);
courseProgress.item("paragraph", "");
courseProgress.item("ratio", "Y".equals(completeYn) ? 100.0 : ratio);
courseProgress.item("complete_yn", completeYn);
courseProgress.item("complete_date", "N".equals(preCompleteYn) && "Y".equals(completeYn) ? m.time("yyyyMMddHHmmss") : "");
courseProgress.item("view_cnt", viewcnt);
courseProgress.item("last_date", m.time("yyyyMMddHHmmss"));
courseProgress.item("status", 1);
courseProgress.item("site_id", siteId);

if(exists) {
	if(!courseProgress.update(
		"course_id = " + cuinfo.i("course_id") + " AND lesson_id = " + lid + " "
		+ " AND chapter = " + chapter + " AND course_user_id = " + cuid + " ")
	) { return; }
} else {
	courseProgress.item("reg_date", m.time("yyyyMMddHHmmss"));
	if(!courseProgress.insert()) { return; }
}

m.log("api", "CP INSERT -- " + m.join(" | ", logVec.toArray()));

//수강생 정보 업데이트
//courseUser.setProgressRatio(cuid);
//courseUser.updateScore(cuid, "progress"); //점수일괄업데이트

String[] scoreFields = { "progress", "exam", "homework", "forum", "etc" };
int lessonCnt = courseLesson.findCount("status = 1 AND course_id = " + cuinfo.i("course_id") + ""); //전체 차시
int completedCnt = courseProgress.findCount("course_user_id = " + cuid + " AND complete_yn = 'Y'");
double totalScore = 0.0;
for(int i = 0; i < scoreFields.length; i++) totalScore += cinfo.d(scoreFields[i] + "_score");


if(-1 == courseUser.execute(
	"UPDATE " + courseUser.table + " SET "
	+ " progress_ratio = " + Math.min(100.00, m.round(lessonCnt > 0 ? completedCnt * 100.00 / lessonCnt : 0.00, 2)) + " "
	+ ", progress_score = " + Math.min(cinfo.d("assign_progress"), cinfo.d("assign_progress") * (cinfo.d("progress_ratio") / 100)) + " "
	+ ", total_score = " + Math.min(totalScore, 100.0) + " "
	+ " WHERE id = " + cuid + ""
)) return;

//courseUser.closeUser(cuid, userId);
cuinfo = courseUser.find("id = " + cuid + "");
if(!cuinfo.next()) return;

String failStr = "";
boolean isComplete = true;

for(int i = 0; i < scoreFields.length; i++) {
	if(cinfo.d("limit_" + scoreFields[i]) > cuinfo.d(scoreFields[i] + "_score")) {
		failStr = scoreFields[i];
		isComplete = false;
		break;
	}
}
//총점검사
if(cinfo.d("limit_total_score") > cuinfo.d("total_score")) {
	failStr = "total_score";
	isComplete = false;
}

if(cinfo.b("complete_auto_yn") || isComplete) {
	courseUser.item("close_yn", "Y");
	courseUser.item("complete_yn", isComplete ? "Y" : "N");
	courseUser.item("complete_no", cuid);
	courseUser.item("close_date", m.time("yyyyMMddHHmmss"));
	courseUser.item("close_user_id", userId);
	courseUser.item("fail_reason", failStr);

	if(!courseUser.update("id = " + cuid + "")) return;
}

m.log("api", m.join(" | ", logVec.toArray()));

p.setVar("error_code", "0");
p.print(out, "../html/mobile/api.xml");

%>