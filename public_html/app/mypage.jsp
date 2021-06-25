<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//JSON

//폼입력
String type = m.rs("type", "on");

//객체
DataObject user = new DataObject("TB_USER");
DataObject courseUser = new DataObject("LM_COURSE_USER");
DataObject course = new DataObject("LM_COURSE");

//변수
String[] types = { "R=>정규", "A=>상시" };
String today = m.time("yyyyMMdd");

//정보
DataSet uinfo = user.find("id = " + userId + " AND status = 1");
if(!uinfo.next()) {
	_error.put("error_code", "2310");
	_error.put("error_msg", "회원 정보가 없습니다.");
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}


//목록
DataSet list = new DataSet();

if("on".equals(type)) {

	//수강중인 과정
	list = courseUser.query(
		"SELECT a.*, c.course_nm, c.course_type, c.course_file "
		+ " FROM " + courseUser.table + " a "
		+ " INNER JOIN " + course.table + " c ON a.course_id = c.id "
		+ " WHERE a.user_id = " + userId + " AND a.status IN (0, 1, 3) "
		+ " AND a.close_yn = 'N' AND a.end_date >= '" + today + "' "
		+ " ORDER BY a.start_date ASC, a.id DESC "
	);
	while(list.next()) {
		list.put("start_date_conv", m.time("yyyy.MM.dd", list.s("start_date")));
		list.put("end_date_conv", m.time("yyyy.MM.dd", list.s("end_date")));
		list.put("study_date_conv", list.s("start_date_conv") + " - " + list.s("end_date_conv"));

		list.put("course_nm_conv", m.cutString(list.s("course_nm"), 40));
		// list.put("progress_ratio", m.nf(list.d("progress_ratio"), 1));
		// list.put("total_score", m.nf(list.d("total_score"), 1));

		list.put("type_conv", m.getItem(list.s("course_type"), types));

		list.put("course_file_url", "/html/images/common/noimage_course.gif");
		if(!"".equals(list.s("course_file"))) list.put("course_file_url", m.getUploadUrl(list.s("course_file")));

		String status = "";
		boolean isOpen = false;
		if(list.i("status") == 0) status = "승인대기";
		else if(0 > m.diffDate("D", list.s("start_date"), today)) status = "학습대기";
		else {
			if(list.b("complete_yn")) status = "수료";
			else status = "학습중";
			isOpen = true;
		}

		list.put("status_conv", status);
		list.put("open_block", isOpen);
	}

} else if("done".equals(type)) {

	//종료된 과정
	list = courseUser.query(
		"SELECT a.*, c.course_nm, c.course_type, c.restudy_yn, c.restudy_day, c.course_file "
		+ " FROM " + courseUser.table + " a "
		+ " INNER JOIN " + course.table + " c ON a.course_id = c.id "
		+ " WHERE a.user_id = " + userId + " AND a.status IN (1, 3) "
		+ " AND (a.end_date < '" + today + "' OR a.close_yn = 'Y') "
		+ " ORDER BY a.end_date DESC, a.id DESC "
	);
	while(list.next()) {
		list.put("start_date_conv", m.time("yyyy.MM.dd", list.s("start_date")));
		list.put("end_date_conv", m.time("yyyy.MM.dd", list.s("end_date")));
		list.put("study_date_conv", list.s("start_date_conv") + " - " + list.s("end_date_conv"));

		list.put("course_nm_conv", m.cutString(list.s("course_nm"), 40));
		//list.put("progress_ratio", m.nf(list.d("progress_ratio"), 1));
		//list.put("total_score", m.nf(list.d("total_score"), 1));
		//list.put("type_conv", m.getItem(list.s("course_type"), types));
		list.put("status_conv", list.b("complete_yn") ? "수료" : "미수료");

		list.put("course_file_url", "/html/images/common/noimage_course.gif");
		if(!"".equals(list.s("course_file"))) list.put("course_file_url", m.getUploadUrl(list.s("course_file")));

		list.put("restudy_block", false);
		if(list.b("restudy_yn")) {
			String edate = m.addDate("D", list.i("restudy_day"), list.s("end_date"), "yyyyMMdd");
			list.put("restudy_block", list.b("restudy_yn") && 0 <= m.diffDate("D", today, edate));
		}
		list.put("open_block", list.b("restudy_block"));
	}
}

_return.put("data", new JSONArray(list));
out.print(_return.toString());

%>