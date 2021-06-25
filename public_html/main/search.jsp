<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
String keyword = m.replace(m.rs("s_keyword").trim().replaceAll("[^가-힣a-zA-Z0-9\\s]", ""), " ", "|");
while(-1 < keyword.indexOf("||")) keyword = m.replace(keyword, "||", "|");
if(keyword.startsWith("|")) keyword = keyword.substring(1);
if(keyword.endsWith("|")) keyword = keyword.substring(0, keyword.length() - 1);
if("".equals(keyword)) { m.jsError(_message.get("alert.common.enter_keyword")); return; }
if(100 < keyword.length()) keyword = m.cutString(keyword, 100, "");

//객체
CourseDao course = new CourseDao();
PostDao post = new PostDao();
ClPostDao clPost = new ClPostDao();
BoardDao board = new BoardDao();
TutorDao tutor = new TutorDao();
CourseTutorDao courseTutor = new CourseTutorDao();
CourseTargetDao courseTarget = new CourseTargetDao();
WebtvDao webtv = new WebtvDao();
WebtvTargetDao webtvTarget = new WebtvTargetDao();
LmCategoryDao category = new LmCategoryDao();
LmCategoryTargetDao categoryTarget = new LmCategoryTargetDao();
SearchLogDao searchLog = new SearchLogDao(request);

//로그
if(!searchLog.addLog(siteId, userId, m.rs("s_keyword"))) { }

//폼체크
Form f2 = new Form("form_search");
f2.setRequest(request);
f2.addElement("s_keyword", null, null);

//변수
String today = m.time("yyyyMMdd");

//정보-과정
DataSet courses = new DataSet();
DataSet coursesAll = course.query(
	" SELECT a.*, c.category_nm "
	+ " FROM " + course.table + " a "
	+ " LEFT JOIN " + category.table + " c ON a.category_id = c.id "
	+ " WHERE a.course_nm REGEXP ? AND a.site_id = " + siteId + " AND a.display_yn = 'Y' AND a.close_yn = 'N' AND a.status = 1 "
	+ " AND (a.target_yn = 'N'"
	+ (!"".equals(userGroups)
		? " OR EXISTS (SELECT 1 FROM " + courseTarget.table + " WHERE course_id = a.id AND group_id IN (" + userGroups + "))"
		: "")
	+ ")"
	+ " ORDER BY a.id desc "
	, new Object[] {keyword}
);
int courseTotal = coursesAll.size();
while(coursesAll.next()) {
	if(coursesAll.i("__ord") > 5) break;

	coursesAll.put("request_date", "-");
	if("R".equals(coursesAll.s("course_type"))) {
		coursesAll.put("is_regular", true);
		coursesAll.put("request_date", m.time(_message.get("format.date.dot"), coursesAll.s("request_sdate")) + " - " + m.time(_message.get("format.date.dot"), coursesAll.s("request_edate")));
		coursesAll.put("study_date", m.time(_message.get("format.date.dot"), coursesAll.s("study_sdate")) + " - " + m.time(_message.get("format.date.dot"), coursesAll.s("study_edate")));
		coursesAll.put("ready_block", 0 > m.diffDate("D", coursesAll.s("request_sdate"), today));
	} else if("A".equals(coursesAll.s("course_type"))) {
		coursesAll.put("is_regular", false);
		coursesAll.put("request_date", "상시");
		coursesAll.put("study_date", "상시");
		coursesAll.put("ready_block", false);
	}

	coursesAll.put("course_nm_conv", m.cutString(coursesAll.s("course_nm"), 48));
	
	coursesAll.put("subtitle_conv", m.nl2br(coursesAll.s("subtitle")));
	coursesAll.put("content_conv", m.cutString(m.stripTags(coursesAll.s("subtitle")), 120));
	//coursesAll.put("content_conv", !"".equals(coursesAll.s("subtitle_conv")) ? coursesAll.s("subtitle_conv") : m.cutString(m.stripTags(coursesAll.s("content1")), 120));

	if(!"".equals(coursesAll.s("course_file"))) {
		coursesAll.put("course_file_url", m.getUploadUrl(coursesAll.s("course_file")));
	} else {
		coursesAll.put("course_file_url", "/html/images/common/noimage_course.gif");
	}
	
	coursesAll.put("is_online", "N".equals(coursesAll.s("onoff_type")));
	coursesAll.put("is_offline", "F".equals(coursesAll.s("onoff_type")));
	coursesAll.put("is_blend", "B".equals(coursesAll.s("onoff_type")));
	coursesAll.put("is_package", "P".equals(coursesAll.s("onoff_type")));
	coursesAll.put("onoff_type_conv", m.getValue(coursesAll.s("onoff_type"), course.onoffPackageTypesMsg));

	coursesAll.put("tutor_nm", courseTutor.getTutorSummary(coursesAll.i("id")));

	courses.addRow(coursesAll.getRow());
}

