<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//객체
UserOutDao userOut = new UserOutDao();
UserSleepDao userSleep = new UserSleepDao();
//UserDeptDao userDept = new UserDeptDao();
TutorDao tutor = new TutorDao();
ActionLogDao actionLog = new ActionLogDao();
FileDao file = new FileDao();

//정보
DataSet info = user.query(
	" SELECT a.*, t.tutor_nm, t.name_en, t.attached, t.tutor_file, t.ability, t.university, t.major, t.introduce, t.bank_nm, t.bank_account "
	+ " FROM " + user.table + " a "
	+ " LEFT JOIN " + tutor.table + " t ON a.id = t.user_id AND t.status != -1 "
	+ " WHERE a.id = " + uid + " AND a.site_id = " + siteId + " AND a.status != -1"
);
if(!info.next()) { m.jsError("해당 회원정보가 없습니다."); return; }
info.put("reg_date_conv", m.time("yyyy.MM.dd HH:mm", info.s("reg_date")));
info.put("sleep_date_conv", m.time("yyyy.MM.dd HH:mm", info.s("sleep_date")));
info.put("conn_date_conv", m.time("yyyy.MM.dd HH:mm", info.s("conn_date")));
info.put("status_conv", m.getItem(info.s("status"), user.statusList));

//파일삭제
if("fdel".equals(m.rs("mode"))) {
	if(!"".equals(info.s("tutor_file"))) {
		tutor.item("tutor_file", "");
		if(!tutor.update("user_id = " + uid + "")) { }
		m.delFileRoot(m.getUploadPath(info.s("tutor_file")));
	}
	return;
}

//변수
boolean superModifyBlock = "S".equals(userKind) || (!"S".equals(info.s("user_kind")) && userId != info.i("id"));
boolean sleepBlock = (31 == info.i("status"));
boolean outBlock = adminBlock && info.i("id") != userId;
DataSet sinfo = new DataSet();

if(sleepBlock) {
	//휴면정보
	sinfo = userSleep.find("id = " + uid + " AND site_id = " + siteId + " AND status != -1");
	if(!sinfo.next()) { m.jsErrClose("해당 휴면회원정보가 없습니다."); return; }
	sinfo.put("dept_nm", userDept.getOne("SELECT dept_nm FROM " + userDept.table + " WHERE id = " + sinfo.s("dept_id")));
	sinfo.put("gender_conv", m.getItem(sinfo.s("gender"), user.genders));
	sinfo.put("birthday_conv", m.time("yyyy.MM.dd", sinfo.s("birthday")));
	if(!"".equals(sinfo.s("mobile"))) try { sinfo.put("mobile_conv", SimpleAES.decrypt(sinfo.s("mobile"))); } catch(Exception e) { }

} else {
	//폼체크
	f.addElement("user_nm", info.s("user_nm"), "hname:'회원명', required:'Y'");
	if(superBlock && superModifyBlock) f.addElement("user_kind", info.s("user_kind"), "hname:'회원구분'");
	if(adminBlock) f.addElement("dept_id", info.s("dept_id"), "hname:'소속', required:'Y'");
	f.addElement("tutor_yn", info.s("tutor_yn"), "hname:'강사여부'");
	f.addElement("passwd", null, "hname:'비밀번호', match:'passwd2'");
	f.addElement("passwd2", null, "hname:'비밀번호'");
	f.addElement("passwd_date", m.time("yyyy-MM-dd", info.s("passwd_date")), "hname:'비밀번호 변경안내일'");
	f.addElement("gender", info.s("gender"), "hname:'성별', required:'Y', option:'number'");
	f.addElement("birthday", m.time("yyyy-MM-dd", info.s("birthday")), "hname:'생년월일'");
	String mobile = "";
	if(!"".equals(info.s("mobile"))) try { mobile = SimpleAES.decrypt(info.s("mobile")); } catch(Exception e) { }
	f.addElement("mobile", mobile, "hname:'휴대전화'");
	f.addElement("email", info.s("email"), "hname:'이메일', option:'email'");
	f.addElement("zipcode", info.s("zipcode"), "hname:'우편번호'");
	//f.addElement("addr", info.s("addr"), "hname:'주소'");
	f.addElement("new_addr", info.s("new_addr"), "hname:'주소'");
	f.addElement("addr_dtl", info.s("addr_dtl"), "hname:'상세주소'");
	f.addElement("etc1", info.s("etc1"), "hname:'기타1'");
	f.addElement("etc2", info.s("etc2"), "hname:'기타2'");
	f.addElement("etc3", info.s("etc3"), "hname:'기타3'");
	f.addElement("etc4", info.s("etc4"), "hname:'기타4'");
	f.addElement("etc5", info.s("etc5"), "hname:'기타5'");
	f.addElement("status", info.i("status"), "hname:'상태', option:'number'");

	f.addElement("display_yn", info.s("display_yn"), "hname:'강사노출여부'");
	f.addElement("name_en", info.s("name_en"), "hname:'강사명(영문)'");
	f.addElement("attached", info.s("attached"), "hname:'소속'");
	f.addElement("ability", null, "hname:'경력사항'");
	f.addElement("major", info.s("major"), "hname:'전공'");
	f.addElement("university", info.s("university"), "hname:'최종학력'");
	f.addElement("introduce", null, "hname:'소개'");
	f.addElement("bank_nm", info.s("bank_nm"), "hname:'은행명'");
	f.addElement("bank_account", info.s("bank_account"), "hname:'계좌번호'");
	f.addElement("tutor_file", null, "hname:'사진', allow:'jpg|gif|jpeg|png'");
}

