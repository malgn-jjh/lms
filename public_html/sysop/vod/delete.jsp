<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

if(!Menu.accessible(31, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

if(m.isPost()) {
	String[] idx = f.getArr("idx");
	if(null != idx) {
		for(int i=0; i<idx.length; i++) {
			String path = m.decode(idx[i]);
			if(!"".equals(path)) { m.delFile(path); }
		}
	}
} else {
	String path = m.rs("path");
	if("".equals(path)) {
		m.jsAlert("경로는 반드시 지정해야 합니다.");
		return;
	}
	m.delFile(m.decode(path));
}

//out.print("<script>top.location.href = top.location.href;</script>");
out.print("<script>parent.parent._LEFT.location.href = parent.parent._LEFT.location.href;</script>");
out.print("<script>parent.location.href = parent.location.href;</script>");


%>