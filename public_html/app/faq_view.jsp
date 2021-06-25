<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//JSON

//기본키
int id = m.ri("id");
if(id == 0) {
	_error.put("error_code", "2200");
	_error.put("error_msg", "잘못된 접근입니다.");
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}


//객체
DataObject board = new DataObject("TB_BOARD");
DataObject post = new DataObject("TB_POST");

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


//정보
DataSet info = post.find("id = " + id + " AND status = 1");
if(!info.next()) {
	_error.put("error_code", "2220");
	_error.put("error_msg", "해당 정보가 없습니다.");
	_return.put("error", _error);
	out.print(_return.toString());
	return;
}

_data.put("subject", info.s("subject"));
_data.put("content", info.s("content"));
_data.put("writer", info.s("writer"));
_data.put("reg_date_conv", m.time("yyyy.MM.dd", info.s("reg_date")));
_return.put("data", _data);
out.print(_return.toString());

%>