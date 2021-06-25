<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
int id = m.ri("id");
if(id == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }

//객체
OrderDao order = new OrderDao();
OrderItemDao orderItem = new OrderItemDao();
PaymentDao payment = new PaymentDao();
CourseDao course = new CourseDao();
CourseUserDao courseUser = new CourseUserDao();
RefundDao refund = new RefundDao();
DeliveryDao delivery = new DeliveryDao();

//변수
String today = m.time("yyyyMMdd");
//정보
DataSet info = order.query(
	" SELECT a.*, d.delivery_nm, d.link "
	+ " FROM " + order.table + " a "
	+ " LEFT JOIN " + delivery.table + " d ON d.id = a.delivery_id "
	+ " WHERE a.id = " + id + " AND a.user_id = " + userId + " AND a.status IN (1,2,3,4,-2) "
);
if(!info.next()) { m.jsError("해당 정보가 없습니다."); return; }

info.put("price_conv", m.nf(info.i("price")));
info.put("disc_price_conv", m.nf(info.i("disc_price")));
info.put("pay_price_conv", m.nf(info.i("pay_price")));
info.put(info.s("paymethod") + "_block", true);
info.put("cancel_block", info.i("status") == 2); //취소가능
info.put("canceled", info.i("status") == -2); //취소됨
info.put("delete_block", info.i("status") == 2 && ("03".equals(info.s("paymethod")) || "90".equals(info.s("paymethod"))));
	
if(info.i("status") >= 3 || info.i("delivery_status") == 0) {
	info.put("status_conv", m.getItem(info.s("status"), order.statusList));
	info.put("delivery_block", false);
} else {
	info.put("status_conv", m.getItem(info.s("delivery_status"), order.deliveryStatusList));
	info.put("delivery_block", info.i("delivery_status") >= 3);
}

if("del".equals(m.rs("mode"))) {
	if(2 == info.i("status") && ("03".equals(info.s("paymethod")) || "90".equals(info.s("paymethod")))) {
		order.item("status", -2);
		order.item("ord_memo", info.s("ord_memo") + "<br>[" + m.time("yyyy.MM.dd HH:mm") + "] 사용자 요청에 의한 무통장입금 취소");
		order.update("id = " + id);

		orderItem.item("status", -2);
		orderItem.update("order_id = " + id);

		courseUser.item("change_date", m.time("yyyyMMddHHmmss"));
		courseUser.item("status", -4);
		courseUser.update("order_id = " + id);

		//order.execute("DELETE FROM " + order.table + " WHERE id = " + id);
		//orderItem.execute("DELETE FROM " + orderItem.table + " WHERE order_id = " + id);
		//courseUser.execute("DELETE FROM " + courseUser.table + " WHERE order_id = " + id);

		m.jsAlert("무통장입금이 취소되었습니다.");
		m.jsReplace("order_list.jsp", "parent");
		return;
	}
}

//환불신청
if("refund".equals(m.rs("mode"))) {
	DataSet oiinfo = orderItem.query(
		"SELECT a.* "
		+ ", cu.id cuid, cu.start_date cu_sdate, cu.end_date cu_edate, cu.course_id "
		+ ", r.id rid, r.status r_status "
		+ " FROM " + orderItem.table + " a "
		+ " LEFT JOIN " + courseUser.table + " cu ON cu.order_item_id = a.id AND cu.status IN (1,3) AND cu.close_yn = 'N' "
		+ " LEFT JOIN " + refund.table + " r ON r.order_item_id = a.id "
		+ " WHERE a.id = " + m.ri("iid") + " AND a.order_id = " + id + " "
		+ " AND a.user_id = " + userId + " AND a.status = 1 "
	);
	if(!oiinfo.next()) { m.jsError("해당 결제정보가 없습니다."); return; }
	//if(oiinfo.i("rid") != 0 || oiinfo.i("cuid") == 0 || 0 < m.diffDate("D", oiinfo.s("cu_edate"), today)) {
	if(oiinfo.i("rid") != 0 || oiinfo.i("product_id") == 0
		|| ("course".equals(oiinfo.s("product_type")) && 0 < m.diffDate("D", oiinfo.s("cu_edate"), today))) {
		m.jsError("올바른 접근이 아닙니다.");
		return;
	}

	//환불 등록
	refund.item("site_id", siteId);
	refund.item("user_id", userId);
	refund.item("order_id", oiinfo.s("order_id"));
	refund.item("order_item_id", oiinfo.i("id"));
	refund.item("refund_type", 3);
	refund.item("req_memo", "");
	refund.item("paymethod", info.s("paymethod"));
	refund.item("reg_date", m.time("yyyyMMddHHmmss"));
	refund.item("status", 1);
	
	if("course".equals(oiinfo.s("product_type"))) {
		refund.item("course_id", oiinfo.s("course_id"));
		refund.item("course_user_id", oiinfo.i("cuid"));
	} else {
		refund.item("course_id", 0);
		refund.item("course_user_id", 0);
	}
	if(!refund.insert()) { m.jsAlert("등록하는 중 오류가 발생했습니다."); return; }

	//아이템상태변경
	orderItem.item("status", 3);
	if(!orderItem.update("id = " + m.ri("iid") + "")) { m.jsAlert("수정하는 중 오류가 발생했습니다."); return; }

	m.jsAlert("환불신청이 완료되었습니다.");
	
	m.jsReplace("order_view.jsp?" + m.qs("iid, mode"));
	return;
}