//수정
if(m.isPost() && f.validate()) {

	//삭제
	if("-2".equals(f.get("status"))) {
		if(!outBlock) { m.jsAlert("권한이 없습니다."); return; }

		//수정
		user.item("passwd", "");
		user.item("status", -2);
		if(!user.update("id = " + uid + " AND site_id = " + siteId)) { m.jsAlert("수정하는 중 오류가 발생했습니다."); return; }

		//세션삭제
		if(-1 == UserSession.execute("UPDATE " + UserSession.table + " SET session_id = 'user_quit_" + sysNow + "', mod_date = '" + sysNow + "' WHERE user_id = " + uid + " AND site_id = " + siteId)) { m.jsAlert("수정하는 중 오류가 발생했습니다[2]."); return; }

		//탈퇴등록
		userOut.item("user_id", uid);
		userOut.item("site_id", siteId);
		userOut.item("out_type", "ETC");
		userOut.item("memo", "CRM 탈퇴");
		userOut.item("admin_id", userId);
		userOut.item("out_date", m.time("yyyyMMddHHmmss"));
		userOut.item("reg_date", m.time("yyyyMMddHHmmss"));
		userOut.item("status", 1);
		if(!userOut.replace()) { m.jsAlert("등록하는 중 오류가 발생했습니다."); return; }

		//이동
		m.js("parent.parent.opener.location.reload();");
		m.jsErrClose("탈퇴처리 되었습니다.", "parent.parent");
		return;

	//비밀번호수정/세션삭제
	} else if(!"".equals(f.get("passwd"))) {
		//제한-비밀번호
		if(!f.get("passwd").matches("^(?=.*?[A-Za-z])(?=.*?[0-9])(?=.*?[\\W_]).{8,}$")) {
			m.jsAlert("비밀번호는 영문, 숫자, 특수문자 조합 8자 이상 입력하세요.");
			return;
		}

		user.item("passwd", m.encrypt(f.get("passwd"), "SHA-256"));
		if(-1 == UserSession.execute("UPDATE " + UserSession.table + " SET session_id = 'passwd_modify_" + sysNow + "', mod_date = '" + sysNow + "' WHERE user_id = " + uid + " AND site_id = " + siteId)) { m.jsAlert("수정하는 중 오류가 발생했습니다[2]."); return; }
	}

	user.item("user_nm", f.get("user_nm"));
	if(superBlock && superModifyBlock) user.item("user_kind", f.get("user_kind"));
	if(adminBlock) user.item("dept_id", f.get("dept_id"));
	user.item("tutor_yn", f.get("tutor_yn", "N"));
	user.item("gender", f.getInt("gender"));
	user.item("birthday", m.time("yyyyMMdd", f.get("birthday")));
	user.item("mobile", !"".equals(f.get("mobile")) ? SimpleAES.encrypt(f.get("mobile")) : "");
	user.item("email", f.get("email"));
	user.item("zipcode", f.get("zipcode"));
	//user.item("addr", f.get("addr"));
	user.item("new_addr", f.get("new_addr"));
	user.item("addr_dtl", f.get("addr_dtl"));
	user.item("etc1", f.get("etc1"));
	user.item("etc2", f.get("etc2"));
	user.item("etc3", f.get("etc3"));
	user.item("etc4", f.get("etc4"));
	user.item("etc5", f.get("etc5"));
	user.item("display_yn", f.get("display_yn"));
	if(superModifyBlock) user.item("status", f.getInt("status"));

	if(!user.update("id = " + uid + "")) { m.jsAlert("수정하는 중 오류가 발생했습니다."); return; }

	if("Y".equals(f.get("tutor_yn"))) {
		tutor.item("user_id", uid);
		tutor.item("site_id", siteId);
		tutor.item("tutor_nm", f.get("user_nm"));
		tutor.item("name_en", f.get("name_en"));
		tutor.item("attached", f.get("attached"));

		if(null != f.getFileName("tutor_file")) {
			File f1 = f.saveFile("tutor_file");
			if(f1 != null) {
				tutor.item("tutor_file", f.getFileName("tutor_file"));
				if(!"".equals(info.s("tutor_file"))) m.delFileRoot(m.getUploadPath(info.s("tutor_file")));
			}
		}

		tutor.item("ability", f.get("ability"));
		tutor.item("university", f.get("university"));
		tutor.item("major", f.get("major"));
		tutor.item("introduce", f.get("introduce"));
		tutor.item("bank_nm", f.get("bank_nm"));
		tutor.item("bank_account", f.get("bank_account"));
		tutor.item("status", "1");

		if(0 < tutor.findCount("user_id = " + uid)) {
			if(!tutor.update("user_id = " + uid)) { m.jsAlert("강사정보를 수정하는 중 오류가 발생했습니다."); return; }
		} else {
			if(!tutor.insert()) { m.jsAlert("강사정보를 등록하는 중 오류가 발생했습니다."); return; }
		}
	} else if(info.b("tutor_yn")) {
		tutor.item("status", "-1");
		//if(!tutor.update("user_id = " + uid + " AND status != -1")) { m.jsAlert("강사정보를 수정하는 중 오류가 발생했습니다."); return; }
	}
	
	m.jsAlert("수정 되었습니다.");
	m.jsReplace("user_modify.jsp?" + m.qs(), "parent");
	return;
}

