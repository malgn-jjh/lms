<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//CHECKED-2014.07.14

//접근권한
if(!Menu.accessible(111, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//객체
OrderDao order = new OrderDao();
OrderItemDao orderItem = new OrderItemDao();
UserDao user = new UserDao();
DeliveryDao delivery = new DeliveryDao();

//처리
if("delivery".equals(m.rs("mode"))) {
	//기본키
	String[] idx = m.rs("idx").split(",");
	String status = m.rs("status");
	if(idx == null || "".equals(status)) { m.jsAlert("기본키는 반드시 지정해야 합니다."); return; }

	//변수
	int cnt = order.findCount("status >= 0 AND delivery_status != 1 AND id IN (" + m.join(",", idx) + ")");

	//수정
	order.item("delivery_status", status);
	if(!order.update("status >= 0 AND delivery_status != 1 AND id IN (" + m.join(",", idx) + ")")) {
		m.jsAlert("배송상태를 수정하는 중 오류가 발생했습니다."); return;
	}

	//이동
	m.jsAlert("주문 " + m.nf(cnt) + " 건의 배송상태가 수정되었습니다.");
	m.jsReplace("delivery_list.jsp?" + m.qs("mode,status,idx"), "parent");
	return;
}

//폼체크
f.addElement("s_order_sdate", null, null);
f.addElement("s_order_edate", null, null);
f.addElement("s_pay_sdate", null, null);
f.addElement("s_pay_edate", null, null);
f.addElement("s_status", null, null);
f.addElement("s_delivery_status", null, null);
f.addElement("s_delivery_type", null, null);
f.addElement("s_escrow_yn", null, null);
f.addElement("s_field", null, null);
f.addElement("s_keyword", null, null);

//목록
ListManager lm = new ListManager();
//lm.d(out);
lm.setRequest(request);
lm.setListNum("excel".equals(f.get("mode2")) ? 20000 : 20);
lm.setTable(
	order.table + " a "
	+ " INNER JOIN " + user.table + " u ON a.user_id = u.id AND u.site_id = " + siteId + " "
	+ " LEFT JOIN " + delivery.table + " d ON a.delivery_id = d.id "
);
lm.setFields(
	"a.*, u.login_id, u.user_nm, d.delivery_nm, d.link"
	//+ " LEFT JOIN (SELECT oid, escrowyn, MAX(reg_date) FROM " + payment.table + " WHERE respcode = '0000' GROUP BY oid) p ON a.id = p.oid "
	//+ ", (SELECT escrowyn FROM " + payment.table + " WHERE respcode = '0000' AND oid = a.id ORDER BY reg_date DESC LIMIT 1) escrow_yn "
);
lm.addWhere("a.status NOT IN (-1, -99)");
lm.addWhere("a.site_id = " + siteId + "");
lm.addWhere("EXISTS (SELECT 1 FROM " + orderItem.table + " WHERE order_id = a.id AND product_type = 'book')");
lm.addSearch("a.order_date", m.time("yyyyMMdd", f.get("s_order_sdate")), ">=");
lm.addSearch("a.order_date", m.time("yyyyMMdd", f.get("s_order_edate")), "<=");
lm.addSearch("a.pay_date", m.time("yyyyMMdd", f.get("s_pay_sdate")), ">=");
lm.addSearch("a.pay_date", m.time("yyyyMMdd", f.get("s_pay_edate")), "<=");
lm.addSearch("a.status", f.get("s_status"));
lm.addSearch("a.delivery_status", f.get("s_delivery_status"));
lm.addSearch("a.delivery_type", f.get("s_delivery_type"));
lm.addSearch("a.escrow_yn", f.get("s_escrow_yn"));
if(!"".equals(f.get("s_field"))) lm.addSearch(f.get("s_field"), f.get("s_keyword"), "LIKE");
else if("".equals(f.get("s_field")) && !"".equals(f.get("s_keyword"))) {
	lm.addSearch("a.id, a.order_nm, a.ord_nm, u.login_id", f.get("s_keyword"), "LIKE");
}
lm.setOrderBy(!"".equals(f.get("ord")) ? f.get("ord") : "a.id DESC");

//포멧팅
DataSet list = lm.getDataSet();
while(list.next()) {
	list.put("status_conv", m.getItem(list.s("status"), order.statusList));
	list.put("delivery_status_conv", m.getItem(list.s("delivery_status"), order.deliveryStatusList));
	list.put("order_date_conv", m.time("yyyy.MM.dd", list.s("order_date")));
	list.put("reg_date_conv", m.time("yyyy.MM.dd", list.s("reg_date")));
	list.put("pay_date_conv", m.time("yyyy.MM.dd", list.s("pay_date")));
	list.put("pay_date_diff", (!"".equals(list.s("pay_date")) ? m.diffDate("D", list.s("pay_date"), m.time("yyyyMMddHHmmss")) : "-"));

	list.put("delivery_block", list.i("delivery_status") >= 3);
	list.put("wait_block", list.i("status") == 1 && (list.i("delivery_status") == 0 || list.i("delivery_status") == 2));
	list.put("cancel_block", list.i("status") < 0);

	try {
		list.put("ord_mobile", !"".equals(list.s("ord_mobile")) ? SimpleAES.decrypt(list.s("ord_mobile")) : "-" );
	} catch(Exception e) {
		list.put("ord_mobile", "-");
	}
	try {
		list.put("ord_phone", !"".equals(list.s("ord_phone")) ? SimpleAES.decrypt(list.s("ord_phone")) : "-" );
	} catch(Exception e) {
		list.put("ord_phone", "-");
	}
}

//엑셀
if("excel".equals(m.rs("mode2"))) {
	ExcelWriter ex = new ExcelWriter(response, "배송관리(" + m.time("yyyy-MM-dd") + ").xls");
	ex.setData(list, new String[] { "__ord=>No", "id=>주문아이디", "order_date_conv=>주문일", "user_nm=>회원명", "login_id=>회원아이디", "order_nm=>주문명", "pay_date_conv=>실결제일", "ord_nm=>주문자명", "ord_reci=>수령자명", "ord_zipcode=>우편번호", "ord_address=>지번주소", "ord_new_address=>도로명주소", "ord_addr_dtl=>상세주소", "ord_email=>주문자이메일", "ord_phone=>주문자연락처", "ord_mobile=>주문자휴대폰", "ord_memo=>주문자요청사항", "reg_date_conv=>등록일", "status_conv=>결제상태", "delivery_status_conv=>배송상태", "delivery_nm=>택배사", "delivery_no=>운송장번호" }, "배송관리(" + m.time("yyyy-MM-dd") + ")");
	ex.write();
	return;
}

//출력
p.setBody("order.delivery_list_20160907");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setLoop("list", list);
p.setVar("list_total", lm.getTotalString());
p.setVar("pagebar", lm.getPaging());

p.setLoop("status_list", m.arr2loop(order.statusList));
p.setLoop("delivery_status_list", m.arr2loop(order.deliveryStatusList));
p.setLoop("delivery_type_list", m.arr2loop(order.deliveryTypeList2));
p.display();

%>