//정보-방송
DataSet webtvs = new DataSet();
DataSet webtvsAll = webtv.query(
	" SELECT a.*, c.category_nm, IF('" + today + "' >= a.open_date, 'Y', 'N') is_open "
	+ " FROM " + webtv.table + " a "
	+ " INNER JOIN " + category.table + " c ON a.category_id = c.id AND c.status = 1 "
	+ " WHERE a.site_id = " + siteId + " AND a.display_yn = 'Y' AND a.status = 1 "
	+ " AND (a.webtv_nm REGEXP ? OR a.subtitle REGEXP ? OR a.content REGEXP ? OR a.keywords REGEXP ?) "
	+ " AND a.open_date <= '" + m.time("yyyyMMddHHmmss") + "'"
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
	+ " ORDER BY a.open_date desc, a.id desc "
	, new Object[] {keyword, keyword, keyword, keyword}
);
int webtvTotal = webtvsAll.size();
while(webtvsAll.next()) {
	if(webtvsAll.i("__ord") > 5) break;

	webtvsAll.put("webtv_nm_conv", m.cutString(webtvsAll.s("webtv_nm"), 70));
	
	webtvsAll.put("subtitle_conv", m.nl2br(webtvsAll.s("subtitle")));
	webtvsAll.put("length_conv", m.strrpad(webtvsAll.s("length_min"), 2, "0") + ":" + m.strrpad(webtvsAll.s("length_sec"), 2, "0"));

	if(!"".equals(webtvsAll.s("webtv_file"))) {
		webtvsAll.put("webtv_file_url", m.getUploadUrl(webtvsAll.s("webtv_file")));
	} else if("".equals(webtvsAll.s("webtv_file_url"))) {
		webtvsAll.put("webtv_file_url", "/common/images/default/noimage_webtv.jpg");
	}

	webtvsAll.put("content_width_conv", webtvsAll.i("content_width") + 20);
	webtvsAll.put("content_height_conv", webtvsAll.i("content_height") + 23);
	
	webtvsAll.put("hit_cnt_conv", m.nf(webtvsAll.i("hit_cnt")));
	webtvsAll.put("reg_date_conv", m.time(_message.get("format.datetime.dot"), webtvsAll.s("reg_date")));
	webtvsAll.put("open_date_conv", m.time(_message.get("format.datetime.dot"), webtvsAll.s("open_date")));

	webtvs.addRow(webtvsAll.getRow());
}

