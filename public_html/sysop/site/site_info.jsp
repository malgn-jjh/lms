<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//접근권한
if(!Menu.accessible(82, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//객체
SiteDao site = new SiteDao();
UserDeptDao userDept = new UserDeptDao();
UserDao user = new UserDao();
ApiLogDao apiLog = new ApiLogDao();

//정보
DataSet info = site.query(
	" SELECT a.*, b.user_nm super_name "
	+ " , (SELECT COUNT(*) FROM " + apiLog.table + " WHERE site_id = a.id "
		+ " AND reg_date >= '" + m.time("yyyyMM01000000") + "' AND reg_date <= '" + m.time("yyyyMMddHHmmss") + "' AND return_code = '000') api_cnt "
	+ " FROM " + site.table + " a "
	+ " LEFT JOIN " + user.table + " b ON a.super_id = b.id AND a.id = b.site_id AND b.user_kind = 'S' "
	+ " WHERE a.id = '" + siteId + "' "
);
if(!info.next()) { m.jsError("해당 정보가 없습니다."); return; }

DataSet cinfo = SiteConfig.getDataSet(siteId);

//파일삭제
if("fdel".equals(m.request("mode"))) {
	if("logo".equals(m.rs("type"))) {
		if(!"".equals(info.s("logo"))) {
			site.item("logo", "");
			if(!site.update("id = " + siteId + "")) { m.jsAlert("로고를 삭제하는 중 오류가 발생했습니다."); return; }
			m.delFileRoot(m.getUploadPath(info.s("logo")));
		}

	} else if("certificate".equals(m.rs("type"))) {
		if(!"".equals(info.s("certificate_file"))) {
			site.item("certificate_file", "");
			if(!site.update("id = " + siteId + "")) { m.jsAlert("수료증 배경 이미지를 삭제하는 중 오류가 발생했습니다."); return; }
			m.delFileRoot(m.getUploadPath(info.s("certificate_file")));
		}
	} else if("course".equals(m.rs("type"))) {
		if(!"".equals(info.s("course_file"))) {
			site.item("course_file", "");
			if(!site.update("id = " + siteId + "")) { m.jsAlert("수강증 배경 이미지를 삭제하는 중 오류가 발생했습니다."); return; }
			m.delFileRoot(m.getUploadPath(info.s("course_file")));
		}
	} else if("certificate_multi".equals(m.rs("type"))) {
		if(!"".equals(info.s("certificate_multi_file"))) {
			site.item("certificate_multi_file", "");
			if(!site.update("id = " + siteId + "")) { m.jsAlert("수료내역서 배경 이미지를 삭제하는 중 오류가 발생했습니다."); return; }
			m.delFileRoot(m.getUploadPath(info.s("certificate_multi_file")));
		}
	}
	return;
}

//변수
String siteEmailNm = "";
String siteEmail = info.s("site_email");
if(-1 < siteEmail.indexOf("<")) {
	siteEmailNm = siteEmail.substring(0, siteEmail.indexOf("<")).trim();
	siteEmail = siteEmail.substring(siteEmail.indexOf("<") + 1, siteEmail.indexOf(">")).trim();
}

//폼체크
f.addElement("site_nm", info.s("site_nm"), "hname:'이름', required:'Y'");
f.addElement("logo", null, "hname:'로고이미지'");
f.addElement("zipcode", info.s("zipcode"), "hname:'우편번호'");
f.addElement("new_addr", info.s("new_addr"), "hname:'주소'");
f.addElement("addr_dtl", info.s("addr_dtl"), "hname:'상세주소'");
f.addElement("join_status", info.i("join_status"), "hname:'회원가입 상태', required:'Y'");
f.addElement("dept_id", info.i("dept_id"), "hname:'기본 회원소속', required:'Y'");
f.addElement("site_email", info.s("site_email"), "hname:'발신자이메일'");
f.addElement("site_email_addr", siteEmail, "hname:'발신자이메일', required:'Y'");
f.addElement("site_email_nm", siteEmailNm, "hname:'발신자이메일발신자명'");
f.addElement("receive_email", info.s("receive_email"), "hname:'수신이메일', option:'email'");
f.addElement("receive_phone", info.s("receive_phone"), "hname:'수신전화번호'");
f.addElement("certificate_file", null, "hname:'수료증 배경', allow:'jpg|jpeg|png|gif'");
f.addElement("course_file", null, "hname:'수강증 배경', allow:'jpg|jpeg|png|gif'");
f.addElement("certificate_multi_file", null, "hname:'수료내역서 배경', allow:'jpg|jpeg|png|gif'");
f.addElement("classroom_notice", null, "hname:'강의실상단안내문구'");
f.addElement("classroom_notice_yn", cinfo.s("classroom_notice_yn"), "hname:'강의실상단안내문구 노출여부'");
f.addElement("pay_notice", null, "hname:'결제페이지안내문구'");
f.addElement("pay_notice_yn", info.s("pay_notice_yn"), "hname:'결제페이지안내문구 노출여부'");
f.addElement("copyright", null, "hname:'하단HTML'");
f.addElement("delivery_free_price", cinfo.i("delivery_free_price"), null);
f.addElement("refund_reason_yn", cinfo.s("refund_reason_yn"), "hname:'환불사유 입력여부'");


//수정
if(m.isPost() && f.validate()) {

	site.item("site_nm", f.get("site_nm"));
	site.item("copyright", f.get("copyright"));
	if(f.getFileName("logo") != null) {
		File f1 = f.saveFile("logo");
		if(f1 != null) {
			site.item("logo", f.getFileName("logo"));
			if(!"".equals(info.s("logo"))) m.delFileRoot(m.getUploadPath(info.s("logo")));
		}
	}
	site.item("join_status", f.getInt("join_status"));
	site.item("zipcode", f.get("zipcode"));
	site.item("new_addr", f.get("new_addr"));
	site.item("addr_dtl", f.get("addr_dtl"));

	site.item("pay_notice", f.get("pay_notice"));
	site.item("pay_notice_yn", f.get("pay_notice_yn"));

	site.item("site_email", f.get("site_email"));
	site.item("receive_email", f.get("receive_email"));
	site.item("receive_phone", f.get("receive_phone"));

	if(null != f.getFileName("certificate_file")) {
		File f1 = f.saveFile("certificate_file");
		if(f1 != null) {
			site.item("certificate_file", f.getFileName("certificate_file"));
			m.delFileRoot(m.getUploadPath(info.s("certificate_file")));
		}
	}
	if(null != f.getFileName("course_file")) {
		File f1 = f.saveFile("course_file");
		if(f1 != null) {
			site.item("course_file", f.getFileName("course_file"));
			m.delFileRoot(m.getUploadPath(info.s("course_file")));
		}
	}
	if(null != f.getFileName("certificate_multi_file")) {
		File f1 = f.saveFile("certificate_multi_file");
		if(f1 != null) {
			site.item("certificate_multi_file", f.getFileName("certificate_multi_file"));
			m.delFileRoot(m.getUploadPath(info.s("certificate_multi_file")));
		}
	}
	
	site.item("dept_id", f.getInt("dept_id"));

	if(!site.update("id = " + siteId + "")) { m.jsAlert("수정하는 중 오류가 발생했습니다."); return; 	}

	SiteConfig.put("delivery_free_price", f.getInt("delivery_free_price"));
	SiteConfig.put("refund_reason_yn", f.get("refund_reason_yn", "N"));

	SiteConfig.put("classroom_notice_yn", f.get("classroom_notice_yn", "N"));
	SiteConfig.put("classroom_notice", f.get("classroom_notice"));

	//캐쉬 삭제
	site.remove(info.s("domain"));
	if(!"".equals(info.s("domain2"))) site.remove(info.s("domain2"));

	SiteConfig.remove(siteId + "");

	m.jsAlert("수정되었습니다.");
	m.jsReplace("site_info.jsp", "parent");
	return;
}

//포멧팅
info.put("logo_conv", m.encode(info.s("logo")));
info.put("logo_url", (!"/data".equals(Config.getDataUrl()) ? "" : siteDomain) + m.getUploadUrl(info.s("logo")));
info.put("logo_ek", m.encrypt(info.s("logo") + m.time("yyyyMMdd")));

info.put("certificate_file_conv", m.encode(info.s("certificate_file")));
info.put("certificate_file_url", (!"/data".equals(Config.getDataUrl()) ? "" : siteDomain) + m.getUploadUrl(info.s("certificate_file")));
info.put("certificate_file_ek", m.encrypt(info.s("certificate_file") + m.time("yyyyMMdd")));

info.put("course_file_conv", m.encode(info.s("course_file")));
info.put("course_file_url", (!"/data".equals(Config.getDataUrl()) ? "" : siteDomain) + m.getUploadUrl(info.s("course_file")));
info.put("course_file_ek", m.encrypt(info.s("course_file") + m.time("yyyyMMdd")));

info.put("certificate_multi_file_conv", m.encode(info.s("certificate_multi_file")));
info.put("certificate_multi_file_url", (!"/data".equals(Config.getDataUrl()) ? "" : siteDomain) + m.getUploadUrl(info.s("certificate_multi_file")));
info.put("certificate_multi_file_ek", m.encrypt(info.s("certificate_multi_file") + m.time("yyyyMMdd")));

info.put("reg_date_conv", m.time("yyyy.MM.dd HH:mm:ss", info.s("reg_date")));

info.put("ovp_vendor_conv", m.getItem(info.s("ovp_vendor"), site.ovpVendors));
info.put("catenoid_block", "C".equals(info.s("ovp_vendor")));

//출력
p.setBody("site.site_info");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setVar(info);
p.setVar("cinfo", cinfo);
p.setVar("modify", true);

p.setLoop("status_list", m.arr2loop(site.statusList));
p.setLoop("dept_list", userDept.getList(siteId));
p.setLoop("pg_list", m.arr2loop(site.pgList));
p.display();

%>