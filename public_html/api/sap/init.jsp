<%@ include file="/init.jsp"%><%@ page import="org.json.*" %><%

//JSON
JSONObject _ret = new JSONObject();
_ret.put("error", "");

//변수
boolean error = false;
String token = m.rs("token"); //.toLowerCase();
String format = "json";

//객체
ApiLogDao apiLog = new ApiLogDao(format, request, response);

//등록
//apiLog.d(out);
if(!apiLog.insertLog(siteId, m.qs())) {
	_ret.put("error", "cannot insert db");
	apiLog.printList(out, _ret, "euc-kr");
	return;
}

//제한-사이트
if(114 != siteId && 1 != siteId) {
	_ret.put("error", "Invalid site");
	apiLog.printList(out, _ret, "euc-kr");
	return;
}

//POST전용
/*
if(!error && !m.isPost()) {
	_ret.put("error", "Invalid method");
	error = true;
}
*/

//사용량
if(!error && siteinfo.i("api_limit")
	<= apiLog.getOneInt(
		"SELECT COUNT(*) FROM " + apiLog.table + " WHERE site_id = " + siteId
		+ " AND reg_date >= '" + m.time("yyyyMM01000000") + "' AND reg_date <= '" + m.time("yyyyMMddHHmmss") + "' AND return_code = '000'")
	) {
	_ret.put("error", "api limit");
	error = true;
}

%>