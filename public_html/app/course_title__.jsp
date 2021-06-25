<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
int cuid = f.getInt("cuid");
if(cuid == 0) {
	_error.put("error_code", "2300");
	_error.put("error_msg", "잘못된 접근입니다." + cuid);
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}

//객체
DataObject user = new DataObject("TB_USER");
DataObject course = new DataObject("LM_COURSE");
DataObject courseUser = new DataObject("LM_COURSE_USER");


//정보
DataSet cuinfo = courseUser.query(
	"SELECT a.*, c.course_nm, c.course_type, c.onoff_type, c.subject_id "
	+ " FROM " + courseUser.table + " a "
	+ " INNER JOIN " + course.table + " c ON a.course_id = c.id AND c.site_id = " + siteId + " "
	+ " LEFT JOIN " + user.table + " t ON a.tutor_id = t.id "
	+ " WHERE a.id = " + cuid + " AND a.user_id = '" + userId + "' AND a.status IN (1,3)"
);
if(!cuinfo.next()) {
	_error.put("error_code", "2300");
	_error.put("error_msg", "해당 수강정보가 없습니다.");
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}

_data.put("course_nm", cuinfo.s("course_nm"));
_return.put("data", _data);
_return.put("error", _error);
out.print(_return.toString());

%>