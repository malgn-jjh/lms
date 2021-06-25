<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../init.jsp" %><%

//폼입력
String tpl = m.rs("tpl", "66_itbc_webtv");
boolean isLatest = 1 == m.ri("is_latest");
int count = m.ri("cnt") > 0 ? m.ri("cnt") : 4;

//객체
WebtvDao webtv = new WebtvDao();
WebtvTargetDao webtvTarget = new WebtvTargetDao();
LmCategoryDao category = new LmCategoryDao("webtv");
LmCategoryTargetDao categoryTarget = new LmCategoryTargetDao();

FileDao file = new FileDao();
LessonDao lesson = new LessonDao();
KollusDao kollus = new KollusDao(siteId);

//변수
String now = m.time("yyyyMMddHHmmss");
String where = " a.site_id = " + siteId + " AND a.status = 1 AND a.display_yn = 'Y' "
	+ " AND a.open_date <= '" + now + "' "
	+ " AND a.recomm_yn = 'Y' "
	+ " AND (a.target_yn = 'N' " //시청대상그룹
	+ (!"".equals(userGroups)
		? " OR EXISTS (SELECT 1 FROM " + webtvTarget.table + " WHERE webtv_id = a.id AND group_id IN (" + userGroups + ")) "
		: "")
	+ " ) "
	+ " AND (c.target_yn = 'N' " //카테고리시청대상그룹
	+ (!"".equals(userGroups)
		? " OR EXISTS (SELECT 1 FROM " + categoryTarget.table + " WHERE category_id = c.id AND group_id IN (" + userGroups + ")) "
		: "")
	+ " ) "
	+ (1 > userId ? " AND c.login_yn = 'N' " : "");

//마지막방송일자
String latestDate = m.cutString(
	webtv.getOne(
		" SELECT a.open_date "
		+ " FROM " + webtv.table + " a "
		+ " INNER JOIN " + category.table + " c ON a.category_id = c.id AND c.status = 1 "
		+ " WHERE " + where
		+ " ORDER BY a.open_date DESC, a.id DESC "
	), 8, ""
);

//목록
//webtv.d(out);
DataSet list = webtv.query(
	" SELECT a.*, c.parent_id, l.lesson_type, l.start_url "
	+ " FROM " + webtv.table + " a "
	+ " INNER JOIN " + lesson.table + " l ON a.lesson_id = l.id AND l.status = 1 "
	+ " INNER JOIN " + category.table + " c ON a.category_id = c.id AND c.status = 1 "
	+ " WHERE " + where + " AND open_date " + (!isLatest ? " NOT " : "") + " LIKE '" + latestDate + "%' "
	+ " ORDER BY a.open_date DESC, a.id " + (!isLatest ? " DESC " : " ASC ")
	, count
);

while(list.next()) {
//	if(list.b("__first")) latestDate = list.s("open_date");
//	list.put("display_block", latestDate.equals(list.s("open_date")));

	list.put("webtv_nm_conv", m.cutString(list.s("webtv_nm"), 70));
	
	list.put("subtitle_conv", m.nl2br(list.s("subtitle")));
	list.put("length_conv", m.strpad(list.s("length_min"), 2, "0") + ":" + m.strpad(list.s("length_sec"), 2, "0"));

	if(!"".equals(list.s("webtv_file"))) {
		list.put("webtv_file_url", m.getUploadUrl(list.s("webtv_file")));
	} else if("".equals(list.s("webtv_file_url"))) {
		list.put("webtv_file_url", "/common/images/default/noimage_webtv.jpg");
	}

	list.put("content_width_conv", list.i("content_width") + 20);
	list.put("content_height_conv", list.i("content_height") + 23);
	
	list.put("open_date_conv", m.time("yyyy.MM.dd HH:mm", list.s("open_date")));
	list.put("start_url_conv", "05".equals(list.s("lesson_type")) ? ("http://v.kr.kollus.com/s?key=" + kollus.getMediaToken(list.s("start_url"), "" + userId)) : list.s("start_url"));
		
	//동영상경로보안
	if("01".equals(list.s("lesson_type")) || "03".equals(list.s("lesson_type"))) {
		int lid = list.i("lesson_id");
		int unixTime = m.getUnixTime();
		String key = lid + "|" + userId + "|" + unixTime;
		String startUrl = "/main/video.jsp?ek=" + m.encrypt(key) + "&lid=" + lid + "&uid=" + userId + "&ut=" + unixTime;
		list.put("start_url", startUrl);
		list.put("start_url_conv", "/player/webtvplayer.jsp?lid=" + lid + "&ek=" + m.encrypt(lid + "|0|" + m.time("yyyyMMdd")));
	}

}

//출력
p.setLayout(null);
p.setBody("inc." + tpl);

p.setLoop("list", list);
p.setVar("is_latest", isLatest);
p.setVar("slide_block", 1 < list.size());
p.display();

%>