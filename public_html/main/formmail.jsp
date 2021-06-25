<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

String ch = m.rs("ch", "board");

//정보-사이트설정
DataSet siteconfig = SiteConfig.getArr(new String[] {"ktalk_"});

//객체
FormmailDao formmail = new FormmailDao();
FileDao file = new FileDao();
SmsDao sms = new SmsDao();
SmsTemplateDao smsTemplate = new SmsTemplateDao(siteId);
MailDao mail = new MailDao();
MailTemplateDao mailTemplate = new MailTemplateDao();
KtalkDao ktalk = new KtalkDao(siteId);
if("Y".equals(siteconfig.s("ktalk_yn"))) ktalk.setAccount(siteinfo.s("sms_id"), siteinfo.s("sms_pw"), siteconfig.s("ktalk_sender_key"));
KtalkTemplateDao ktalkTemplate = new KtalkTemplateDao(siteId);
Json result = new Json(out);

//폼입력
boolean jsonBlock = "json".equals(m.rs("mode", "submit"));

//제한
if("".equals(siteinfo.s("receive_email"))) {
	if(!jsonBlock) {
		m.jsError(_message.get("alert.formmail.nosetting"));
	} else {
		result.put("rst_code", "9999");
		result.put("rst_message", _message.get("alert.formmail.nosetting"));
		result.print();
	}
	return;
}

//폼체크
f.addElement("category_nm", null, "HNAME:'카테고리명'");
f.addElement("user_nm", null, "HNAME:'담당자', required:'Y'");
f.addElement("mobile1", null, "HNAME:'연락처', required:'Y', option:'number', minbyte:'3', maxbyte:'3'");
f.addElement("mobile2", null, "HNAME:'연락처', required:'Y', option:'number', minbyte:'3', maxbyte:'4'");
f.addElement("mobile3", null, "HNAME:'연락처', required:'Y', option:'number', minbyte:'4', maxbyte:'4'");
f.addElement("email1", null, "HNAME:'이메일', option:'email', glue:'email2', delim:'@'");
f.addElement("email2", null, "HNAME:'이메일'");
f.addElement("content", null, "HNAME:'문의내용'");

//등록
if(m.isPost() && f.validate()) {
	
	//변수
	String resultCode = "0000";
	String resultMsg = _message.get("alert.formmail.inserted");
	boolean isError = false;

	//제한
	if(1 > m.replace(m.stripTags(f.get("content")), "&nbsp;", " ").trim().length()) {
		resultCode = "1001";
		resultMsg = _message.get("alert.common.enter_contents");
		isError = true;
	}

	String today = m.time("yyyyMMddHHmmss");
	String email = f.glue("@", "email1,email2");
	String mobile = f.glue("-", "mobile1,mobile2,mobile3");
	String mobileEncrypt = "";

	//제한-휴대전화번호
	if(!isError && !sms.isMobile(mobile)) {
		resultCode = "1002";
		resultMsg = _message.get("alert.member.unvalid_contact");
		isError = true;
	}

	try {
		mobileEncrypt = SimpleAES.encrypt(mobile);
	} catch(Exception e) {
		resultCode = "1003";
		resultMsg = _message.get("alert.common.error_insert");
		isError = true;
	}

	//제한-이미지URI및용량
	String content = f.get("content");
	int bytes = content.replace("\r\n", "\n").getBytes("UTF-8").length;
	if(!isError && -1 < content.indexOf("<img") && -1 < content.indexOf("data:image/") && -1 < content.indexOf("base64")) {
		resultCode = "1004";
		resultMsg = _message.get("alert.board.attach_image");
		isError = true;
	}
	if(!isError && 60000 < bytes) {
		resultCode = "1005";
		resultMsg = _message.get("alert.board.over_capacity", new String[] {"maximum=>60000", "bytes=>" + bytes});
		isError = true;
	}

	//등록
	int newId = -99;
	if(!isError) {
		newId = formmail.getSequence();
		formmail.item("id", newId);
		formmail.item("site_id", siteId);
		formmail.item("user_nm", f.get("user_nm"));
		formmail.item("category_nm", f.get("category_nm"));
		formmail.item("mobile", mobileEncrypt);
		formmail.item("email", email);
		formmail.item("content", ("mobile".equals(f.get("device")) ? m.nl2br(content) : content));
		formmail.item("ip_addr", request.getRemoteAddr());
		formmail.item("reg_date", today);
		formmail.item("status", 1);
		if(!formmail.insert()) {
			resultCode = "2001";
			resultMsg = _message.get("alert.common.error_insert");
			isError = true;
		}
	}

	//발송
	if(!isError) {
		//갱신-임시파일
		if(0 != f.getInt("temp_id")) file.updateTempFile(f.getInt("temp_id"), newId, "formmail");

		p.setVar("user_nm", f.get("user_nm"));
		p.setVar("mobile", mobile);
		p.setVar("email", email);
		p.setVar("category_nm", !"".equals(f.get("category_nm")) ? f.get("category_nm") : "이메일문의");
		p.setVar("content", f.get("content"));
		if("Y".equals(siteconfig.s("ktalk_yn"))) {
			ktalkTemplate.sendKtalk(siteinfo, SimpleAES.encrypt(siteinfo.s("receive_phone")), "formmail", p);
		} else {
			smsTemplate.sendSms(siteinfo, SimpleAES.encrypt(siteinfo.s("receive_phone")), "formmail", p);
		}
		mail.send(siteinfo, siteinfo.s("receive_email"), "formmail", p);
	}

	//출력
	if(!jsonBlock) {
		m.jsAlert(resultMsg);
		if(!isError) m.js("parent.location.href = parent.location.href");
	} else {
		response.setContentType("application/json");
		result.put("rst_code", resultCode);
		result.put("rst_message", resultMsg);
		result.print();
	}
	return;

} else if(m.isPost() && !f.validate()) {
	if(!jsonBlock) {
		m.jsAlert(_message.get("alert.common.enter_contents"));
	} else {
		response.setContentType("application/json");
		result.put("rst_code", "1001");
		result.put("rst_message", _message.get("alert.common.enter_contents"));
		result.print();
	}
	return;
}

int tempId = m.getRandInt(-2000000, 1990000);

//출력
p.setLayout(ch);
p.setBody("main.formmail");
p.setVar("p_title", "이메일문의");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setVar("temp_id", tempId);
p.setVar("allow_ext", "jpg|jpeg|gif|png|swf|mp4|flv|mov|qt|mpeg|wmv|wma|asf|mp3|avi|wmp|rmp|ra|pdf|hwp|txt|doc|docx|xls|xlsx|ppt|pptx|zip|7z|rar|alz|egg");
p.display();

%>