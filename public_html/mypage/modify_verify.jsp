<%@ page contentType="text/html; charset=utf-8" %><%@ page import="java.util.regex.Pattern" %><%@ include file="init.jsp" %><%

if(!"direct".equals(mSession.s("login_method"))) {
	m.jsReplace("modify.jsp", "parent");
}

//폼체크
f.addElement("passwd", null, "hname:'비밀번호', required:'Y'");

//확인
if(m.isPost() && f.validate()) {
	
	String passwd = m.encrypt(f.get("passwd"), "SHA-256");
	if(!passwd.equals(uinfo.s("passwd"))) {
		m.jsAlert(_message.get("alert.member.reenter_password"));
		return;
	}

	//저장
	mSession.put("MODIFY_VERIFY", loginId);
	mSession.save();

	//이동
	m.jsReplace("modify.jsp", "parent");
	return;
}

//출력
p.setLayout(ch);
p.setBody("mypage.modify_verify");
p.setVar("form_script", f.getScript());
p.display();

%>