<%@ page contentType="text/html; charset=euc-kr" %><%@ include file="../init.jsp" %>
<%
	// 결과값
	String sResultCd  = request.getParameter("allat_result_cd");
	String sResultMsg = request.getParameter("allat_result_msg");
	String sEncData   = request.getParameter("allat_enc_data");

	m.log("allat", "sResultCd:" + sResultCd + "\nsResultMsg:" + sResultMsg + "\nsEncData:" + sEncData);
	// 결과값 Return
	out.println("<script>");
	out.println("if(window.opener != undefined) {");
	out.println("	opener.result_submit('" + sResultCd + "','" + sResultMsg + "','" + sEncData + "');");
	out.println("	window.close();");
	out.println("} else {");
	out.println("	parent.result_submit('" + sResultCd + "','" + sResultMsg + "','" + sEncData + "');");
	out.println("}");
	out.println("</script>");
%>
