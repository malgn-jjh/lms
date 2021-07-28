<%@ page import="javax.xml.ws.http.HTTPException"%><%@ page contentType="application/json; charset=utf-8" %><%@ include file="../init.jsp" %><%

//JSON
Json _ret = new Json();
_ret.put("ret_code", "000");
_ret.put("ret_msg", "success");

if((1 == siteId || 66 == siteId) && "Y".equals(SiteConfig.s("itbc_stock_yn"))) {

	//변수
	String src = null;

	//HTTP
    try {
		Http http = new Http("https://finance.daum.net/api/domestic/quotes");
		http.setHeader("Referer", "https://finance.daum.net/domestic");
		src = http.send("GET");
	} catch(HTTPException httpe) {
        m.errorLog("HTTPException : " + httpe.getMessage(), httpe);
		_ret.put("ret_code", "100");
		_ret.put("ret_msg", "http error");
	} catch(Exception e) {
        m.errorLog("Exception : " + e.getMessage(), e);
		_ret.put("ret_code", "100");
		_ret.put("ret_msg", "http error");
	}


	//포맷팅
	if(null != src && !"".equals(src)) {
		//변수
		HashMap<String, String> market = new HashMap<String, String>();
		DataSet info = new DataSet();

		//JSON
		info.unserialize(src);
		info.first();
		while(info.next()) {
			if("001".equals(info.s("sectorCode"))) {
				market.put(info.s("market"), m.nf(m.parseDouble(info.s("tradePrice")), 2));
			}
		}
		_ret.put("ret_data", market);
		_ret.put("ret_size", market.size());
	} else {
		_ret.put("ret_code", "200");
		_ret.put("ret_msg", "no return value");
	}

} else {
	_ret.put("ret_code", "900");
	_ret.put("ret_msg", "disabled function");
}

//출력
out.print(_ret);

%>