//액션로그-조회
actionLog.item("site_id", siteId);
actionLog.item("user_id", userId);
actionLog.item("module", "user");
actionLog.item("module_id", uid);
actionLog.item("action_type", "R");
actionLog.item("action_desc", "회원정보조회");
actionLog.item("before_info", "");
actionLog.item("after_info", "");
actionLog.item("reg_date", m.time("yyyyMMddHHmmss"));
actionLog.item("status", 1);
if(!actionLog.insert()) { m.jsError("등록하는 중 오류가 발생했습니다."); return; }

//포맷팅
if(0 < info.i("dept_id")) {	
	info.put("dept_nm_conv", userDept.getNames(info.i("dept_id")));
} else {	
	info.put("dept_nm", "[미소속]");
	info.put("dept_nm_conv", "[미소속]");
}
info.put("tutor_file_conv", m.encode(info.s("tutor_file")));
info.put("tutor_file_url", m.getUploadUrl(info.s("tutor_file")));
info.put("tutor_file_ek", m.encrypt(info.s("tutor_file") + m.time("yyyyMMdd")));
info.put("super_modify_block", superModifyBlock);
info.put("user_kind_conv", m.getItem(info.s("user_kind"), user.kinds));
info.put("email_yn_conv", m.getItem(info.s("email_yn"), user.receiveYn));
info.put("sms_yn_conv", m.getItem(info.s("sms_yn"), user.receiveYn));
info.put("status_conv", m.getItem(info.s("status"), user.statusList));

//파일
DataSet files = file.getFileList(m.parseInt(uid), "user", true);
while(files.next()) {
	files.put("ext", file.getFileIcon(files.s("filename")));
	files.put("ek", m.encrypt(files.s("id")));
	files.put("file_url", m.getUploadUrl(files.s("filename")));
	files.put("class", -1 < files.s("filetype").indexOf("image/") ? "image01" : "");
}

//휴면해제
if("awake".equals(m.rs("mode"))) {
	if(0 >= userSleep.awakeUser(uid)) { m.jsAlert("휴면해제하는 중 오류가 발생했습니다."); }
	m.jsReplace("../crm/user_modify.jsp?" + m.qs("mode"), "parent");
	return;
}

//출력
p.setLayout(ch);
p.setBody("crm.user_modify");
p.setVar("p_title", !sleepBlock ? "수정" : "휴면정보 조회");
p.setVar("list_query", m.qs("id"));
p.setVar("query", m.qs());
p.setVar("form_script", f.getScript());
p.setVar("tab_user", "current");

p.setVar(info);
p.setVar("sinfo", sinfo);
p.setLoop("files", files);

p.setVar("out_block", outBlock);
p.setVar("sleep_block", sleepBlock);

p.setVar("SITE_CONFIG", SiteConfig.getArr(new String[] {"user_etc_", "join_"}));
p.setLoop("kinds", m.arr2loop(user.kinds));
p.setLoop("status_list", m.arr2loop(user.statusList));
p.setLoop("genders", m.arr2loop(user.genders));
//p.setLoop("dept_list", userDept.find("status = 1 AND site_id  = " + siteId + "", "*", "sort ASC"));
p.setLoop("dept_list", userDept.getList(siteId));
p.display();

%>