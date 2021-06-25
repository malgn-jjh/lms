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
info.put("status_conv", m.getItem(info.s("status"), postTemplate.statusList));

//출력
p.setBody("board.template_view");
p.setVar("p_title", binfo.s("board_nm") + "게시판답변템플릿관리");
p.setVar("form_script", f.getScript());
p.setVar("list_query", m.qs("id"));
p.setVar("query", m.qs());

p.setVar(info);
p.setVar("board", binfo);

p.display();

%>