//목록-항목
DataSet list = orderItem.query(
	"SELECT a.* "
	+ ", c.id course_id, c.request_sdate, c.request_edate, c.step, c.study_sdate, c.study_edate, c.auto_approve_yn "
	+ ", c.class_member, c.credit "
	+ ", cu.id cuid, cu.start_date cu_sdate, cu.end_date cu_edate"
	+ ", r.id rid, r.status r_status"
	+ ", o.delivery_status"
	+ " FROM " + orderItem.table + " a "
	+ " LEFT JOIN " + course.table + " c ON a.product_type = 'course' AND a.product_id = c.id "
	+ " LEFT JOIN " + courseUser.table + " cu ON "
		+ " a.product_type = 'course' AND a.id = cu.order_item_id AND cu.package_id = 0 AND cu.status IN (1,3) AND cu.close_yn = 'N' "
	+ " LEFT JOIN " + refund.table + " r ON a.product_type = 'course' AND a.id = r.order_item_id"
	+ " LEFT JOIN " + order.table + " o ON a.order_id = o.id"
	+ " WHERE a.user_id = " + userId + " AND a.order_id = " + id + " AND a.status IN (1,2,3,-2) "
	+ " ORDER BY a.id ASC "
);
while(list.next()) {
	list.put("course_block", false);
	list.put("use_block", true);
	list.put("refund_block", false);
	list.put("price_conv", m.nf(list.i("price")));
	list.put("disc_price_conv", m.nf(list.i("disc_price")));
	list.put("coupon_price_conv", m.nf(list.i("coupon_price")));
	list.put("pay_price_conv", m.nf(list.i("pay_price")));
	list.put("product_type_conv", m.getItem(list.s("product_type"), orderItem.ptypes));
	list.put("reg_date_conv", m.time("yyyy.MM.dd", list.s("reg_date")));
	list.put("status_conv", m.getItem(list.s("status"), orderItem.statusList));
	list.put("refund_conv", list.i("r_status") == 0 || list.i("r_status") == 1 ? "-" : m.getItem(list.s("r_status"), refund.statusList));
	list.put("refund_price_conv", list.i("status") == -2 && list.i("refund_price") > 0 ? " (" + m.nf(list.i("refund_price")) + "원)" :"");

	if("course".equals(list.s("product_type"))) {
		list.put("course_block", true);
		list.put("refund_block",
			list.i("rid") == 0 && list.i("status") == 1 && list.i("cuid") > 0
			&& 0 >= m.diffDate("D", list.s("cu_edate"), today)
		);
	} else if("book".equals(list.s("product_type"))) {
		list.put("course_block", false);
		list.put("refund_block",
			list.i("rid") == 0 && list.i("status") == 1
			&& (list.i("delivery_status") == 0 || list.i("delivery_status") == 4)
		);
	} else {
		list.put("course_block", false);
		list.put("refund_block", false);
	}
}

//결제정보
DataSet pinfo = new DataSet();
if("90".equals(info.s("paymethod")) || "99".equals(info.s("paymethod"))) {
	p.setVar("pg_block", false);
} else {
	p.setVar("pg_block", true);
	pinfo = payment.find("oid = " + id);
	if(!pinfo.next()) { m.jsError("해당 정보가 없습니다."); return; }
	pinfo.put("paydate_conv", m.time("yyyy.MM.dd HH:mm:ss", pinfo.s("paydate")));
	pinfo.put("cardinstallmonth_conv", pinfo.i("cardinstallmonth") == 0 ? "일시불" : pinfo.i("cardinstallmonth") + "개월");
	pinfo.put("amount_conv", m.nf(pinfo.i("amount")));
	pinfo.put("authdata", m.encrypt(pinfo.s("mid") + pinfo.s("tid") + siteinfo.s("pg_key")));
}

//출력
p.setLayout(ch);
p.setBody("mypage.freepass_view");
p.setVar("query", m.qs("mode, iid"));
p.setVar("list_query", m.qs("id, mode, iid"));

p.setLoop("list", list);
p.setVar("quantity", list.size());
p.setVar("order", info);
p.setVar("payment", pinfo);
p.setVar("ek", m.encrypt(id + userId + "__LMS2014"));
p.setVar("free_block", "99".equals(info.s("paymethod")));

p.display();

%>