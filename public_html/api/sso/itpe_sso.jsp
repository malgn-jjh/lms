<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

//변수
String ekey = "GOfdg02sklrl08Z1"; //맑은소프트에서 발급하는 SSO키 abcdefg123456789
String siteUrl = "https://it.itpe.co.kr";  //정식도메인으로 변경해야 합니다.
String ssoUrl = siteUrl + "/member/slogin.jsp";
String mode = request.getParameter("mode");

String memberDir = !m.isMobile() ? "/member" : "/mobile";

if("logout".equals(mode)) {

	//내부 로그아웃 페이지로 이동시켜주세요.
	response.sendRedirect(memberDir + "/logout.jsp?returl=" + m.rs("returl"));
	return;
}

//로그인이 안되어 있을 경우 내부 로그인 페이지로 이동해주세요.
if(userId == 0) {

	//내부 로그인 페이지로 이동시켜주세요.
	//단 로그인후에는 반드시 다시 이 페이지로 돌아오도록 설정 부탁드립니다.
	response.sendRedirect(memberDir + "/login.jsp?returl=" + m.urlencode("/api/sso/itpe_sso.jsp?returl=" + m.rs("returl")));
	return;
}

String mobile = "";

UserDao user = new UserDao();
DataSet info = user.find("id = " + userId, "mobile");
if(info.next()) {
	mobile = SimpleAES.decrypt(info.s("mobile"));
}

//해쉬값(ek)는 사용자아이디 + 비밀키 + 날짜(yyyyMMdd)의 조합을 SHA256 으로 암호화 해주시기 바랍니다.
String today = m.time("yyyyMMdd");
String ek = m.sha256(loginId + ekey + today);
String returl = !"".equals(m.rs("returl")) ? SimpleAES.encrypt(m.rs("returl"), ekey) : "";

%>
<body onload="document.forms['form1'].submit();">
<form name="form1" method="POST" action="<%= ssoUrl %>">
<input type="hidden" name="encrypted" value="Y">
<input type="hidden" name="ek" value="<%= ek %>">
<input type="hidden" name="login_id" value="<%= SimpleAES.encrypt(loginId, ekey) %>">
<input type="hidden" name="user_nm" value="<%= SimpleAES.encrypt(userName, ekey) %>">
<input type="hidden" name="email" value="<%= SimpleAES.encrypt(userEmail, ekey) %>">
<input type="hidden" name="mobile" value="<%= SimpleAES.encrypt(mobile, ekey) %>">
<input type="hidden" name="returl" value="<%= returl %>">
</form>