<%@ page import="java.util.*,java.io.*,dao.*,malgnsoft.db.*,malgnsoft.util.*,org.json.*" %><%

//request.setCharacterEncoding("utf-8");

String docRoot = Config.getDocRoot();
String jndi = Config.getJndi();

Malgn m = new Malgn(request, response, out);

Form f = new Form("form1");
try { f.setRequest(request); }
catch(Exception ex) { out.print("Overflow file size. - " + ex.getMessage()); return; }


//SITE
DataObject Site = new DataObject("TB_SITE");
DataSet siteinfo = Site.find("(domain = '" + request.getServerName() + "' OR domain2 = '" + request.getServerName() + "') AND status = 1");
if(!siteinfo.next()) { m.jsReplace("/main/guide.jsp", "top"); return; }

String webUrl = "http://" + request.getServerName();
int port = request.getServerPort();
if(port != 80) webUrl += ":" + port;
String dataDir = "/home/" + siteinfo.s("ftp_id") + "/public_html/data";
String tplRoot = "/home/" + siteinfo.s("ftp_id") + "/public_html/html";
f.dataDir = dataDir;
m.dataDir = dataDir;

siteinfo.put("logo_url", "/common/images/default/malgn_logo.jpg");
if(!"".equals(siteinfo.s("logo"))) siteinfo.put("logo_url", m.getUploadUrl(siteinfo.s("logo")));

Page p = new Page(tplRoot);
p.setRequest(request);
p.setPageContext(pageContext);
p.setWriter(out);

int siteId = siteinfo.i("id");
int userId = 0;
String loginId = "";
String userName = "";
String userKind = "";
int userDeptId = 0;
String userGroups = "";

//SESSION
boolean isLogin = false;
String ssid = f.get("ssid");
int sessionMinute = Config.getInt("sessionTime");
DataObject _session = new DataObject("TB_SESSION");
if(!"".equals(ssid)) {
	DataSet _ssinfo = _session.find("id = '" + ssid + "' AND site_id = " + siteId + "");
	if(_ssinfo.next()) {
		if(sessionMinute <= 0 || sessionMinute >= m.diffDate("M", _ssinfo.s("session_date"), m.time("yyyyMMddHHmmss"))) {
			userId = _ssinfo.i("user_id");
			loginId = _ssinfo.s("login_id");
			userName = _ssinfo.s("user_nm");
			userKind = _ssinfo.s("user_kind");
			userDeptId = _ssinfo.i("dept_id");
			userGroups = _ssinfo.s("groups");
			isLogin = true;

			if(-1 == _session.execute(
				"UPDATE " + _session.table + " SET "
				+ " update_cnt = update_cnt + 1 "
				+ ", session_date = '" + m.time("yyyyMMddHHmmss") + "' "
				+ " WHERE id = '" + ssid + "'"
			)) { }
		} else {
			if(-1 ==  _session.execute("DELETE FROM " + _session.table + " WHERE id = '" + ssid + "'")) { }
		}
	}
}

p.setVar("SYS_HTTPHOST", request.getServerName());
p.setVar("SYS_LOGINID", loginId);
p.setVar("SYS_USERNAME", userName);
p.setVar("SYS_SESSIONID", ssid);
p.setVar("SYS_PAGE_URL", request.getRequestURL() + (!"".equals(m.qs()) ? "?" + m.qs() : ""));
p.setVar("SYS_TITLE", siteinfo.s("site_nm"));
p.setVar("webUrl", webUrl);
p.setVar("SITE_INFO", siteinfo);
p.setVar("CURR_DATE", m.time("yyyyMMdd"));
p.setVar("SYS_EK", m.encrypt(loginId + siteinfo.s("sso_key") + m.time("yyyyMMdd"), "SHA-256"));


boolean isAPP = "Y".equals(f.get("app"));
boolean isAndroid = false;
boolean isIOS = false;
String browser = request.getHeader("User-Agent");
if (browser != null && !browser.trim().equals("")) {
	if(browser.contains("Android")) isAndroid = true;
	else if(browser.contains("iPhone") || browser.contains("iPad") || browser.contains("iPod")) isIOS = true;
}

//JSON
JSONObject _return = new JSONObject();
JSONObject _error = new JSONObject();
JSONObject _data = new JSONObject();
_error.put("error_code", "0000"); _error.put("error_msg", "Success");
_data.put("ssid", ssid);
_return.put("error", _error);
_return.put("data", _data);

//LOGIN
if(!isLogin) {
	if(request.getRequestURI().indexOf("/app/login.jsp") == -1
		&& request.getRequestURI().indexOf("/app/logout.jsp") == -1
		&& request.getRequestURI().indexOf("/app/index.jsp") == -1
		&& request.getRequestURI().indexOf("/app/notice.jsp") == -1
		&& request.getRequestURI().indexOf("/app/notice_view.jsp") == -1
		&& request.getRequestURI().indexOf("/app/faq.jsp") == -1
		&& request.getRequestURI().indexOf("/app/faq_view.jsp") == -1
		&& request.getRequestURI().indexOf("/app/api.jsp") == -1
	) {
		_error.put("error_code", "2100");
		_error.put("error_msg", "로그아웃되었습니다. 다시 로그인하세요.");
		_return.put("error", _error);
		out.print(_return.toString());
		return;
	}
};

%>