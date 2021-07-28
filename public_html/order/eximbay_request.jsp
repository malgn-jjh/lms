<%@ page contentType="text/html; charset=utf-8" %><%@ page import="java.security.*" %><%@ include file="init.jsp" %><%

/*
TEST MID : 1849705C64
TEST KEY : 289F40E6640124B2628640168C3C5464
*/

//객체
OrderDao order = new OrderDao();

//변수
String secretKey = siteinfo.s("pg_key");
String reqURL = siteinfo.b("pg_test_yn") ? "https://secureapi.test.eximbay.com/Gateway/BasicProcessor.krp" : "https://secureapi.eximbay.com/Gateway/BasicProcessor.krp";
String fgkey = ""; //fgkey검증키 관련
String sortingParams = ""; //파라미터 정렬 관련

String payUrl = "/order/payment.jsp?oek=" + order.getOrderEk(m.ri("ref"), userId);

//fgkey 검증키 생성
Enumeration param1 = request.getParameterNames();
HashMap<String, String> reqTemp = new HashMap<String, String>();
while(param1.hasMoreElements()){
	String name = (String)param1.nextElement();
	String value = request.getParameter(name);
	//System.out.println(name + ":" + value);	
	reqTemp.put(name, value);

}
sortingParams = makeAllParam(reqTemp);
fgkey = m.sha256(secretKey + "?" + sortingParams);
%>
<!DOCTYPE html>
<html>
<head>
<title>{{SYS_TITLE}}</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=EDGE" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, target-densitydpi=medium-dpi" />
<link rel="stylesheet" type="text/css" href="/common/css/skin2.css" />
<style type="text/css">
.pay_warning { text-align:center; font-size:24px; line-height:40px; padding-top:100px; }
</style>
</head>
<body onload="document.regForm.submit(); //openwin();">

<div class="pay_warning">
	<p>Payment is in progress securely.</p>
	<p>Do not refresh the window or call it multiple times.</p>
	<button type="button" class="button gray" onclick="location.href = '<%=payUrl%>';">&lt; Back to Order Form</button>
</div>

<form name="regForm" method="post" action="<%=reqURL%>">
<input type="hidden" name="fgkey" value="<%=fgkey%>" />	<!--필수 값-->
<%
Enumeration param = request.getParameterNames();
while(param.hasMoreElements()) {
	String name = (String)param.nextElement();
	String value = request.getParameter(name);
%>
<input type="hidden" name="<%=name%>" value="<%=value%>">
<% } %>
</form>
<script>
function openwin() {
	//window.open('about:blank','eximbaypop','width=1000,height=800');
	document.regForm.submit();
}
</script>
</body>
</html>
<%!
//파라미터 정렬
public String makeAllParam(HashMap<String, String> reqTemp){

	int listSize = 1;
	StringBuffer reqParam = new StringBuffer();

	List<String> reqList = new ArrayList<String>();


	reqList = new ArrayList<String>(reqTemp.keySet());
	Collections.sort(reqList);

	for (String str : reqList) {
		String key = str;
		String value = (String) reqTemp.get(str);

		if ("fgkey".equals(key))  {
			listSize++;
			continue;
		}
		if(reqList.size() ==  listSize)
			reqParam.append(key).append("=").append(value);
		else
			reqParam.append(key).append("=").append(value).append("&");
		listSize++;
	}
	//System.out.println("[makeReqAllParam]sorting : "+reqParam.toString());

	//System.out.println("[makeReqAllParam]return : "+reqParam.toString());
	return reqParam.toString();
}
%>