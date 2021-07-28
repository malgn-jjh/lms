<%@ page contentType="text/html; charset=utf-8" %><%@ page import="java.security.*" %>
<%@ page import="java.io.UnsupportedEncodingException" %>
<%@ include file="/init.jsp" %><%

//로그
m.log("eximbay_noti", m.reqMap("").toString());

//PG에서 보냈는지 IP로 체크 
String addr = request.getRemoteAddr().substring(0, 11);
if(!"112.175.138".equals(addr) && !"119.205.195".equals(addr) && !"115.91.52.2".equals(addr)) {
	out.print("rescode=1000&resmsg=invalid_ip_address"); m.log("payletter_noti", "FAIL1000-" + addr); return;
}

//객체
OrderDao order = new OrderDao(); order.setMessage(_message);
OrderItemDao orderItem = new OrderItemDao(siteId);
PaymentDao payment = new PaymentDao();

MailDao mail = new MailDao();
SmsTemplateDao smsTemplate = new SmsTemplateDao(siteId);

UserDao user = new UserDao();

//폼입력
int oid = m.ri("ref");
String transid = m.rs("transid"); //tid
String secretKey = siteinfo.s("pg_key"); //가맹점 secretkey
String rescode = m.rs("rescode"); //0000 : 정상 
String resmsg = m.rs("resmsg"); //결제 결과 메세지
String cmid = m.rs("mid");
String fgkey = m.rs("fgkey"); //파라미터 유효성 검증키 값
String sortingParams = ""; //파라미터 정렬 관련
String newFgkey = ""; //응답 받은 파라미터 검증 fgkey

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
	out.print("rescode=1001&resmsg=no_essential_data"); m.log("eximbay_noti", "FAIL1001-" + addr); return;
}

//rescode=0000 일때 fgkey 확인
if("0000".equals(rescode)) {
	sortingParams = makeAllParam(reqTemp);
	newFgkey = encryptSHA256(secretKey + "?" + sortingParams);
	//fgkey 검증 실패 시 에러 처리
	if(!fgkey.equals(newFgkey)) {
		rescode = "ERROR";
		resmsg = "Invalid transaction";
		out.print("rescode=1002&resmsg=invalid_transaction_fgkey"); m.log("eximbay_noti", "FAIL1002-" + addr); return;
	}
} else {
	out.print("rescode=1003&resmsg=invalid_rescode"); m.log("eximbay_noti", "FAIL1003-" + addr); return;
}

if(!"0000".equals(rescode)) {
	out.print("rescode=1004&resmsg=invalid_rescode_2"); m.log("eximbay_noti", "FAIL1004-" + addr); return;
}

//변수
boolean isDBOK = true;
boolean isWait = !"".equals(m.rs("status")) && !"Sale".equals(m.rs("status")); //molpay등 status가 return되는 특정 결제수단용. 이외는 즉시결제완료처리, 타결제수단 bankAccount와 같음
int paymentId = 0;

//정보-주문
DataSet info = order.find("id = " + oid);
if(!info.next()) { out.print("rescode=2000&resmsg=cannot_find_order_info"); m.log("eximbay_noti", "FAIL2000-" + addr); return; }

//정보-회원
DataSet uinfo = user.find("id = " + info.i("user_id") + " AND site_id = " + siteId + " AND status = 1");
if(!uinfo.next()) { out.print("rescode=2001&resmsg=cannot_find_user_info"); m.log("eximbay_noti", "FAIL2001-" + addr); return; }

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
	payment.item("respcode", rescode + (isWait ? "_r" : ""));
	payment.item("respmsg", resmsg + m.rs("status"));
	payment.item("amount", m.rs("amt"));
	payment.item("buyer", uinfo.s("user_nm"));
	payment.item("buyeremail", m.rs("email"));
	payment.item("productinfo", info.s("order_nm"));
	payment.item("paydate", sysNow); //승인날짜
	//payment.item("financename", pginfo); //은행명
	payment.item("reg_date", sysNow);
	if(!payment.insert()) { out.print("rescode=3000&resmsg=cannot_insert_payment_info"); m.log("eximbay_noti", "FAIL3000-" + addr); return; }
}

//갱신-주문
if(-99 == info.i("status")) {
	order.item("pay_date", sysNow);
	order.item("status", isWait ? 2 : 1);
	if(!order.update("id = " + oid + " AND status = -99")) { out.print("rescode=3001&resmsg=cannot_insert_payment_info"); m.log("eximbay_noti", "FAIL3001-" + addr); return; }
} else if(2 == info.i("status") && !isWait) {
	order.item("pay_date", sysNow);
	order.item("status", 1);
	if(!order.update("id = " + oid + " AND status = -99")) { out.print("rescode=3002&resmsg=cannot_insert_payment_info"); m.log("eximbay_noti", "FAIL3002-" + addr); return; }
}

//갱신-주문항목
if(-99 == info.i("status")) {
	orderItem.item("order_id", oid);
	orderItem.item("status", isWait ? 2 : 1);
	if(!orderItem.update("id IN (" + info.s("items") + ")")) { out.print("rescode=3003&resmsg=cannot_insert_payment_info"); m.log("eximbay_noti", "FAIL3003-" + addr); return; }
} else if(2 == info.i("status") && !isWait) {
	orderItem.item("order_id", oid);
	orderItem.item("status", 1);
	if(!orderItem.update("id IN (" + info.s("items") + ")")) { out.print("rescode=3004&resmsg=cannot_insert_payment_info"); m.log("eximbay_noti", "FAIL3004-" + addr); return; }
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
	if(!order.confirmDeposit("" + oid, siteinfo)) { out.print("rescode=4000&resmsg=cannot_insert_payment_info"); m.log("eximbay_noti", "FAIL4000-" + addr); return; }
}

out.print("rescode=0000&resmsg=Success");

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
        }
		catch(NoSuchAlgorithmException nsae){
			System.out.println("[encryptSHA256]NoSuchAlgorithmException : " + nsae.getMessage());
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
		//System.out.println("[makeAllParam]sorting : "+reqParam.toString());

		return reqParam.toString();
	}
	//null 체크 함수
	public String checkNull(Object obj){
		if(obj == null) return "";
		else return (String)obj;
	}
%>