//정보-강사
DataSet tutors = new DataSet();
DataSet tutorsAll = course.query(
	" SELECT a.*, c.category_nm "
	+ " FROM " + course.table + " a "
	+ " LEFT JOIN " + category.table + " c ON a.category_id = c.id "
	+ " INNER JOIN " + courseTutor.table + " ct ON ct.course_id = a.id "
	+ " INNER JOIN " + tutor.table + " t ON t.user_id = ct.user_id AND t.status = 1 "
	+ " WHERE a.site_id = " + siteId + " AND a.display_yn = 'Y' AND a.close_yn = 'N' AND a.status = 1 "
	+ " AND t.tutor_nm REGEXP ? "
	+ " AND (a.target_yn = 'N'"
	+ (!"".equals(userGroups)
		? " OR EXISTS (SELECT 1 FROM " + courseTarget.table + " WHERE course_id = a.id AND group_id IN (" + userGroups + "))"
		: "")
	+ ")"
	+ " ORDER BY a.id desc "
	, new Object[] {keyword}
);
int tutorTotal = tutorsAll.size();
while(tutorsAll.next()) {
	if(tutorsAll.i("__ord") > 5) break;

	tutorsAll.put("request_date", "-");
	if("R".equals(tutorsAll.s("course_type"))) {
		tutorsAll.put("is_regular", true);
		tutorsAll.put("request_date", m.time(_message.get("format.date.dot"), tutorsAll.s("request_sdate")) + " - " + m.time(_message.get("format.date.dot"), tutorsAll.s("request_edate")));
		tutorsAll.put("study_date", m.time(_message.get("format.date.dot"), tutorsAll.s("study_sdate")) + " - " + m.time(_message.get("format.date.dot"), tutorsAll.s("study_edate")));
		tutorsAll.put("ready_block", 0 > m.diffDate("D", tutorsAll.s("request_sdate"), today));
	} else if("A".equals(tutorsAll.s("course_type"))) {
		tutorsAll.put("is_regular", false);
		tutorsAll.put("request_date", "상시");
		tutorsAll.put("study_date", "상시");
		tutorsAll.put("ready_block", false);
	}

	tutorsAll.put("course_nm_conv", m.cutString(tutorsAll.s("course_nm"), 48));
	
	tutorsAll.put("subtitle_conv", m.nl2br(tutorsAll.s("subtitle")));
	tutorsAll.put("content_conv", m.cutString(m.stripTags(tutorsAll.s("subtitle")), 120));
	//tutorsAll.put("content_conv", !"".equals(tutorsAll.s("subtitle_conv")) ? tutorsAll.s("subtitle_conv") : m.cutString(m.stripTags(tutorsAll.s("content1")), 120));

	if(!"".equals(tutorsAll.s("course_file"))) {
		tutorsAll.put("course_file_url", m.getUploadUrl(tutorsAll.s("course_file")));
	} else {
		tutorsAll.put("course_file_url", "/html/images/common/noimage_course.gif");
	}
	
	tutorsAll.put("is_online", "N".equals(tutorsAll.s("onoff_type")));
	tutorsAll.put("is_offline", "F".equals(tutorsAll.s("onoff_type")));
	tutorsAll.put("is_blend", "B".equals(tutorsAll.s("onoff_type")));
	tutorsAll.put("is_package", "P".equals(tutorsAll.s("onoff_type")));
	tutorsAll.put("onoff_type_conv", m.getValue(tutorsAll.s("onoff_type"), course.onoffPackageTypesMsg));

	tutorsAll.put("tutor_nm", courseTutor.getTutorSummary(tutorsAll.i("id")));

	tutors.addRow(tutorsAll.getRow());
}

//정보-게시물
DataSet posts = new DataSet();
DataSet postsAll = post.query(
	" SELECT a.*, b.board_nm, b.code, b.layout, b.comment_yn "
	+ " FROM " + post.table + " a "
	+ " INNER JOIN " + board.table + " b ON b.id = a.board_id AND b.site_id = " + siteId + " AND b.status = 1 "
		+ (userId > 0 ? " AND b.auth_list LIKE '%|U|%' " : " AND b.auth_list LIKE '%|0|%' ")
	+ " WHERE (a.subject REGEXP ? OR a.content REGEXP ?) "
	+ " AND a.site_id = " + siteId + " AND a.secret_yn = 'N' AND a.display_yn = 'Y' AND a.status = 1 AND a.depth = 'A' "
	+ " ORDER BY a.id desc "
	, new Object[] {keyword, keyword}
);
int postTotal = postsAll.size();
while(postsAll.next()) {
	if(postsAll.i("__ord") > 5) break;

	postsAll.put("subject_conv", m.cutString(postsAll.s("subject"), 80));
	postsAll.put("reg_date_conv", m.time(_message.get("format.date.dot"), postsAll.s("reg_date")));
	postsAll.put("hit_cnt_conv", m.nf(postsAll.i("hit_cnt")));
	postsAll.put("comment_conv", postsAll.b("comment_yn") && postsAll.i("comm_cnt") > 0 ? "(" + postsAll.i("comm_cnt") + ")" : "");

	posts.addRow(postsAll.getRow());
}

//변수
int searchTotal = tutorTotal + courseTotal + webtvTotal + postTotal;

//출력
p.setLayout("search");
p.setBody("main.search");
p.setVar("p_title", "통합");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("subject_query", m.qs("id,subject"));
p.setVar("form_script", f2.getScript());

p.setLoop("tutors", tutors);
p.setLoop("courses", courses);
p.setLoop("webtvs", webtvs);
p.setLoop("posts", posts);

//p.setVar("s_keyword", keyword.replaceAll("\\|", " "));
p.setVar("tutor_total", m.nf(tutorTotal));
p.setVar("course_total", m.nf(courseTotal));
p.setVar("webtv_total", m.nf(webtvTotal));
p.setVar("post_total", m.nf(postTotal));
p.setVar("search_total", m.nf(searchTotal));
p.setVar("no_result", 0 == searchTotal);
p.display();

%>