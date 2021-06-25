<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//객체
DataObject board = new DataObject("TB_BOARD");
DataObject category = new DataObject("TB_CATEGORY");

//변수
String code = "faq";

//정보
DataSet binfo = board.find("code = '" + code + "' AND site_id = " + siteId + "");
if(!binfo.next()) {
	_error.put("error_code", "2300");
	_error.put("error_msg", "해당 게시판 정보가 없습니다.");
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}

//목록-FAQ카테고리
DataSet categories = category.find("site_id = " + siteId + " AND status = 1 AND module = 'board' AND module_id = " + binfo.i("id") + "", "*", "sort ASC");


//출력
p.setVar("is_android", isAndroid);
p.setVar("is_ios", isIOS);
p.setVar("is_app", isAPP);
p.setLoop("categories", categories);
p.print(out, "../app/html/index.html");

%>