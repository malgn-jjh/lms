<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%

//기본키
String qq = f.get("qq");
String ts = f.get("ts");
String sno = f.get("sno");

m.log("sap", "qq=" + qq + ";ts=" + ts + ";sno=" + sno);

String ret = m.replace(m.exec("/home/talkit/bin/sap_api.sh " + qq + " " + ts + " " + sno), "\n", "");
if(!ret.startsWith("[")) {
	m.p();
	m.p(ret); return;
}

DataSet rs = Json.decode(ret);
if(!rs.next()) {
	m.p(ret); return;
}

String companyIDX = m.urlencode(rs.s("companyIDX"));
String userID = rs.s("userID");
String enterpriseCourseKey = rs.s("enterpriseCourseKey");
String courseStartDate = m.urlencode(rs.s("courseStartDate"));

m.redirect("https://www.sapelearning.co.kr/api/sap/login.jsp?companyIDX=" + companyIDX + "&userID=" + userID + "&enterpriseCourseKey=" + enterpriseCourseKey + "&courseStartDate=" + courseStartDate);

%>