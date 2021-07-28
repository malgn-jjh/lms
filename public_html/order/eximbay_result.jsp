<%@ page contentType="text/html; charset=utf-8" %><%@ page import="java.security.*" %>
<%@ page import="java.io.UnsupportedEncodingException" %>
<%@ include file="init.jsp" %><%

//객체
OrderDao order = new OrderDao(); order.setMessage(_message);
OrderItemDao orderItem = new OrderItemDao(siteId);
PaymentDao payment = new PaymentDao();

MailDao mail = new MailDao();
SmsTemplateDao smsTemplate = new SmsTemplateDao(siteId);

//기본키
int oid = m.ri("ref");
String transid = m.rs("transid"); //tid
String secretKey = siteinfo.s("pg_key"); //가맹점 secretkey
String rescode = m.rs("rescode"); //0000 : 정상 
String resmsg = m.rs("resmsg"); //결제 결과 메세지
String cmid = m.rs("mid");
String fgkey = m.rs("fgkey"); //파라미터 유효성 검증키 값
String sortingParams = ""; //파라미터 정렬 관련
String newFgkey = ""; //응답 받은 파라미터 검증 fgkey
String payUrl = "/order/payment.jsp?oek=" + order.getOrderEk(oid, userId);

//처리-fgkey
HashMap<String, String> reqTemp = new HashMap<String, String>();
Enumeration param1 = request.getParameterNames();
while(param1.hasMoreElements()){
	String name = (String)param1.nextElement();
	String value = request.getParameter(name);
	//System.out.println(name + ":" + value);	
	reqTemp.put(name, value);

}

//제한-기본키
if(1 > oid || "".equals(transid) || "".equals(rescode) || "".equals(resmsg) || "".equals(fgkey)) {
	m.jsAlert(_message.get("alert.common.required_key")); m.jsReplace(payUrl); return;
}

//rescode=0000 일때 fgkey 확인
if("0000".equals(rescode)) {
	sortingParams = makeAllParam(reqTemp);
	newFgkey = encryptSHA256(secretKey + "?" + sortingParams);
	//fgkey 검증 실패 시 에러 처리
	if(!fgkey.equals(newFgkey)) {
		rescode = "ERROR";
		resmsg = "Invalid transaction";
		m.jsAlert(_message.get("alert.payment.error") + "\\n\\nERROR CODE : fgkey\\nERROR MESSAGE : fgkey mismatch"); m.jsReplace(payUrl); return;
	}
} else {
	m.jsAlert(_message.get("alert.payment.error") + "\\n\\nERROR CODE : " + rescode + "\\nERROR MESSAGE : " + resmsg); m.jsReplace(payUrl); return; 
}

if(!"0000".equals(rescode)) {
	m.jsAlert(_message.get("alert.payment.error") + "\\n\\nERROR CODE : " + rescode + "\\nERROR MESSAGE : " + resmsg); m.jsReplace(payUrl); return;
}

//변수
boolean isDBOK = true;
boolean isWait = !"".equals(m.rs("status")) && !"Sale".equals(m.rs("status")); //molpay등 status가 return되는 특정 결제수단용. 이외는 즉시결제완료처리, 타결제수단 bankAccount와 같음
int paymentId = 0;

//정보-주문
DataSet info = order.find("id = ? AND user_id = ? AND site_id = ? AND status IN (-99, 1, 2)", new Integer[] {oid, userId, siteId});
if(!info.next()) { m.jsAlert(_message.get("alert.order.nodata")); m.jsReplace(payUrl); return; }

//등록-결제
DataSet pinfo = payment.find("site_id = ? AND tid = ? AND oid = ? AND respcode= '0000'", new String[] {siteId + "", transid, oid + ""});
if(pinfo.next()) {
	paymentId = pinfo.i("id");
} else {
	paymentId = payment.getSequence();
	payment.item("id", paymentId);
	payment.item("site_id", siteId);
	payment.item("pg_nm", "eximbay");
	payment.item("reg_date", m.time("yyyyMMddHHmmss"));
	payment.item("oid", oid); //주문번호
	payment.item("mid", cmid);
	payment.item("tid", m.rs("transid")); //거래번호
	payment.item("paytype", m.rs("paymethod")); //결제방법(지불수단)
	payment.item("respcode", rescode + (isWait ? "_r" : "")); //입금대기도 0000으로 들어와서 추가
	payment.item("respmsg", resmsg + m.rs("status"));
	payment.item("amount", m.rs("amt"));
	payment.item("buyer", uinfo.s("user_nm"));
	payment.item("buyeremail", m.rs("email"));
	payment.item("productinfo", info.s("order_nm"));
	payment.item("paydate", sysNow); //승인날짜
	//payment.item("financename", pginfo); //은행명
	payment.item("reg_date", sysNow);
	if(!payment.insert()) isDBOK = false;
}

