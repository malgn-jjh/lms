<%@ page language="java" contentType="text/html;charset=EUC-KR" %>
<%@ include file="./config.jsp" %>
<%

	String uurl = null;


	//http://nlstest.initech.com:8090/agent/sso/login_exec.jsp : �� ���������� ȣ���ؾ� �ȴ�.
	//1.SSO ID ����

	String sso_id = getSsoId(request);
	out.println("<pre>");
	out.println("*================== [login_exec.jsp]  sso_id = "+sso_id);
	out.println(SECode.USER_ID);

	if(true) return;

	if (sso_id == null || sso_id.equals("")) {
		//�α��� �������� �̵��ϴ� ������ �־�� ��.
		// goLoginPage(response); 
		//
		out.println("sso_id is null");
		return;
	} else {

		//4.��Ű ��ȿ�� Ȯ�� :0(����)
		String retCode = getEamSessionCheck2(request,response);
		out.println("*================== [retCode]  retCode = " + retCode);
	
		if(!retCode.equals("0")){
			out.println(retCode);
			//goErrorPage(response, Integer.parseInt(retCode));
			return;
		}
		//
		//5.�����ý��ۿ� ���� ����� ���̵� �������� ����
		String EAM_ID = (String)session.getAttribute("SSO_ID");
		if(EAM_ID == null || EAM_ID.equals("")) {
			session.setAttribute("SSO_ID", sso_id);
		}
		out.println("SSO ���� ����!!");

		//6.�����ý��� ������ ȣ��(���� ������ �Ǵ� ���������� ����)  --> �����ý��ۿ� �°� URL ����!
		response.sendRedirect("app01.jsp");
		//out.println("��������");
	}

	out.print("End");
%>
