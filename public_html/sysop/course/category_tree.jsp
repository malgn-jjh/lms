<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//접근권한
if(!Menu.accessible(22, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//객체
LmCategoryDao category = new LmCategoryDao("course");

//목록
DataSet list = category.find("status = 1 AND module = 'course' AND site_id = " + siteId + "", "*", "parent_id ASC, sort ASC");

//출력
p.setLayout("blank");
p.setBody("course.category_tree");
p.setVar("list_query", m.qs("id"));
p.setVar("query", m.qs());

p.setLoop("list", list);
p.display();

%>