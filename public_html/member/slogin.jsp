<%@ page import="javax.crypto.BadPaddingException" %>
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//폼입력
String ek = f.get("ek");

/*
if(siteId == 66) {
	String firstLog = "{f.data} " + f.data.toString() + "\n\n{m.reqMap} " + m.reqMap("").toString();
	m.log("slogin_first_" + siteId, firstLog);
}
*/

//제한
if("".equals(ek)) { out.print("기본키는 반드시 지정해야 합니다. 전산담당자에게 문의하세요."); return; }
//if(!m.isPost()) { out.print("METHOD IS NOT VALID"); return; }

//객체
UserDao user = new UserDao();
GroupDao group = new GroupDao();
UserDeptDao userDept = new UserDeptDao();
UserLoginDao userLogin = new UserLoginDao();

//변수
String lid, userNm, email, mobile, zipcode, addr, newAddr, addrDtl, deptId, deptCd, gender, birthday, returl, etc1, etc2, etc3; 
String now = m.time("yyyyMMddHHmmss");
String log = f.data.toString() + "\n";

if("Y".equals(f.get("encrypted"))) {
	try {
		String ssokey = siteinfo.s("sso_key");
		lid = SimpleAES.decrypt(f.get("login_id"), ssokey); 
		userNm = SimpleAES.decrypt(f.get("user_nm"), ssokey);
		email = !"".equals(f.get("email")) ? SimpleAES.decrypt(f.get("email"), ssokey) : "";
		mobile = !"".equals(f.get("mobile")) ? SimpleAES.decrypt(f.get("mobile"), ssokey) : "";
		zipcode = !"".equals(f.get("zipcode")) ? SimpleAES.decrypt(f.get("zipcode"), ssokey) : "";
		addr = !"".equals(f.get("addr")) ? SimpleAES.decrypt(f.get("addr").replaceAll("(\r\n|\r|\n|\n\r)", ""), ssokey) : "";
		newAddr = !"".equals(f.get("new_addr")) ? SimpleAES.decrypt(f.get("new_addr").replaceAll("(\r\n|\r|\n|\n\r)", ""), ssokey) : "";
		addrDtl = !"".equals(f.get("addr_dtl")) ? SimpleAES.decrypt(f.get("addr_dtl").replaceAll("(\r\n|\r|\n|\n\r)", ""), ssokey) : "";
		deptId = !"".equals(f.get("dept_id")) ? SimpleAES.decrypt(f.get("dept_id"), ssokey) : "";
		deptCd = !"".equals(f.get("dept_cd")) ? SimpleAES.decrypt(f.get("dept_cd"), ssokey) : "";
		gender = !"".equals(f.get("gender")) ? SimpleAES.decrypt(f.get("gender"), ssokey) : "";
		birthday = !"".equals(f.get("birthday")) ? SimpleAES.decrypt(f.get("birthday"), ssokey) : "";
		returl = !"".equals(f.get("returl")) ? SimpleAES.decrypt(f.get("returl").replaceAll("(\r\n|\r|\n|\n\r)", ""), ssokey) : "";
		etc1 = !"".equals(f.get("etc1")) ? SimpleAES.decrypt(f.get("etc1").replaceAll("(\r\n|\r|\n|\n\r)", ""), ssokey) : "";
		etc2 = !"".equals(f.get("etc2")) ? SimpleAES.decrypt(f.get("etc2").replaceAll("(\r\n|\r|\n|\n\r)", ""), ssokey) : "";
		etc3 = !"".equals(f.get("etc3")) ? SimpleAES.decrypt(f.get("etc3").replaceAll("(\r\n|\r|\n|\n\r)", ""), ssokey) : "";

		log += "{AES} ";
	} catch(BadPaddingException bpe) {
		m.errorLog("BadPaddingException : " + bpe.getMessage(), bpe);
		out.print("\n\n올바르지 않은 암호문이 입력돼 로그인이 불가능합니다. 전산담당자에게 문의하세요.");
		return;
	} catch(Exception e) {
		m.errorLog("Exception : " + e.getMessage(), e);
		out.print("\n\n올바르지 않은 암호문이 입력돼 로그인이 불가능합니다. 전산담당자에게 문의하세요.");
		return;
	}
} else {
	lid = f.get("login_id"); 
	userNm = f.get("user_nm");
	email = f.get("email");
	mobile = f.get("mobile");
	zipcode = f.get("zipcode");
	addr = f.get("addr");
	newAddr = f.get("new_addr");
	addrDtl = f.get("addr_dtl");
	deptId = f.get("dept_id");
	deptCd = f.get("dept_cd");
	gender = f.get("gender");
	birthday = f.get("birthday");
	returl = f.get("returl");
	etc1 = f.get("etc1");
	etc2 = f.get("etc2");
	etc3 = f.get("etc3");

	log += "{NORMAL} ";
}

log += "login_id:" + lid + " / user_nm:" + userNm + " / dept_id:" + deptId + " / dept_cd:" + deptCd + " / etc1:" + etc1;

//포맷팅
birthday = (8 != birthday.length() ? m.time("yyyyMMdd") : m.time("yyyyMMdd", birthday));

//제한
String eKey = m.encrypt(lid + siteinfo.s("sso_key") + m.time("yyyyMMdd"), "SHA-256");
if(!ek.equals(eKey)) { 
	m.log("slogin_error", f.data.toString() + " / login_id:" + lid + " / user_nm:" + userNm + " / sso_key:" + siteinfo.s("sso_key") + " / ek:" + ek + " / eKey:" + eKey);
	out.print("올바르지 않은 암호키가 입력돼 로그인이 불가능합니다. 전산담당자에게 문의하세요."); return;
}

