<%@ page import="java.util.*,java.io.*,dao.*,malgnsoft.db.*,malgnsoft.util.*" %><%

//request.setCharacterEncoding("utf-8");

final String BUILDVERSION = "21.22.01";

String docRoot = Config.getDocRoot();
String jndi = Config.getJndi();

Malgn m = new Malgn(request, response, out);

Form f = new Form("form1");
try { f.setRequest(request); }
catch(Exception ex) { out.print("Overflow file size. - " + ex.getMessage()); return; }

SiteDao Site = new SiteDao(); //Site.clear();
DataSet siteinfo = Site.getSiteInfo(request.getServerName());
SiteConfigDao SiteConfig = new SiteConfigDao(siteinfo.i("id"));
if(1 != siteinfo.i("status") || "".equals(siteinfo.s("doc_root"))) {
	m.jsReplace("about:blank", "top");
	return;
}

//Hashtable<String, String> siteconfig = SiteConfig.getSiteConfig(siteinfo.s("id"));

String webUrl = request.getScheme() + "://" + request.getServerName();
int port = request.getServerPort();
if(port != 80 && port != 443) webUrl += ":" + port;
String dataDir = siteinfo.s("doc_root") + "/data";
String tplRoot = siteinfo.s("doc_root") + "/html";
f.dataDir = dataDir;
m.dataDir = dataDir;
//m.dataUrl = "https://cdn.malgnlms.com/cdndata/" + siteinfo.s("ftp_id");
m.dataUrl = Config.getDataUrl() + (!"/data".equals(Config.getDataUrl()) ? siteinfo.s("ftp_id") : "");

boolean isDevServer = -1 < request.getServerName().indexOf("lms.malgn.co.kr");
if(!"".equals(siteinfo.s("logo"))) siteinfo.put("logo_url", m.getUploadUrl(siteinfo.s("logo")));
else siteinfo.put("logo_url", "/common/images/default/malgn_logo.jpg");

//IP차단
String userIp = request.getRemoteAddr();
if(!"".equals(siteinfo.s("allow_ip_user")) && !Site.checkIP(userIp, siteinfo.s("allow_ip_user"))) {
	m.redirect("/main/guide.jsp");
	return;
}

Page p = new Page(tplRoot);
p.setRequest(request);
p.setPageContext(pageContext);
p.setWriter(out);
p.setBaseRoot("/home/lms/public_html/html");

//언어
String sysLocale = "".equals(siteinfo.s("locale")) ? "default" : siteinfo.s("locale");
Message _message = new Message(sysLocale);
_message.reloadAll();
m.setMessage(_message);
//p.setMessage(_message);

int siteId = siteinfo.i("id");
int userId = 0;
String loginId = "";
String loginMethod = "";
String userName = "";
String userEmail = "";
String userKind = "";
int userDeptId = 0;
String userGroups = "";
int userGroupDisc = 0;
//String aloginYn = "";
String userSessionId = "";
boolean userB2BBlock = false;
String userB2BName = "";
String userB2BFile = "";
String sysToday = m.time("yyyyMMdd");
String sysNow = m.time("yyyyMMddHHmmss");
boolean isRespWeb = (5 <= siteinfo.i("skin_cd"));
boolean isGoMobile = !isRespWeb && m.isMobile();

SessionDao mSession = new SessionDao(request, response);

