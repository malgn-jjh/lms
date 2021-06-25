<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../init.jsp" %><%

//폼입력
String id = m.reqSql("id");
String passwd = m.reqSql("passwd");
String accessToken = m.rs("access_token");
String ek = m.rs("ek");
String returl = m.rs("returl", "/sysop/index.jsp");
if((-1 < returl.indexOf("http://") || -1 < returl.indexOf("https://")) && 0 > returl.indexOf(siteinfo.s("domain"))) returl = "/sysop/index.jsp";

//폼체크
f.addElement("id", null, "hname:'아이디', required:'Y'");
f.addElement("passwd", null, "hname:'비밀번호', required:'Y'");

//SSL인증처리
String sslDomain = request.getServerName().indexOf(".malgn.co.kr") > 0 ? "ssl.malgn.co.kr" : (request.getServerName().indexOf("demo.malgnlms.com") > 0 ? "demo.malgnlms.com" : "ssl.malgnlms.com");
boolean isSSL = "https".equals(request.getScheme()) && sslDomain.equals(request.getServerName()) && !"".equals(f.get("domain"));
if(siteinfo.b("ssl_yn")) {
	sslDomain = siteinfo.s("domain");
	isSSL = false;
}
if(isSSL) {
	siteinfo = Site.getSiteInfo(f.get("domain"), "sysop");
	if("".equals(siteinfo.s("doc_root"))) { m.jsError("사이트 정보가 없습니다."); return; }
	siteId = siteinfo.i("id");
}
boolean isToken = !"".equals(accessToken) && ek.equals(m.encrypt(accessToken + sslDomain + m.time("yyyyMMdd")));

if((m.isPost() && f.validate()) || isToken) {

	UserDao user = new UserDao();
	UserSiteDao userSite = new UserSiteDao(siteId);
	UserLoginDao userLogin = new UserLoginDao();
	GroupDao group = new GroupDao();
	CourseManagerDao courseManager = new CourseManagerDao();

	DataSet info;
	if(isToken) {
		info = user.find("access_token = ? AND site_id IN (0, " + siteId + ") AND user_kind IN ('C', 'D', 'A', 'S') AND status = 1", new Object[] {accessToken});
	} else {
		passwd = m.encrypt(passwd, "SHA-256");
		info = user.find("site_id IN (0, " + siteId + ") AND login_id = ? AND passwd = ? AND user_kind IN ('C', 'D', 'A', 'S') AND status = 1", new Object[] {id, passwd});
	}

	if(!info.next()) { m.jsAlert("아이디 또는 비밀번호가 일치하지 않습니다."); return; }

	//마스터아이디
	if(0 == info.i("site_id")) {
		if(!userSite.verifyUser(info.i("id"))) { m.jsAlert("아이디 또는 비밀번호가 일치하지 않습니다."); return; }
	}

	//SSL로그인확인
	if(isSSL) {
		accessToken = m.md5(m.getUniqId());
		ek = m.encrypt(accessToken + sslDomain + m.time("yyyyMMdd"));
		user.item("access_token", accessToken);
		user.update("id = " + info.i("id") + " AND site_id = " + info.i("site_id"));
		m.jsReplace("http://" + f.get("domain") + "/sysop/main/login.jsp?access_token=" + accessToken + "&ek=" + ek);
		return;
	}

	//갱신
	user.item("conn_date", m.time("yyyyMMddHHmmss"));
	user.item("access_token", "");
	if(!user.update("id = " + info.i("id") + " AND site_id = " + info.i("site_id"))) {
		m.jsAlert("로그인하는 중 오류가 발생했습니다.");
		m.js("parent.resetPassword();");
		return;
	}

	//세션
	UserSession.setUserId(info.i("id"));
	UserSession.setSession(mSession.s("id"));
	
	//인증
	String tmpGroups = group.getUserGroup(info);
	auth.put("ID", info.i("id"));
	auth.put("LOGINID", info.s("login_id"));
	auth.put("KIND", info.s("user_kind"));
	auth.put("NAME", info.s("user_nm"));
	auth.put("DEPT", info.i("dept_id"));
	auth.put("GROUPS", tmpGroups);
	auth.put("MANAGE_COURSES", courseManager.getManageCourses(info.i("id")));
	auth.put("SESSIONID", mSession.s("id"));
	auth.put("IS_USER_MASTER", 0 == info.i("site_id") ? "Y" : "");
	auth.setAuthInfo();

	//로그
	userLogin.item("id", userLogin.getSequence());
	userLogin.item("site_id", siteId);
	userLogin.item("user_id", info.i("id"));
	userLogin.item("admin_yn", "Y");
	userLogin.item("login_type", "I");
	userLogin.item("ip_addr", request.getRemoteAddr());
	userLogin.item("agent", request.getHeader("user-agent"));
	userLogin.item("device", userLogin.getDeviceType(request.getHeader("user-agent")));
	userLogin.item("log_date", m.time("yyyyMMdd"));
	userLogin.item("reg_date", m.time("yyyyMMddHHmmss"));
	if(!userLogin.insert()) {}

	//이동
	m.jsReplace(returl, "parent");
	return;
}

m.setCookie("PREPAGE", "", 0);
m.setCookie("csd", "");
m.setCookie("cod", "");

//출력
p.setLayout("blank");
p.setBody("main.login");
p.setVar("form_script", f.getScript());
p.setVar("returl", returl);
p.setVar("domain", request.getServerName());
p.setVar("SSL_DOMAIN", sslDomain);
p.display();
%>