//갱신-주문
if(isDBOK) {
	if(-99 == info.i("status")) {
		order.item("pay_date", sysNow);
		order.item("status", isWait ? 2 : 1);
		if(!order.update("id = " + oid + " AND status = -99")) isDBOK = false;
	} else if(2 == info.i("status") && !isWait) {
		order.item("pay_date", sysNow);
		order.item("status", 1);
		if(!order.update("id = " + oid + " AND status = -99")) isDBOK = false;
	}
}

//갱신-주문항목
if(isDBOK) {
	if(-99 == info.i("status")) {
		orderItem.item("order_id", oid);
		orderItem.item("status", isWait ? 2 : 1);
		if(!orderItem.update("id IN (" + info.s("items") + ")")) isDBOK = false;
	} else if(2 == info.i("status") && !isWait) {
		orderItem.item("order_id", oid);
		orderItem.item("status", 1);
		if(!orderItem.update("id IN (" + info.s("items") + ")")) isDBOK = false;
	}
}

if(isDBOK == false) {
	m.jsAlert(_message.get("alert.order.error_wrapup"));
	m.jsReplace(payUrl);
	return;
}

//주문처리
if(-99 == info.i("status")) {
	order.process(oid);

	//발송
	info.put("pay_price_conv", m.nf(info.i("pay_price")));
	info.put("order_date_conv", m.time(_message.get("format.date.dot"), info.s("order_date")));
	info.put("paymethod_conv", m.getItem(info.s("paymethod"), order.methods));

	DataSet items = orderItem.find("id IN (" + info.s("items") + ")");
	while(items.next()) {
		items.put("quantity_conv", m.nf(items.i("quantity")));
		items.put("pay_price_conv", m.nf(items.i("pay_price")));
	}

	p.setVar("order", info);
	p.setLoop("order_items", items);

	if(isWait) {
		p.setVar("payment", payment.find("id = " + paymentId + " AND oid = " + oid));
		mail.send(siteinfo, uinfo, "account", p);
		smsTemplate.sendSms(siteinfo, uinfo, "account", p);
	} else {
		mail.send(siteinfo, uinfo, "payment", p);
		smsTemplate.sendSms(siteinfo, uinfo, "payment", p, "P");
	}
} else if(2 == info.i("status") && !isWait) {
	if(!order.confirmDeposit("" + oid, siteinfo)) {
		m.jsAlert(_message.get("alert.order.error_wrapup"));
		m.jsReplace(payUrl);
		return;
	}
}

//정상처리시 결과페이지로
String eKey = m.encrypt(oid + userId + "__LMS2014");
m.jsReplace("payment_complete.jsp?ek=" + eKey + "&oid=" + m.encode(""+oid), "parent");
return;

%><%!
//SHA256 해쉬 함수
public String encryptSHA256(String value){
	try{
		byte[] plainText = value.getBytes("UTF-8");
		byte[] hashValue = null;
		
		MessageDigest md = MessageDigest.getInstance("SHA-256");
		hashValue = md.digest(plainText);

		return toHexString(hashValue);
	}
	catch(UnsupportedEncodingException uee){
		System.out.println("[encryptSHA256]UnsupportedEncodingException : " + uee.getMessage());
		//System.out.println("[encryptSHA256]Exception : " + e);
	}
	catch(NoSuchAlgorithmException nsae){
		System.out.println("[encryptSHA256]NoSuchAlgorithmException : " + nsae.getMessage());
		//System.out.println("[encryptSHA256]Exception : " + e);
	}
	catch(Exception e){
		System.out.println("[encryptSHA256]Exception : " + e.getMessage());
		//System.out.println("[encryptSHA256]Exception : " + e);
	}
	
	return "";
}
//16진수 변환 함수
public String toHexString(byte[] letter){
	StringBuffer sbHex = new StringBuffer();
	for (int j = 0; j <letter.length; j++) {             
		String hexValue = Integer.toHexString((int)letter[j] & 0xff); 
		
		if(hexValue.length() == 1) sbHex.append("0");
		sbHex.append(hexValue.toUpperCase());
	} 
	
	return sbHex.toString();
}

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