Auth auth = new Auth(request, response);
auth.loginURL = "/member/login.jsp";
auth.keyName = "MLMS14" + siteId + "7";
if(0 < siteinfo.i("session_hour")) auth.setValidTime(siteinfo.i("session_hour") * 3600);
if(auth.isValid()) {
	userId = auth.getInt("ID");
	loginId = auth.getString("LOGINID");
	loginMethod = auth.getString("LOGINMETHOD");
	userName = auth.getString("NAME");
	userEmail = auth.getString("EMAIL");
	userKind = auth.getString("KIND");
	userDeptId = auth.getInt("DEPT");
	userGroups = auth.getString("GROUPS");
	userGroupDisc = !"null".equals(auth.getString("GROUPS_DISC")) ? m.parseInt(auth.getString("GROUPS_DISC")) : 0;
	//aloginYn = auth.getString("ALOGIN_YN");
	userSessionId = auth.getString("SESSIONID");
	userB2BName = auth.getString("B2BNAME");
	userB2BFile = auth.getString("B2BFILE");

	if(userGroups != null) {
		if(-1 < userGroups.indexOf(",")) for(String userGroupId : m.split(",", userGroups)) p.setVar("SYS_USERGROUP_" + userGroupId, true);
		else p.setVar("SYS_USERGROUP_" + userGroups, true);
	}

	mSession.put("id", userSessionId);
	mSession.save();

	p.setVar("login_block", true);
} else {
	p.setVar("login_block", false);

	if(siteinfo.b("close_yn")) {
		boolean isNeedLogin = true;
		String[] exceptPages = m.split("|", siteinfo.s("close_except"));

		if(-1 < request.getRequestURI().indexOf("/member/login.jsp")
			|| -1 < request.getRequestURI().indexOf("/member/find.jsp")
			|| -1 < request.getRequestURI().indexOf("/member/alogin.jsp")
			|| -1 < request.getRequestURI().indexOf("/member/slogin.jsp")
			|| -1 < request.getRequestURI().indexOf("/member/slogin_input.jsp")
			|| -1 < request.getRequestURI().indexOf("/member/sysop_slogin.jsp")
			|| -1 < request.getRequestURI().indexOf("/main/site_cache.jsp")
			|| -1 < request.getRequestURI().indexOf("/mobile/login.jsp")
			|| -1 < request.getRequestURI().indexOf("/mypage/certificate.jsp")
			|| -1 < request.getRequestURI().indexOf("/mypage/certificate_course.jsp")
			|| -1 < request.getRequestURI().indexOf("/kollus/check_api.jsp")
			|| -1 < request.getRequestURI().indexOf("/common/")
			|| -1 < request.getRequestURI().indexOf("/api/auto_send.jsp")
		) {
			isNeedLogin = false;
		} else if(!"".equals(siteinfo.s("close_except"))) {
			for(int i = 0; i < exceptPages.length; i++) {
				if(-1 < request.getRequestURI().indexOf(exceptPages[i])) { isNeedLogin = false; continue; }
			}
		}

		if(isNeedLogin) {
			m.redirect(!isGoMobile ? auth.loginURL : "/mobile/login.jsp");
			return;
		}
	}
}

userB2BBlock = !"".equals(userB2BName) && null != userB2BName;
p.setVar("SYS_HTTPHOST", request.getServerName());
p.setVar("SYS_LOGINID", loginId);
p.setVar("SYS_USERNAME", userName);
p.setVar("SYS_USEREMAIL", userEmail);
p.setVar("SYS_USERKIND", userKind);
p.setVar("SYS_DEPTID", userDeptId);
p.setVar("SYS_GROUP_DISC", userGroupDisc);
p.setVar("SYS_B2BBLOCK", userB2BBlock);
p.setVar("SYS_B2BNAME", userB2BName);
p.setVar("SYS_B2BFILE", userB2BFile);
p.setVar("SYS_PAGE_URL", request.getRequestURL() + (!"".equals(m.qs()) ? "?" + m.qs() : ""));
p.setVar("SYS_TITLE", siteinfo.s("site_nm"));
p.setVar("webUrl", webUrl);
p.setVar("SITE_INFO", siteinfo);
//p.setVar("SITE_CONFIG", siteconfig);
p.setVar("CURR_DATE", m.time("yyyyMMdd"));
p.setVar("SYS_EK", m.encrypt(loginId + siteinfo.s("sso_key") + m.time("yyyyMMdd"), "SHA-256"));
p.setVar("IS_RESP_WEB", isRespWeb);
p.setVar("IS_MOBILE", m.isMobile());
p.setVar("IS_GO_MOBILE", isGoMobile);
p.setVar("IS_DEV_SERVER", isDevServer);
p.setVar("SYS_LOCALE", sysLocale);
p.setVar("SYS_TODAY", sysToday);
p.setVar("SYS_NOW", sysNow);
p.setVar("SYS_COMMON_CDN", !isDevServer ? "//cdn.malgnlms.com" : "");

for(int IndexSkin = 1; IndexSkin < 5; IndexSkin++) {
	p.setVar("SKIN_LT_" + IndexSkin, siteinfo.i("skin_cd") < IndexSkin);
	p.setVar("SKIN_LTE_" + IndexSkin, siteinfo.i("skin_cd") <= IndexSkin);
	p.setVar("SKIN_GT_" + IndexSkin, siteinfo.i("skin_cd") > IndexSkin);
	p.setVar("SKIN_GTE_" + IndexSkin, siteinfo.i("skin_cd") >= IndexSkin);
}

MenuDao Menu = new MenuDao(p, sysLocale);

UserSessionDao UserSession = new UserSessionDao();
UserSession.setSiteId(siteId);
if(userId != 0 && !"SYSLOGIN".equals(userSessionId) && !siteinfo.b("duplication_yn") && !UserSession.isValid(userSessionId, userId)) {
	if(request.getRequestURI().indexOf("/member/logout.jsp") == -1 && request.getRequestURI().indexOf("/mobile/logout.jsp") == -1) {
		m.jsAlert(_message.get("alert.common.logout_session"));
		if(request.getRequestURI().indexOf("/mobile/") != -1) m.jsReplace("/mobile/logout.jsp?mode=session");
		else m.jsReplace("/member/logout.jsp?mode=session");
		return;
	}
}

%>