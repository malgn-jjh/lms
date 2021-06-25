<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//JSON

//SSO
/*
if(siteinfo.b("sso_yn") && !"".equals(siteinfo.s("sso_url"))) {
	m.setSession("RETURL", returl);
	m.redirect(siteinfo.s("sso_url"));
	return;
}
*/

//폼입력
String id = m.reqSql("id");
String passwd = m.reqSql("passwd");

//객체
DataObject user = new DataObject("TB_USER");
DataObject group = new DataObject("TB_GROUP");
DataObject groupUser = new DataObject("TB_GROUP_USER");

//로그인
if(m.isPost()) {

	passwd = m.encrypt(passwd, "SHA-256");
	DataSet info = user.find("login_id = '" + id + "' AND passwd = '" + passwd + "' AND site_id = " + siteId + " AND status = 1");
	if(info.next()) {

		String groups = "";
		DataSet list = group.query(
			"SELECT a.* "
			+ " FROM " + groupUser.table + " a "
			+ " WHERE a.site_id = " + siteId + " AND a.status = 1 "
			+ " AND ((a.depts LIKE '%|" + info.i("dept_id") + "|%' "
			+ " AND NOT EXISTS ( "
				+ "SELECT 1 FROM " + groupUser.table + " "
				+ " WHERE add_type = 'D' AND group_id = a.id AND user_id = " + info.i("id") + " "
			+ " ) "
			+ " ) OR ( EXISTS ( "
				+ " SELECT 1 FROM " + groupUser.table + " "
				+ " WHERE add_type = 'A' AND group_id = a.id AND user_id = " + info.i("id") + " "
			+ " ) "
			+ " )) "
		);

		while(list.next()) {
			groups += (!"".equals(groups) ? "," : "") + list.i("id");
		}


		//SESSION
		String ipAddr = request.getRemoteAddr();
		String now = m.time("yyyyMMddHHmmss");
		String sKey = now + ipAddr + browser;
		String newId = m.encrypt(sKey, "SHA-256");
		String device = getDevice(browser);

		_session.item("id", newId);
		_session.item("site_id", siteId);
		_session.item("user_id", info.i("id"));
		_session.item("login_id", info.s("login_id"));
		_session.item("user_nm", info.s("user_nm"));
		_session.item("user_kind", info.s("user_kind"));
		_session.item("dept_id", info.i("dept_id"));
		_session.item("groups", groups);
		_session.item("ip_addr",ipAddr);
		_session.item("agent", browser);
		_session.item("device", device);
		_session.item("update_cnt", 0);
		_session.item("session_date", now);
		_session.item("reg_date", now);
		_session.item("status", 1);
		if(!_session.insert()) {
			_error.put("error_code", "2110");
			_error.put("error_msg", "로그인하는 중 오류가 발생했습니다.");
			_return.put("error", _error);
			out.print(_return.toString());
			return;
		} else {
			if(-1 == _session.execute(
				"DELETE FROM " + _session.table + " "
				+ " WHERE user_id = " + info.i("id") + " AND site_id = " + siteId + " AND id != '" + newId + "'"
			)) {
				if(-1 == _session.execute(
					"DELETE FROM " + _session.table + " "
					+ " WHERE user_id = " + info.i("id") + " AND site_id = " + siteId + " "
				)) { }
				_error.put("error_code", "2120");
				_error.put("error_msg", "로그인하는 중 오류가 발생했습니다.");
				_return.put("error", _error);
				out.print(_return.toString());
				return;
			} else {
				user.item("conn_date", m.time("yyyyMMddHHmmss"));
				if(!user.update("id = " + info.i("id") + "")) {
					_error.put("error_code", "2130");
					_error.put("error_msg", "로그인하는 중 오류가 발생했습니다");
					_return.put("error", _error);
					out.print(_return.toString());
					return;
				}
			}
		}

		_data.put("ssid", newId);
		_return.put("data", _data);
		out.print(_return.toString());
		return;
	}

	_error.put("error_code", "2140");
	_error.put("error_msg", "아이디/비밀번호를 확인하세요.");
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}

_error.put("error_code", "2000");
_error.put("error_msg", "잘못된 접근입니다.");
_return.put("error", _error);
out.print(_return.toString());

%>
<%!

String getDevice(String agent) {
	String result = "unknown";
	if(agent == null || "".equals(agent)) return result;

	result = "PC";
	if(agent.indexOf("iPad") > -1) result = "iPad";
	else if (agent.indexOf("iPhone") > -1) result = "iPhone";
	else if (agent.indexOf("Android") > -1) result = "Android";

	return result;
}

%>