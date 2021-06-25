<%@ page import="java.util.*,java.io.*,dao.*,malgnsoft.db.*,malgnsoft.util.*,org.json.*" %><%

//request.setCharacterEncoding("utf-8");

String docRoot = Config.getDocRoot();
String jndi = Config.getJndi();

Malgn m = new Malgn(request, response, out);

Form f = new Form("form1");
try { f.setRequest(request); }
catch(Exception ex) { out.print("Overflow file size. - " + ex.getMessage()); return; }

SiteDao Site = new SiteDao(); //Site.clear();
DataSet siteinfo = Site.getSiteInfo(request.getServerName());
SiteConfigDao SiteConfig = new SiteConfigDao(siteinfo.i("id"));
if("".equals(siteinfo.s("doc_root"))) {
	m.jsReplace("about:blank", "top"); 
	return;
}

String webUrl = request.getScheme() + "://" + request.getServerName();
int port = request.getServerPort();
if(port != 80) webUrl += ":" + port;
String dataDir = siteinfo.s("doc_root") + "/data";
String tplRoot = siteinfo.s("doc_root") + "/html";
f.dataDir = dataDir;
m.dataDir = dataDir;

Page p = new Page(tplRoot);
p.setRequest(request);
p.setPageContext(pageContext);
p.setWriter(out);
p.setBaseRoot("/home/lms/public_html/html");

//���
String sysLocale = "".equals(siteinfo.s("locale")) ? "default" : siteinfo.s("locale");
Message _message = new Message(sysLocale);
m.setMessage(_message);
//p.setMessage(_message);

int siteId = siteinfo.i("id");

SessionDao mSession = new SessionDao(request, response);
mSession.put("id", session.getId());

Auth auth = new Auth(request, response);
auth.loginURL = "/member/login.jsp";
auth.keyName = "MLMS14" + siteId + "7";

//JSON
JSONObject _ret = new JSONObject();
_ret.put("error", "");

//����
boolean error = false;
String token = m.rs("token"); //.toLowerCase();
String format = "json";

//��ü
ApiLogDao apiLog = new ApiLogDao(format, request, response);

//���
//apiLog.d(out);
if(!apiLog.insertLog(siteId, m.qs())) {
	_ret.put("error", "cannot insert db");
	apiLog.printList(out, _ret, "euc-kr");
	return;
}

//����-����Ʈ
if(114 != siteId && 1 != siteId) {
	_ret.put("error", "Invalid site");
	apiLog.printList(out, _ret, "euc-kr");
	return;
}

//POST����
/*
if(!error && !m.isPost()) {
	_ret.put("error", "Invalid method");
	error = true;
}
*/

//��뷮
if(!error && siteinfo.i("api_limit")
	<= apiLog.getOneInt(
		"SELECT COUNT(*) FROM " + apiLog.table + " WHERE site_id = " + siteId
		+ " AND reg_date >= '" + m.time("yyyyMM01000000") + "' AND reg_date <= '" + m.time("yyyyMMddHHmmss") + "' AND return_code = '000'")
	) {
	_ret.put("error", "api limit");
	error = true;
}

%>