<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//CHECKED-2014.06.27

//접근권한
if(!Menu.accessible(16, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//기본키
int id = m.ri("id");
if(id == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

//객체
UserDao user = new UserDao();
TutorDao tutor = new TutorDao();
UserDeptDao userDept = new UserDeptDao();

//정보
DataSet info = user.query(
	"SELECT a.*, t.* "
	+ " FROM " + user.table + " a "
	+ " INNER JOIN " + tutor.table + " t ON t.user_id = a.id "
	+ " WHERE a.id = " + id + " AND a.site_id = " + siteId + " AND a.tutor_yn = 'Y' AND a.status != -1"
);
if(!info.next()) { m.jsError("해당 정보가 없습니다."); }

//파일삭제
if("fdel".equals(m.rs("mode"))) {
	if(!"".equals(info.s("tutor_file"))) {
		tutor.item("tutor_file", "");
		if(!tutor.update("user_id = " + id + "")) { }
		m.delFileRoot(m.getUploadPath(info.s("tutor_file")));
	}
	return;
}


//폼체크
f.addElement("dept_id", info.s("dept_id"), "hname:'소속', required:'Y'");
f.addElement("user_nm", info.s("user_nm"), "hname:'강사명', required:'Y'");
f.addElement("name_en", info.s("name_en"), "hname:'강사명(영문)', required:'Y'");
f.addElement("passwd", null, "hname:'비밀번호', match:'passwd2'");
f.addElement("gender", info.s("gender"), "hname:'성별', required:'Y'");
f.addElement("birthday", m.time("yyyy-MM-dd", info.s("birthday")), "hname:'생년월일'");
String mobile = "";
if(!"".equals(info.s("mobile"))) try { mobile = SimpleAES.decrypt(info.s("mobile")); } catch(Exception e) { m.errorLog(e.getMessage(), e); }
f.addElement("mobile", mobile, "hname:'휴대전화'");
f.addElement("email1", m.split("@", info.s("email"), 2)[0], "hname:'이메일', required:'Y', option:'email', glue:'email2', delim:'@'");
f.addElement("email2", m.split("@", info.s("email"), 2)[1], "hname:'이메일', required:'Y'");
f.addElement("zipcode", info.s("zipcode"), "hname:'우편번호'");
//f.addElement("addr", info.s("addr"), "hname:'구주소'");
f.addElement("new_addr", info.s("new_addr"), "hname:'주소'");
f.addElement("addr_dtl", info.s("addr_dtl"), "hname:'상세주소'");
f.addElement("etc1", info.s("etc1"), "hname:'기타1'");
f.addElement("etc2", info.s("etc2"), "hname:'기타2'");
f.addElement("etc3", info.s("etc3"), "hname:'기타3'");
f.addElement("etc4", info.s("etc4"), "hname:'기타4'");
f.addElement("etc5", info.s("etc5"), "hname:'기타5'");

f.addElement("display_yn", info.s("display_yn"), "hname:'강사노출여부'");
f.addElement("attached", info.s("attached"), "hname:'소속'");
f.addElement("ability", null, "hname:'경력사항'");
f.addElement("major", info.s("major"), "hname:'전공'");
f.addElement("university", info.s("university"), "hname:'최종학력'");
f.addElement("introduce", null, "hname:'소개'");
f.addElement("bank_nm", info.s("bank_nm"), "hname:'은행명'");
f.addElement("bank_account", info.s("bank_account"), "hname:'계좌번호'");
f.addElement("tutor_file", null, "hname:'사진', allow:'jpg|gif|jpeg|png'");
f.addElement("status", info.s("status"), "hname:'상태', required:'Y'");

//수정
if(m.isPost() && f.validate()) {

	//제한-이미지URI및용량
	String ability = f.get("ability");
	String introduce = f.get("introduce");
	int byteab = ability.replace("\r\n", "\n").getBytes("UTF-8").length;
	int bytein = introduce.replace("\r\n", "\n").getBytes("UTF-8").length;
	if(-1 < ability.indexOf("<img") && -1 < ability.indexOf("data:image/") && -1 < ability.indexOf("base64")) {
		m.jsAlert("경력 사항 이미지는 첨부파일 기능으로 업로드 해 주세요.");
		return;
	}
	if(-1 < introduce.indexOf("<img") && -1 < introduce.indexOf("data:image/") && -1 < introduce.indexOf("base64")) {
		m.jsAlert("강사 소개 이미지는 첨부파일 기능으로 업로드 해 주세요.");
		return;
	}
	if(60000 < byteab) { m.jsAlert("경력 사항 내용은 60000바이트를 초과해 작성하실 수 없습니다.\\n(현재 " + byteab + "바이트)"); return; }
	if(60000 < bytein) { m.jsAlert("강사 소개 내용은 60000바이트를 초과해 작성하실 수 없습니다.\\n(현재 " + bytein + "바이트)"); return; }

	user.item("dept_id", f.get("dept_id"));
	user.item("user_nm", f.get("user_nm"));
	if(!"".equals(f.get("passwd"))) user.item("passwd", m.encrypt(f.get("passwd"), "SHA-256"));
	user.item("email", f.glue("@", "email1, email2"));
	user.item("mobile", !"".equals(f.get("mobile")) ? SimpleAES.encrypt(f.get("mobile")) : "");
	user.item("zipcode", f.get("zipcode"));
	//user.item("addr", f.get("addr"));
	user.item("new_addr", f.get("new_addr"));
	user.item("addr_dtl", f.get("addr_dtl"));
	user.item("gender", f.getInt("gender"));
	user.item("birthday", m.time("yyyyMMdd", f.get("birthday")));
	user.item("etc1", f.get("etc1"));
	user.item("etc2", f.get("etc2"));
	user.item("etc3", f.get("etc3"));
	user.item("etc4", f.get("etc4"));
	user.item("etc5", f.get("etc5"));
	user.item("display_yn", f.get("display_yn"));
	user.item("status", f.getInt("status"));

	if(!user.update("id = " + id + "")) { m.jsAlert("수정하는 중 오류가 발생했습니다."); return; }

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
	tutor.item("status", f.getInt("status"));

	if(!tutor.update("user_id = " + id + "")) { m.jsAlert("수정하는 중 오류가 발생했습니다."); return; }

	//이동
	m.jsReplace("tutor_list.jsp?" + m.qs("id"), "parent");
	return;

}

//포맷팅
info.put("tutor_file_conv", m.encode(info.s("tutor_file")));
info.put("tutor_file_url", m.getUploadUrl(info.s("tutor_file")));
info.put("tutor_file_ek", m.encrypt(info.s("tutor_file") + m.time("yyyyMMdd")));

//출력
p.setBody("user.tutor_insert");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setVar("modify", true);
p.setVar(info);

p.setLoop("dept_list", userDept.getList(siteId));
p.setLoop("genders", m.arr2loop(user.genders));
p.setLoop("status_list", m.arr2loop(user.statusList));
p.display();

%>