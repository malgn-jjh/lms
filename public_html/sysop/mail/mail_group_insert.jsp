<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//CHECKED-2014.06.27

//접근권한
if(!Menu.accessible(39, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//객체
MailDao mail = new MailDao();
MailUserDao mailUser = new MailUserDao();
MailTemplateDao mailTemplate = new MailTemplateDao();
UserDao user = new UserDao();
GroupDao group = new GroupDao();
GroupUserDao groupUser = new GroupUserDao();

//변수
if("".equals(siteinfo.s("site_email"))) siteinfo.put("site_email", "webmaster@" + siteinfo.s("domain"));
String sender = siteinfo.s("site_email");

//폼체크
f.addElement("subject", null, "hname:'제목', required:'Y'");
f.addElement("mail_type", "A", "hname:'메일유형', required:'Y'");
f.addElement("sender", sender, "hname:'발송자', required:'Y'");
f.addElement("group_id", null, "hname:'회원그룹', required:'Y'");

//등록
if(m.isPost() && f.validate()) {

	//정보
	DataSet ginfo = group.find("id = '" + f.getInt("group_id") + "' AND site_id = " + siteId + "");
	if(!ginfo.next()) { m.jsAlert("해당 그룹 정보가 없습니다."); return; }
	String depts = !"".equals(ginfo.s("depts")) ? m.replace(ginfo.s("depts").substring(1, ginfo.s("depts").length()-1), "|", ",") : "";

	//변수
	boolean isAd = "A".equals(f.get("mail_type", "A"));
	int newId = mail.getSequence();

	mail.item("id", newId);
	mail.item("site_id", siteId);
	mail.item("module", "group");
	mail.item("module_id", f.getInt("group_id"));

	mail.item("user_id", userId);
	mail.item("mail_type", f.get("mail_type", "A"));
	mail.item("sender", f.get("sender"));
	mail.item("subject", f.get("subject"));
	mail.item("content", f.get("content"));
	mail.item("resend_id", 0);
	mail.item("send_cnt", 0);
	mail.item("fail_cnt", 0);
	mail.item("reg_date", m.time("yyyyMMddHHmmss"));
	mail.item("status", 1);

	if(!mail.insert()) { m.jsAlert("등록하는 중 오류가 발생했습니다."); return; }

	DataSet users = user.query(
		"SELECT a.* "
		+ " FROM " + user.table + " a "
		+ " WHERE a.site_id = " + siteId + " AND (a.email IS NOT NULL OR a.email != '') "
		+ (!"".equals(depts)
				? " AND a.status = 1 AND ( a.dept_id IN (" + depts + ") OR "
				: " AND ( a.status = 1 AND ")
		+ " EXISTS ( "
			+ " SELECT 1 FROM " + groupUser.table + " "
			+ " WHERE group_id = " + f.get("group_id") + " AND add_type = 'A' "
			+ " AND user_id = a.id "
		+ " ) ) AND NOT EXISTS ( "
			+ " SELECT 1 FROM " + groupUser.table + " "
			+ " WHERE group_id = " + f.get("group_id") + " AND add_type = 'D' "
			+ " AND user_id = a.id "
		+ " ) "
		+ (isAd ? " AND a.email_yn = 'Y'" : "")
	);

	//템플릿
	p.setRoot(siteinfo.s("doc_root") + "/html");
	p.setVar("SITE_INFO", siteinfo);
	p.setVar("subject", f.get("subject"));
	p.setVar("MBODY", f.get("content"));

	//메일 발송
	m.mailFrom = f.get("sender");
	String subject = "[" + siteinfo.s("site_nm") + "] " + f.get("subject");
	String today = m.time("yyyy년 MM월 dd일");

	int sendCnt = 0;
	int failCnt = 0;
	while(users.next()) {
		int newMailUserId = mailUser.getSequence();

		mailUser.item("id", newMailUserId);
		mailUser.item("site_id", siteId);
		mailUser.item("mail_id", newId);
		mailUser.item("email", users.s("email"));
		mailUser.item("user_id", users.s("id"));
		mailUser.item("user_nm", users.s("user_nm"));
		if(mail.isMail(users.s("email"))) {
			mailUser.item("send_yn", "Y");
			if(mailUser.insert()) {
				if(isSend) {
					p.setVar("agree_info", 
						isAd
						? _message.get("mail.agree_info", new String[] {
							"agree_date_conv=>" + today
							, "domain=>" + siteinfo.s("domain")
							, "ek=>" + m.encrypt(newMailUserId + "_" + siteId + "_EMAIL_UNSUBSCRIBE")
							, "key=>" + newMailUserId
						})
						: ""
					);
					m.mail(users.s("email"), subject, p.fetchRoot("mail/template.html"));
				}
				sendCnt++;
			}
		} else {
			mailUser.item("send_yn", "N");
			if(mailUser.insert()) { failCnt++; }
		}
	}

	//발송건수
	mail.execute("UPDATE " + mail.table + " SET send_cnt = " + sendCnt + ", fail_cnt = " + failCnt + " WHERE id = " + newId + "");

	m.jsReplace("mail_list.jsp?" + m.qs("id"), "parent");
	return;
}

//목록
DataSet groups = group.find("status = 1 AND site_id = " + siteId + "", "*", "group_nm ASC");

//출력
p.setBody("mail.mail_group_insert");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

//p.setLoop("templates", m.arr2loop(mail.templates));
p.setLoop("templates", mailTemplate.getList(siteId));
p.setLoop("types", m.arr2loop(mail.types));
p.setVar("t_link", "insert");
p.setLoop("groups", groups);
p.setVar("mail_type", "A");
p.display();

%>