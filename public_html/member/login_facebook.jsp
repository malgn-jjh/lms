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
} catch(Exception e) {
	oklist.addRow();
}
if(!oklist.next()) { m.jsAlert(_message.get("alert.member.nodata_oauth")); m.js("parent.CloseLayer();"); return; }

//객체
OAuthClient oauth = new OAuthClient(request, session);
//oauth.setDebug(out);
oauth.setClient("facebook", oklist.s("facebook_id"), oklist.s("facebook_secret"));

//제한-사용자취소및오류
if("access_denied".equals(error)) { m.js("window.close();"); return; }
else if(!"".equals(error)) { m.jsErrClose(error + " - " + errorDescription); return; }

//처리
if(!"".equals(code) && !"".equals(state)) {

	//변수
	HashMap oauthMap = oauth.getProfile(m.rs("code"));
	if(oauthMap == null) { m.jsAlert(_message.get("alert.member.nodata_login")); m.js("window.close();"); return; }
	
	//필수정보미비
	if(!oauthMap.containsKey("name") || !oauthMap.containsKey("email")) {
		p.setLayout("blank");
		p.setBody("member.login_reauth");
		p.setVar("facebook_block", true);
		p.setVar("reauth_url", oauth.getAuthUrl("facebook") + "&display=popup&auth_type=rerequest");
		p.display();
		return;
	}
	
	//정보
	DataSet info = user.find("login_id = 'facebook_" + oauthMap.get("id").toString() + "' AND site_id = " + siteId + "");
	if(info.next()) {
		//세션
		mSession.put("login_method", "oauth-facebook");
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
	//m.p(oauthMap);

	//세션
	mSession.put("join_method", "oauth");
	mSession.put("join_vendor", "facebook");
	mSession.put("join_vendor_nm", "페이스북");
	mSession.put("join_data", Json.encode(oauthMap));
	mSession.save();

	//이동
	m.jsReplace("../member/agreement.jsp?mode=oauth", "opener");
	m.js("window.close();");

} else {
	m.redirect(oauth.getAuthUrl("facebook") + "&display=popup");
}

%>