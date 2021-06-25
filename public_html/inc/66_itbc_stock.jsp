<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../init.jsp" %><%

//정보
DataSet info = new DataSet();
info.addRow();

/*
if("Y".equals(SiteConfig.s("itbc_stock_yn"))) {
	try {
		//변수
		Http http = new Http("http://www.krx.co.kr/main/main.jsp");
		String src = m.replace(http.send("GET"), new String[] { "\r\n", "\r", "\n", "\t" }, "");

		String[] kospi = m.split("<div class=\"index-info-l\"><span class=\"index-name\">KOSPI</span></div><div class=\"index-info-r\"><span><span class=\"index-price\">", src);
		if(1 < kospi.length) {
			kospi = m.split("</span><br />", kospi[1]);
			if(1 < kospi.length) {
				info.put("kospi", kospi[0]);
			}
		} else {
			info.put("kospi", "점검중");
		}

		String[] kosdaq = m.split("<div class=\"index-info-l\"><span class=\"index-name\">KOSDAQ</span></div><div class=\"index-info-r\"><span><span class=\"index-price\">", src);
		if(1 < kosdaq.length) {
			kosdaq = m.split("</span><br />", kosdaq[1]);
			if(1 < kosdaq.length) {
				info.put("kosdaq", kosdaq[0]);
			}
		} else {
			info.put("kosdaq", "점검중");
		}
	} catch(Exception e) {
		info.put("kospi", "점검중");
		info.put("kosdaq", "점검중");
	}
} else {
	info.put("kospi", "-");
	info.put("kosdaq", "-");
}
*/
info.put("kospi", "-");
info.put("kosdaq", "-");

//출력
p.setLayout(null);
p.setBody("inc.66_itbc_stock");
p.setVar(info);
p.display();

%>