<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../init.jsp" %><%

//접근권한
if(!(Menu.accessible(6, userId, userKind))) { m.jsError("접근 권한이 없습니다."); return; }

//기본키
int bid = m.ri("bid");
int id = m.ri("id");
if(1 > bid || 1 > id) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

//객체
PostTemplateDao postTemplate = new PostTemplateDao();

//정보
DataSet info = postTemplate.find("id = " + id + " AND board_id = " + bid + " AND site_id = " + siteId + " AND status != -1");
if(!info.next()) { m.jsError("해당 정보가 없습니다."); return; }

//삭제
postTemplate.item("status", -1);
if(!postTemplate.update("id = " + id)) { m.jsError("삭제하는 중 오류가 발생하였습니다."); return; }

//이동
m.jsReplace("template_list.jsp?" + m.qs("id"));
return;

%>