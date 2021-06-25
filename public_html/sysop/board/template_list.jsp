<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../init.jsp" %><%

//접근권한
if(!(Menu.accessible(6, userId, userKind))) { m.jsError("접근 권한이 없습니다."); return; }

//기본키
int bid = m.ri("bid");
if(1 > bid) { m.jsAlert("기본키는 반드시 지정해야 합니다."); return; }

//객체
PostTemplateDao postTemplate = new PostTemplateDao(siteId);
BoardDao board = new BoardDao();

//정보-게시판
DataSet binfo = board.find("id = " + bid + " AND board_type = 'qna' AND status = 1 AND site_id = " + siteId);
if(!binfo.next()) { m.jsAlert("해당 게시판 정보가 없습니다."); return; }

//폼체크
f.addElement("bid", null, null);
f.addElement("s_field", null, null);
f.addElement("s_keyword", null, null);

//목록
ListManager lm = new ListManager(jndi);
//lm.d(out);
lm.setRequest(request);
lm.setListNum("excel".equals(m.rs("mode")) ? 60000 : f.getInt("s_listnum", 20));
lm.setTable(postTemplate.table + " a");
lm.setFields("a.*");
lm.addWhere("a.status != -1");
lm.addWhere("a.board_id = " + bid);
lm.addWhere("a.site_id = " + siteId);
if(!"".equals(f.get("s_field"))) lm.addSearch(f.get("s_field"), f.get("s_keyword"), "LIKE");
else if("".equals(f.get("s_field")) && !"".equals(f.get("s_keyword"))) lm.addSearch("a.template_nm,a.content", f.get("s_keyword"), "LIKE");
lm.setOrderBy(!"".equals(f.get("ord")) ? f.get("ord") : "a.id DESC");

//포맷팅
DataSet list = lm.getDataSet();
while(list.next()) {
	list.put("template_nm_conv", m.cutString(list.s("template_nm"), 50));
	list.put("content_conv", m.cutString(m.stripTags(list.s("content")), 100));
	list.put("reg_date_conv", m.time("yyyy.MM.dd HH:mm", list.s("reg_date")));
	list.put("status_conv", m.getItem(list.s("status"), postTemplate.statusList));
}

//출력
p.setLayout("sysop");
p.setBody("board.template_list");
p.setVar("p_title", binfo.s("board_nm") + "게시판답변템플릿관리");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setLoop("list", list);
p.setVar("pagebar", lm.getPaging());
p.setVar("list_total", lm.getTotalString());

p.setVar("board", binfo);

p.display();

%>