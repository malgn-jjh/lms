<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%@ page import="eu.bitwalker.useragentutils.*" %><%

ch = m.rs("ch", "board");
String mode = m.rs("mode", "html");

//객체
UserAgent ua = new UserAgent(request.getHeader("User-Agent"));

//변수
String[] deviceTypes = {
	"computer=>PC", "dmr=>디지털 미디어 플레이어", "game_console=>게임콘솔"
	, "mobile=>모바일 기기", "tablet=>태블릿 PC", "unknown=>알 수 없음", "wearable=>웨어러블 기기"
};

//정보
DataSet info = new DataSet();
info.addRow();
info.put("os_nm", ua.getOperatingSystem().getName());
info.put("device_type", ua.getOperatingSystem().getDeviceType().getName());
info.put("device_type_conv", m.getItem(info.s("device_type").toLowerCase(), deviceTypes));
info.put("browser_nm", ua.getBrowser().getName());
try { info.put("browser_version", ua.getBrowserVersion().getVersion()); }
catch(NullPointerException e) { info.put("browser_version", "버전 정보 없음"); }

if("json".equals(mode)) {
	out.print(Json.encode(info.getRow()));
} else {
	//출력
	p.setLayout(ch);
	p.setBody("main.checkspec");
	p.setVar(info);
	p.display();
}

%>