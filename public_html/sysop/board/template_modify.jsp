<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../init.jsp" %><%

//접근권한
if(!(Menu.accessible(6, userId, userKind))) { m.jsError("접근 권한이 없습니다."); return; }

//기본키
int bid = m.ri("bid");
int id = m.ri("id");
if(1 > bid || 1 > id) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

//객체
PostTemplateDao postTemplate = new PostTemplateDao();
BoardDao board = new BoardDao();

//정보-게시판
DataSet binfo = board.find("id = " + bid + " AND board_type = 'qna' AND status = 1 AND site_id = " + siteId);
if(!binfo.next()) { m.jsError("해당 게시판 정보가 없습니다."); return; }

//정보
DataSet info = postTemplate.find("id = " + id + " AND board_id = " + bid + " AND site_id = " + siteId + " AND status != -1");
if(!info.next()) { m.jsError("해당 정보가 없습니다."); return; }
info.put("reg_date_conv", m.time("yyyy.MM.dd HH:mm", info.s("reg_date")));

//폼체크
f.addElement("template_nm", info.s("template_nm"), "hname:'템플릿명', required:'Y'");
f.addElement("content", null, "hname:'내용', allowiframe:'Y'");
f.addElement("status", info.s("status"), "hname:'상태', required:'Y'");

//등록
if(m.isPost() && f.validate()) {

	String content = f.get("content");
	//제한-이미지URI
	if(-1 < content.indexOf("<img") && -1 < content.indexOf("data:image/") && -1 < content.indexOf("base64")) {
		m.jsAlert("이미지는 첨부파일 기능으로 업로드 해 주세요.");
		return;
	}

	//제한-용량
	int bytes = content.replace("\r\n", "\n").getBytes("UTF-8").length;
	if(60000 < bytes) {
		m.jsAlert("내용은 60000바이트를 초과해 작성하실 수 없습니다.\\n(현재 " + bytes + "바이트)");
		return;
	}

	postTemplate.item("template_nm", f.get("template_nm"));
	postTemplate.item("content", content);
	postTemplate.item("status", f.get("status", "1"));
	if(!postTemplate.update("id = " + id)) { m.jsAlert("수정하는 중 오류가 발생하였습니다."); return; }

	//이동
	m.jsReplace("template_list.jsp?" + m.qs("id"), "parent");
	return;
}

//출력
p.setBody("board.template_insert");
p.setVar("p_title", binfo.s("board_nm") + "게시판답변템플릿관리");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setVar(info);
p.setVar("board", binfo);
p.setVar("modify", true);

p.setLoop("status_list", m.arr2loop(postTemplate.statusList));
p.display();

%>