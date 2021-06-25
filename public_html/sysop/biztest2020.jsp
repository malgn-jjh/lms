<%@ page contentType="text/html; charset=utf-8" %><%@ page import="org.apache.tika.*" %><%@ include file="init.jsp" %><%

//20200327 과제파일 마이그레이션

//객체
Tika tika = new Tika();
SiteDao site = new SiteDao();
ClFileDao file = new ClFileDao();
HomeworkUserDao homeworkUser = new HomeworkUserDao();

//목록-사이트루트경로
Hashtable<String, String> siteDir = new Hashtable<String, String>();
DataSet sites = site.find("1 = 1");
while(sites.next()) siteDir.put(sites.s("id"), sites.s("doc_root"));

//목록-강의
DataSet hulist = homeworkUser.find("user_file IS NOT NULL AND user_file != ''");
int hutotal = hulist.size();
int i = 1;
m.p("총 갯수 : " + hutotal);
//포맷팅-강의
while(hulist.next()) {
	//사이트경로설정
	m.setDataDir((siteDir.containsKey(hulist.s("site_id")) ? siteDir.get(hulist.s("site_id")) : "/home/lms/public_html") + "/data");

	//변수
	String filename = hulist.s("user_file");
	String uploadpath = m.getUploadPath(filename);

	m.p("[■있음] " + (i++) + " / " + hutotal + "번째 - " + hulist.s("homework_id") + "_" + hulist.s("course_user_id") + " / site : " + hulist.s("site_id") + " / nm : " + hulist.s("subject") + " / file : <strong>" + filename + "</strong>");

	//파일존재여부
	File f1 = new File(uploadpath);
	if(!f1.exists()) {
		//삭제됨
		m.p("<div style='width:40px;float:left;'>&nbsp;</div>-> <span style='color:red;'>[■삭제] " + uploadpath + "</span>");
	} else {
		//존재함
		String mimeType = "";
		try { mimeType = tika.detect(f1); } 
		catch (Exception e) { }
		m.p("<div style='width:40px;float:left;'>&nbsp;</div>-> [□실존] " + uploadpath + " / size : " + f1.length() + " / mime : " + mimeType);
/*
		//파일정보등록
		int newId = file.getSequence();
		file.item("id", newId);
		file.item("site_id", hulist.s("site_id"));
		file.item("module", "homework_" + hulist.s("homework_id"));
		file.item("module_id", hulist.s("course_user_id"));
		file.item("main_yn", "N");
		file.item("file_nm", filename);
		file.item("filename", filename);
		file.item("realname", f1.getName());
		file.item("filesize", f1.length());
		file.item("filetype", mimeType);
		file.item("download_cnt", "0");
		file.item("reg_date", !"".equals(hulist.s("mod_date")) ? hulist.s("mod_date") : hulist.s("reg_date"));
		file.item("status", "1");

		if(file.insert()) {				
			m.p("<div style='width:80px;float:left;'>&nbsp;</div>-> [□등록성공] fid : " + newId + "");

			/ *
			lesson.item("lesson_file", "");
			if(lesson.update("id = " + hulist.s("id"))) {
				m.p("<div style='width:120px;float:left;'>&nbsp;</div>-> [□수정성공] lid : " + hulist.s("id") + "");
			} else { 
				m.p("<div style='width:120px;float:left;'>&nbsp;</div>-> <span style='color:red;'>[■수정실패] lid : " + hulist.s("id") + "</span>");
			}
			* /
		} else {
			m.p("<div style='width:80px;float:left;'>&nbsp;</div>-> <span style='color:red;'>[■등록실패] fid : " + newId + "</span>");
		}
*/
	}
}

%>