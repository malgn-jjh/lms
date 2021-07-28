<%@ page import="java.io.UnsupportedEncodingException" %>
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//기본키
String dir = m.rs("dir", "/");
if("C".equals(userKind) && !dir.startsWith("/" + userId)) dir = "/" + userId;


//폼체크
f.addElement("folder_nm", null, "hname:'폴더명', required:'Y', pattern:'^[a-zA-Z]{1}[a-zA-Z0-9]{1,19}$', errmsg:'영문으로 시작하는 2-20자로 영문, 숫자 조합으로 입력하세요.'");

//등록
if(m.isPost() && f.validate()) {

	//목록
	FTPClient ftp = new FTPClient();
	try{
		ftp.setControlEncoding("utf-8");
		ftp.connect(ftpHost, ftpPort);
		ftp.enterLocalPassiveMode();
		ftp.login(ftpId, ftpPw);
		if(!"".equals(dir)) ftp.changeWorkingDirectory(dir);

		boolean ret = ftp.makeDirectory(f.get("folder_nm"));

		ftp.logout();
		ftp.disconnect();

		if(!ret) {
			m.jsError("폴더를 생성하는 중 오류가 발생했습니다.");
			return;
		}
	} catch(UnsupportedEncodingException uee) {
		m.log("ftp", uee.toString());
		m.jsError("폴더를 생성하는 중 오류가 발생했습니다. " + uee.toString());
		return;
	} catch(Exception e) {
		m.log("ftp", e.toString());
		m.jsError("폴더를 생성하는 중 오류가 발생했습니다. " + e.toString());
		return;
	}

	//이동
	m.jsReplace("ftp_list.jsp?" + m.qs(), "parent");
	m.js("parent.CloseLayer();");
	return;
}

//출력
p.setLayout("poplayer");
p.setBody("webftp.ftp_folder_insert");
p.setVar("p_title", "폴더생성");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setVar("dir", dir);

p.display();

%>