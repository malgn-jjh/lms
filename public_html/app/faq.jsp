<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//JSON

//객체
DataObject board = new DataObject("TB_BOARD");
DataObject post = new DataObject("TB_POST");
DataObject file = new DataObject("TB_FILE");
DataObject category = new DataObject("TB_CATEGORY");

//변수
String code = "faq";

//정보
DataSet binfo = board.find("code = '" + code + "' AND site_id = " + siteId + "");
if(!binfo.next()) {
	_error.put("error_code", "2210");
	_error.put("error_msg", "해당 게시판 정보가 없습니다.");
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}

//변수
int bid = binfo.i("id");
int ln = 5;
int newHour = 24;

//목록
ListManager lm = new ListManager(jndi);
//lm.d(out);
lm.setRequest(request);
lm.setListNum(1000);
lm.setTable(
	post.table + " a "
	+ " LEFT JOIN " + file.table + " f ON f.module = 'post' AND f.module_id = a.id AND f.main_yn = 'Y' "
	+ " LEFT JOIN " + category.table + " c ON a.category_id = c.id "
);
lm.setFields("a.*, c.category_nm, f.filename");
lm.addWhere("a.status = 1");
lm.addWhere("a.board_id = " + bid + "");
lm.addSearch("a.category_id", f.get("s_category"));
lm.setOrderBy("a.thread ASC, a.depth ASC");

//포맷팅
DataSet list = lm.getDataSet();
while(list.next()) {
	list.put("reg_date_conv", m.time("yyyy.MM.dd", list.s("reg_date")));
	list.put("subject_conv", m.cutString(list.s("subject"), 60));
	list.put("cid", f.get("s_category"));
}

_data.put("category", f.get("s_category"));
_data.put("list", new JSONArray(list));
_return.put("data", _data);
out.print(_return.toString());

%>