<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

String resultCode = m.rs("resultcode");
String resultMsg 	= m.rs("resultmessage");
int oid = m.ri("webordernumber");

if("".equals(resultCode) || 1 > oid) return;

OrderDao order = new OrderDao();
OrderItemDao orderItem = new OrderItemDao(siteId);
PaymentDao payment = new PaymentDao();

CouponDao coupon = new CouponDao();
CouponUserDao couponUser = new CouponUserDao();

MailDao mail = new MailDao();
SmsTemplateDao smsTemplate = new SmsTemplateDao(siteId);

String payUrl = "/mypage/payment.jsp?oek=" + order.getOrderEk(oid, userId);

if("00".equals(resultCode)) {

	DataSet info = order.find("id = " + oid + " AND status = -99");
	if(!info.next()) {
		m.jsAlert("주문정보를 찾을 수 없습니다.");
		m.jsReplace(payUrl);
		return;
	}

	boolean isDBOK = true;
	int newPaymentId = payment.getSequence();

	payment.item("id", newPaymentId);
	payment.item("site_id", siteId);
	payment.item("pg_nm", "inicis_pp");
	payment.item("reg_date", m.time("yyyyMMddHHmmss"));

	payment.item("oid", m.rs("webordernumber")); //주문번호
	payment.item("mid", m.rs("mid"));
	payment.item("tid", m.rs("tid")); //거래번호
	payment.item("paytype", m.rs("paymethod")); //결제방법(지불수단)
	payment.item("respcode", m.rs("resultcode"));
	payment.item("respmsg", m.rs("resultmessage"));
	payment.item("amount", m.rs("pricewon"));
	payment.item("buyer", m.rs("buyername"));
	payment.item("buyeremail", m.rs("buyeremail"));
	payment.item("buyerphone", m.rs("buyertel"));
	payment.item("productinfo", m.rs("goodName"));

	payment.item("paydate", m.rs("authdate") + m.rs("authtime")); //승인날짜
	payment.item("timestamp", m.rs("authdate") + m.rs("authtime")); //승인시간
	if(!payment.insert()) isDBOK = false;

	if(isDBOK) {
		order.item("pay_date", m.time());
		order.item("status", 1);
		if(!order.update("id = " + oid + " AND status = -99")) isDBOK = false;
	}

	//갱신-주문항목
	if(isDBOK) {
		orderItem.item("order_id", oid);
		orderItem.item("status", 1);
		if(!orderItem.update("id IN (" + info.s("items") + ")")) isDBOK = false;		
	}

	if(isDBOK == false) {
		//결제취소처리
		//http.setUrl(netCancel);
		//ret = http.send("POST");

		//m.log("inipay", ret);
		//resultMap = Json.decode(ret);
		//resultMap.next();

		//자동취소결과 업데이트
		payment.clear();
		payment.item("cancel_code", m.rs("resultcode"));
		payment.item("cancel_msg", m.rs("resultmsg"));
		payment.update("id = " + newPaymentId + "");

		//주문정보 삭제
		order.item("status", -2);
		order.update("id = " + oid);

		m.jsAlert("처리하는 중 오류가 발생하여 결제가 자동취소 되었습니다.(DB ERROR)");
		//m.jsReplace(payUrl);
		return;
	}

	//주문처리
	order.process(oid);

	//발송
	info.put("pay_price_conv", m.nf(info.i("pay_price")));
	info.put("order_date_conv", m.time("yyyy년 MM월 dd일", info.s("order_date")));
	info.put("paymethod_conv", m.getItem(info.s("paymethod"), order.methods));
	
	DataSet items = orderItem.find("id IN (" + info.s("items") + ")");
	while(items.next()) {
		items.put("quantity_conv", m.nf(items.i("quantity")));
		items.put("pay_price_conv", m.nf(items.i("pay_price")));
	}

	p.setVar("order", info);
	p.setLoop("order_items", items);
	mail.send(siteinfo, uinfo, "payment", p);
	smsTemplate.sendSms(siteinfo, uinfo, "payment", p, "P");

	//정상처리시 결과페이지로
	String eKey = m.encrypt(oid + userId + "__LMS2014");
	m.jsReplace("payment_complete.jsp?ek=" + eKey + "&oid=" + m.encode(""+oid), "parent");
	return;

} else {
	m.jsAlert(resultMsg + " (" + resultCode + ")");
	m.jsReplace(payUrl);
	//m.jsReplace(payUrl);
	return;
}

%>