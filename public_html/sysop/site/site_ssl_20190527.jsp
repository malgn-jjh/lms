<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

String domain = siteinfo.s("domain").replace("www.", "");
String dcvDir = "/home/" + siteinfo.s("ftp_id") + "/public_html/.well-known/pki-validation";

if(m.isPost()) {

	if("dcv".equals(f.get("mode"))) {
		File folder = new File(dcvDir);
		if(!folder.exists()) folder.mkdirs();
		
		m.writeFile(dcvDir + "/" + f.get("dcv_file"), f.get("dcv_text"));
		if(new File(dcvDir + "/" + f.get("dcv_file")).exists()) {
			m.jsAlert("DCV 파일이 생성되었습니다.");
		} else {
			m.jsAlert("DCV 파일생성에 실패하였습니다.");
		}

	} else if("cert".equals(f.get("mode"))) {
		m.jsAlert("인증서 파일이 업로드 되었습니다.");

	} else {
		m.jsAlert("잘못된 접근입니다.");
	}
	return;
}

//출력
p.setLayout(ch);
p.setBody("site.site_ssl");
p.setVar("domain", domain);
p.display();

%>