int deptNo = (
	"".equals(deptCd)
	? m.parseInt(deptId)
	: userDept.getOneInt("SELECT id FROM " + userDept.table + " WHERE site_id = " + siteId + " AND CONCAT('|', dept_cd, '|') LIKE '%|" + deptCd + "|%' AND status = 1 ORDER BY sort ASC, id ASC")
);
if(birthday.length() != 8) birthday = "";
if(!"".equals(mobile)) mobile = SimpleAES.encrypt(mobile);
if(!"2".equals(gender)) gender = "1";

log += " / gender_conv:" + gender;

//정보
DataSet info = user.find("login_id = ? AND site_id = ?", new Object[] {lid, siteId});
if(info.next()) {
	if(info.i("status") != 1) { m.jsAlert(_message.get("alert.member.suspended_slogin")); return; }

	if(!"".equals(userNm)) user.item("user_nm", userNm);
	if(!"".equals(email)) user.item("email", email);
	if(!"".equals(mobile)) user.item("mobile", mobile);
	if(!"".equals(zipcode)) user.item("zipcode", zipcode);
	if(!"".equals(newAddr)) user.item("new_addr", newAddr);
	else if(!"".equals(addr)) user.item("new_addr", addr);
	if(!"".equals(addrDtl)) user.item("addr_dtl", addrDtl);
	if(deptNo > 0) user.item("dept_id", deptNo);
	if(!"".equals(gender)) user.item("gender", "2".equals(gender) ? "2" : "1");
	if(!"".equals(birthday)) user.item("birthday", birthday);
	if(!"".equals(etc1)) user.item("etc1", etc1);
	if(!"".equals(etc2)) user.item("etc2", etc2);
	if(!"".equals(etc3)) user.item("etc3", etc3);
	user.item("passwd_date", m.time("yyyyMMdd"));
	user.item("conn_date", now);

	if(!user.update("id = " + info.i("id") + "")) { m.jsAlert(_message.get("alert.member.error_login")); return; }

} else {

	if(0 > siteinfo.i("join_status")) {
		m.jsAlert(_message.get("alert.member.nodata_slogin"));
		m.jsReplace("/");
		return;
	}

	int newId = user.getSequence();
	user.item("id", newId);
	user.item("site_id", siteId);
	user.item("login_id", lid);
	user.item("user_nm", userNm);
	user.item("user_kind", "U");
	user.item("passwd", m.encrypt(lid, "SHA-256"));
	user.item("email", email);
	user.item("mobile", mobile);
	user.item("zipcode", zipcode);
	user.item("addr", addr);
	user.item("new_addr", newAddr);
	user.item("addr_dtl", addrDtl);
	user.item("dept_id", deptNo > 0 ? deptNo : siteinfo.i("dept_id"));
	user.item("gender", gender);
	user.item("birthday", birthday);
	user.item("etc1", etc1);
	user.item("etc2", etc2);
	user.item("etc3", etc3);
	user.item("privacy_yn", "N");
	user.item("passwd_date", m.time("yyyyMMdd"));
	user.item("conn_date", now);
	user.item("reg_date", now);
	user.item("status", ("0".equals(siteinfo.s("join_status")) ? "0" : "1"));
	if(!user.insert()) { m.jsAlert(_message.get("alert.member.error_login")); return; }

	info = user.find("id = " + newId + "");
	if(!info.next()) { out.print("USER IS NOT FOUND"); return; }
}

if("Y".equals(siteinfo.s("sso_privacy_yn")) && !"Y".equals(info.s("privacy_yn"))) {
	String pek = m.encrypt("PRIVACY_" + info.s("id") + "_AGREE_" + m.time("yyyyMMdd"));
	m.redirect("privacy_agree.jsp?id=" + info.s("id") + "&ek=" + pek + (!"".equals(returl) ? "&returl=" + m.urlencode(returl) : "")); return;
}

UserSession.setUserId(info.i("id"));
UserSession.setSession(mSession.s("id"));

log += " / id:" + info.s("id");

m.log("slogin_" + siteId, log);

String tmpGroups = group.getUserGroup(info);
auth.put("ID", info.s("id"));
auth.put("LOGINID", info.s("login_id"));
auth.put("KIND", info.s("user_kind"));
auth.put("NAME", info.s("user_nm"));
auth.put("EMAIL", info.s("email"));
auth.put("DEPT", info.i("dept_id"));
auth.put("SESSIONID", mSession.s("id"));
auth.put("GROUPS", tmpGroups);
auth.put("GROUPS_DISC", group.getMaxDiscRatio());
//auth.put("ALOGIN_YN", "N");
auth.setAuthInfo();

//로그
userLogin.item("id", userLogin.getSequence());
userLogin.item("site_id", siteId);
userLogin.item("user_id", info.i("id"));
userLogin.item("admin_yn", "N");
userLogin.item("login_type", "I");
userLogin.item("ip_addr", request.getRemoteAddr());
userLogin.item("agent", request.getHeader("user-agent"));
userLogin.item("device", userLogin.getDeviceType(request.getHeader("user-agent")));
userLogin.item("log_date", m.time("yyyyMMdd"));
userLogin.item("reg_date", m.time("yyyyMMddHHmmss"));
if(!userLogin.insert()) { }

if("".equals(returl)) {
	returl = !"".equals(m.getSession("RETURL")) ? m.getSession("RETURL") : "/";
}

//세션-SSL
mSession.put("login_method", "sso");
mSession.save();

m.redirect(returl);

%>