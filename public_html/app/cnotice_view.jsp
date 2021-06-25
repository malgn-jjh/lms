<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//JSON

//기본키
int cuid = f.getInt("cuid");
int id = m.ri("id");
if(cuid == 0 || id == 0) {
	_error.put("error_code", "2300");
	_error.put("error_msg", "잘못된 접근입니다.");
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}

//변수
String code = "notice";

//객체
DataObject user = new DataObject("TB_USER");
DataObject course = new DataObject("LM_COURSE");
DataObject courseUser = new DataObject("LM_COURSE_USER");
DataObject courseModule = new DataObject("LM_COURSE_MODULE");

//정보
DataSet cuinfo = courseUser.query(
	"SELECT a.*, c.course_nm, c.course_type, c.onoff_type, t.user_nm tutor_name, c.subject_id "
	+ " FROM " + courseUser.table + " a "
	+ " INNER JOIN " + course.table + " c ON a.course_id = c.id AND c.site_id = " + siteId + " "
	+ " LEFT JOIN " + user.table + " t ON a.tutor_id = t.id"
	+ " INNER JOIN " + user.table + " u ON a.user_id = u.id"
	+ " WHERE a.id = " + cuid + " AND a.user_id = '" + userId + "' AND a.status IN (1,3)"
);
if(!cuinfo.next()) {
	_error.put("error_code", "2320");
	_error.put("error_msg", "해당 수강정보가 없습니다.");
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}

//정보-과정
String courseId = cuinfo.s("course_id");
DataSet cinfo = course.find("id = " + courseId + " AND site_id = " + siteId + "");
if(!cinfo.next()) {
	_error.put("error_code", "2330");
	_error.put("error_msg", "해당 과정정보가 없습니다.");
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}


//객체
DataObject board = new DataObject("CL_BOARD");
DataObject post = new DataObject("CL_POST");
DataObject file = new DataObject("CL_FILE");

//정보-게시판
DataSet binfo = board.find("course_id = " + courseId + " AND code = '" + code + "' AND status = 1");
if(!binfo.next()) {
	_error.put("error_code", "2340");
	_error.put("error_msg", "해당 게시판 정보가 없습니다.");
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}


//정보
DataSet info = post.find("id = " + id + " AND status = 1");
if(!info.next()) {
	_error.put("error_code", "2350");
	_error.put("error_msg", "해당 정보가 없습니다.");
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}

_data.put("subject", info.s("subject"));
_data.put("content", info.s("content"));
_data.put("writer", info.s("writer"));
_data.put("reg_date_conv", m.time("yyyy.MM.dd", info.s("reg_date")));
_return.put("data", _data);
out.print(_return.toString());

%>