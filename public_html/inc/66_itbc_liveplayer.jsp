<%@ page contentType="text/html; charset=utf-8" %><%@ page import="eu.bitwalker.useragentutils.*" %><%@ include file="/init.jsp" %><%

//제한-동양생명
if(siteId != 66 && siteId != 1) return;

//객체
WebtvLiveDao webtvLive = new WebtvLiveDao();
LessonDao lesson = new LessonDao();

//목록
//webtvLive.d(out);
DataSet info = webtvLive.query(
    " SELECT a.live_nm, a.lesson_id, l.* "
    + " FROM " + webtvLive.table + " a "
    + " INNER JOIN " + lesson.table + " l ON a.lesson_id = l.id AND l.status != -1 "
    + " WHERE a.site_id = " + siteId + " AND a.status != -1 "
//	+ " WHERE a.site_id = " + siteId + " AND a.start_date <= '" + now + "' AND a.end_date >= '" + now + "' AND a.status = 1 "
//	+ (1 > userId ? " AND a.login_yn = 'N' " : "")
    , 1
);
if(!info.next()) { m.jsErrClose(_message.get("alert.lesson.nodata")); return; }

info.put("lesson_nm_conv", m.cutString(info.s("lesson_nm"), 40));
info.put("total_time", info.i("total_time") * 60);

//라이브모바일
if(m.isMobile()) {
    m.redirect("https://cdn-live.itbc.tv/tylive/tylivestream/playlist.m3u8");
    return;
}

String fileType = "m3u8";
boolean ie8 = false;

UserAgent ua = new UserAgent(request.getHeader("User-Agent"));
String browser = ua.getBrowser().getName();
String version = ua.getBrowserVersion().getMajorVersion();
if(browser.indexOf("Explorer") > 0) {
    int ver = m.parseInt(version);
    if(ver <= 8) ie8 = true;
}

//출력
p.setLayout(null);
p.setBody("inc.66_itbc_liveplayer");
p.setVar(info);
p.setVar("user_id", userId);
p.setVar("file_type", fileType);
p.setVar("ie8", ie8);
p.display();

%>