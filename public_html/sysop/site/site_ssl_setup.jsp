<%@ page contentType="text/html; charset=utf-8" %><%@ page import="java.util.*,java.io.*,dao.*,malgnsoft.db.*,malgnsoft.util.*,java.net.InetAddress" %><%

//객체
Malgn m = new Malgn(request, response, out);

Form f = new Form("form1");
try { f.setRequest(request); }
catch(Exception ex) { out.print("Overflow file size. - " + ex.getMessage()); return; }

//제한-IP
if(!"115.91.52.203".equals(request.getRemoteAddr()) && !"115.91.52.204".equals(request.getRemoteAddr() )&& !"125.128.232.145".equals(request.getRemoteAddr())) {
	return;
}

//기본키
int sid = m.ri("sid");
String mode = m.rs("mode", "NORMAL");
String key = m.rs("k");
String ek = m.rs("ek");
if(1 > sid) { out.print("올바른 접근이 아닙니다. [1]"); return; }
if(!ek.equals(m.encrypt("SSL_SETTING_" + key + "_PCC_" + m.time("yyyyMMdd")))) { out.print("올바른 접근이 아닙니다. [2]"); return; }

//제한-POST
//if(!m.isPost()) { out.print("올바른 접근이 아닙니다. [3]"); return; }

//객체
SiteDao site = new SiteDao();

//정보
DataSet info = site.find("id = " + sid);
if(!info.next()) { m.jsAlert("해당 정보가 없습니다."); return; }

//처리
String path = "/root/setup_ssl.sh " + info.s("ftp_id") + " " + info.s("domain");
if("TEST".equals(mode)) path = "/etc/init.d/httpd configtest";
else if("GRACE".equals(mode)) path = "/etc/init.d/httpd graceful";
else if("RELEASE".equals(mode)) path = "/root/rsync_httpd.sh";

InetAddress addr = InetAddress.getLocalHost();
String hostname = addr.getHostName();
StringBuffer sb = new StringBuffer();

//sb.append("<pre>\n");
//sb.append(hostname + "<br>");
sb.append(info.s("site_nm") + "\n");
sb.append("MODE : " + mode + "\n");

try {
	String line;
	Process proc = Runtime.getRuntime().exec(path);
	BufferedReader input = new BufferedReader(new InputStreamReader(proc.getInputStream()));

	while((line = input.readLine()) != null) {
		sb.append(line + "\n");
	}

	input.close();
} catch(RuntimeException re) {
	sb.append(re.getMessage());
} catch(Exception ex) {
	sb.append(ex.getMessage());
}

//출력
//sb.append("</pre>");
out.print("<pre>" + sb.toString() + "</pre>");

//텔레그램통지
//boolean isDevServer = -1 < request.getServerName().indexOf("lms.malgn.co.kr");
boolean isDevServer = 1 == info.i("id");
sb.insert(0, "<em>[SSL 세팅완료" + (isDevServer ? " - 테스트" : "") + "]</em>\n[" + info.i("id") + "] " + info.s("ftp_id") + " 사이트에 SSL 세팅이 완료되어 확인이 필요합니다.\n\n<em>[세팅결과]</em>\n");

Http http = new Http("https://api.telegram.org/bot603185314:AAH8HPsY4doAhtiMiO7JwqKSnRnSqVL3r5M/sendMessage");
//http.setDebug(out);
//http.setParam("chat_id", isDevServer ? "422230577" : "-244863179"); //personal
http.setParam("chat_id", "-244863179");
http.setParam("parse_mode", "HTML");
http.setParam("text", sb.toString());

String ret = http.send("GET");

%>