<%@ include file="/init.jsp"%><%@ page import="org.json.*" %><%

//JSON
JSONObject _ret = new JSONObject();
_ret.put("ret_code", "000");
_ret.put("ret_msg", "success");

//변수
boolean error = false;
String token = m.rs("token"); //.toLowerCase();
String format = m.rs("format", "json").toLowerCase();

//객체
ApiLogDao apiLog = new ApiLogDao(format, request, response);

//등록
if(!apiLog.insertLog(siteId, m.qs())) {
	_ret.put("ret_code", "210");
	_ret.put("ret_msg", "cannot insert db");
	apiLog.printList(out, _ret);
	return;
}

//제한-사이트
if(178 != siteId && 1 != siteId) {
	_ret.put("ret_code", "211");
	_ret.put("ret_msg", "invalid site");
	apiLog.printList(out, _ret);
	return;
}

/*
//POST전용
if(!error && !m.isPost()) {
	_ret.put("ret_code", "220");
	_ret.put("ret_msg", "not valid method");
	error = true;
}
*/

//토큰
if(!error && ("".equals(siteinfo.s("api_token")) || !token.equals(siteinfo.s("api_token")))) {
	_ret.put("ret_code", "230");
	_ret.put("ret_msg", "not valid api token");
	error = true;
}

//사용량
if(!error && siteinfo.i("api_limit")
	<= apiLog.getOneInt(
		"SELECT COUNT(*) FROM " + apiLog.table + " WHERE site_id = " + siteId
		+ " AND reg_date >= '" + m.time("yyyyMM01000000") + "' AND reg_date <= '" + m.time("yyyyMMddHHmmss") + "' AND return_code = '000'")
	) {
	_ret.put("ret_code", "240");
	_ret.put("ret_msg", "api limit");
	error = true;
}

if(!error && !"".equals(siteinfo.s("api_ip_addr"))) {
	String[] ipArr = m.split("|", siteinfo.s("api_ip_addr"));
	boolean ipAuth = false;

	for(int i = 0; i < ipArr.length; i++) {
		if(ipArr[i].equals(request.getRemoteAddr())) {
			ipAuth = true;
			break;
		}
	}

	if(!ipAuth) {
		_ret.put("ret_code", "250");
		_ret.put("ret_msg", "unauthorized ip address");
		error = true;
	}
}

%>