<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

if(!Menu.accessible(31, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

if(m.isPost()) {
	String[] idx = f.getArr("idx");
	String[] paths = new String[idx.length];
	if(null != idx) {
		for(int i=0; i<idx.length; i++) {
			paths[i] = m.decode(idx[i]);
		}
	}
	new Zip().compress(paths, m.time("yyyyMMddHHmmss") + ".zip", response);
}

%>