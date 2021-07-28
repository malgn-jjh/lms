<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//CHECKED-2014.06.27

//접근권한
if(!Menu.accessible(17, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//기본키
int id = m.ri("id");
if(id == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

//객체
UserDao user = new UserDao();
UserDeptDao userDept = new UserDeptDao();

//정보
DataSet info = user.find("id = " + id + " AND site_id = " + siteId + " AND user_kind IN ('C', 'D', 'A', 'S') AND status != -1");
if(!info.next()) { m.jsError("해당 정보가 없습니다."); }

//폼체크
f.addElement("dept_id", info.s("dept_id"), "hname:'소속', required:'Y'");
f.addElement("user_nm", info.s("user_nm"), "hname:'관리자명', required:'Y'");
f.addElement("user_kind", info.s("user_kind"), "hname:'유형', required:'Y'");
f.addElement("passwd", null, "hname:'비밀번호', match:'passwd2'");
f.addElement("gender", info.s("gender"), "hname:'성별', required:'Y'");
f.addElement("birthday", m.time("yyyy-MM-dd", info.s("birthday")), "hname:'생년월일'");
f.addElement("email1", m.split("@", info.s("email"), 2)[0], "hname:'이메일', required:'Y', option:'email', glue:'email2', delim:'@'");
f.addElement("email2", m.split("@", info.s("email"), 2)[1], "hname:'이메일', required:'Y'");
String mobile = "";
if(!"".equals(info.s("mobile"))) mobile = SimpleAES.decrypt(info.s("mobile"));
f.addElement("mobile", mobile, "hname:'휴대전화'");
f.addElement("zipcode", info.s("zipcode"), "hname:'우편번호'");
//f.addElement("addr", info.s("addr"), "hname:'구주소'");
f.addElement("new_addr", info.s("new_addr"), "hname:'주소'");
f.addElement("addr_dtl", info.s("addr_dtl"), "hname:'상세주소'");
f.addElement("etc1", info.s("etc1"), "hname:'기타1'");
f.addElement("etc2", info.s("etc2"), "hname:'기타2'");
f.addElement("etc3", info.s("etc3"), "hname:'기타3'");
f.addElement("etc4", info.s("etc4"), "hname:'기타4'");
f.addElement("etc5", info.s("etc5"), "hname:'기타5'");
f.addElement("status", info.s("status"), "hname:'상태', required:'Y'");

//수정
if(m.isPost() && f.validate()) {

	//제한-유형을 운영자를 변경시 또는 상태를 중지로 변경시 최고 관리자가 없는 경우
	if(!"S".equals(f.get("user_kind")) || f.getInt("status") == 0) {
		if(0 == user.findCount("status = 1 AND user_kind = 'S' AND site_id = " + siteId + " AND id != '" + id + "'")) {
			m.jsAlert("최고 관리자는 최소 한 명이상 이여야 합니다. 상태 또는 유형을 확인하세요.");
			return;
		}
	}

	user.item("dept_id", f.get("dept_id"));
	user.item("user_nm", f.get("user_nm"));
	user.item("user_kind", f.get("user_kind"));
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
	user.item("status", f.getInt("status"));
	if(!user.update("id = " + id + "")) { m.jsAlert("수정하는 중 오류가 발생했습니다."); return; }

	//이동
	m.jsReplace("admin_list.jsp?" + m.qs("id"), "parent");
	return;
}


//출력
p.setBody("user.admin_insert");
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