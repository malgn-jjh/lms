<%@ page import="com.oracle.javafx.jmx.json.JSONException" %>
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
String code = m.rs("code");
String state = m.rs("state");

//폼입력
String error = m.rs("error");
String errorDescription = m.rs("error_description");
String returl = m.rs("returl");

//객체
UserDao user = new UserDao();

//정보
DataSet oklist = new DataSet();
try {
	oklist = Json.decode(siteinfo.s("oauth_key"));
}
catch(JSONException jsone) {
	m.errorLog("JSONException : " + jsone.getMessage(), jsone);
	oklist.addRow();
}
catch(Exception e) {
	m.errorLog("Exception : " + e.getMessage(), e);
	oklist.addRow();
}
if(!oklist.next()) { m.jsAlert(_message.get("alert.member.nodata_oauth")); m.js("parent.CloseLayer();"); return; }

//객체
OAuthClient oauth = new OAuthClient(request, session);
//oauth.setDebug(out);
oauth.setClient("line", oklist.s("line_id"), oklist.s("line_secret"));

//제한-사용자취소및오류
if("access_denied".equals(error)) { m.js("window.close();"); return; }
else if(!"".equals(error)) { m.jsErrClose(error + " - " + errorDescription); return; }

//처리
if(!"".equals(code) && !"".equals(state)) {

	//변수
	HashMap oauthMap = oauth.getProfile(m.rs("code"));
	if(oauthMap == null) { m.jsAlert(_message.get("alert.member.nodata_login")); m.js("window.close();"); return; }
	oauthMap.put("id", oauthMap.get("userId").toString());
	oauthMap.put("name", oauthMap.get("displayName").toString());
	
	//정보
	DataSet info = user.find("login_id = 'line_" + oauthMap.get("id").toString() + "' AND site_id = " + siteId + "");
	if(info.next()) {
		//세션
		mSession.put("login_method", "oauth-line");
		mSession.save();

		//로그인
		String accessToken = m.md5(m.getUniqId());
		String ek = m.encrypt(accessToken + sslDomain + m.time("yyyyMMdd"));
		user.item("access_token", accessToken);
		if(!user.update("id = " + info.i("id") + " AND site_id = " + siteId)) {
			m.jsErrClose(_message.get("alert.member.error_find"));
			return;
		}
		m.jsReplace("../" + (!m.isMobile() ? "member" : "mobile") + "/login.jsp?returl=" + returl + "&access_token=" + accessToken + "&ek=" + ek, "opener");
		m.js("window.close();");
		return;
	}

	//세션
	mSession.put("join_method", "oauth");
	mSession.put("join_vendor", "line");
	mSession.put("join_vendor_nm", "LINE");
	mSession.put("join_data", Json.encode(oauthMap));
	mSession.save();

	//이동
	m.jsReplace("../member/agreement.jsp?mode=oauth", "opener");
	m.js("window.close();");

} else {
	m.redirect(oauth.getAuthUrl("line"));
}

%>