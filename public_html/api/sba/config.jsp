<%@page import="com.initech.eam.api.NXNLSAPI"%>
<%@page import="com.initech.eam.smartenforcer.SECode"%>
<%@page import="java.util.Vector"%>
<%@page import="com.initech.eam.nls.CookieManager"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.initech.eam.api.NXContext"%>
<%@ page import="malgnsoft.util.*" %>
<%!
/**[INISAFE NEXESS JAVA AGENT]**********************************************************************
* �����ý��� ���� ���� (���� ȯ�濡 �°� ����)
***************************************************************************************************/


/***[SERVICE CONFIGURATION]***********************************************************************/
	private String SERVICE_NAME = "sba";
	private String SERVER_URL 	= "http://academy.sba.kr";
	private String SERVER_PORT = "80";
	private String ASCP_URL = SERVER_URL + ":" + SERVER_PORT + "/api/sba/login_exec.jsp";
	
	//Custom Login Url
	//private String custom_url = SERVER_URL + ":" + SERVER_PORT + "/agent/sso/loginFormPageCoustom.jsp";
	private String custom_url = "";
/*************************************************************************************************/


/***[SSO CONFIGURATION]**]***********************************************************************/
	private String NLS_URL 		 = "http://nsso.sba.seoul.kr";
	private String NLS_PORT 	 = "8090";
	//private String NLS_LOGIN_URL = NLS_URL + ":" + NLS_PORT + "/nls3/clientLogin.jsp";
	private String NLS_LOGIN_URL = NLS_URL + ":" + NLS_PORT + "/nls3/cookieLogin.jsp";
	//private String NLS_LOGOUT_URL= NLS_URL + ":" + NLS_PORT + "/nls3/NCLogout.jsp";
	private String NLS_ERROR_URL = NLS_URL + ":" + NLS_PORT + "/nls3/error.jsp";
	private static String ND_URL = "http://nsso.sba.seoul.kr:5480";
	//private static String ND_URL2 = "http://ndtest.initech.com:5481";

	private static Vector PROVIDER_LIST = new Vector();

	private static final int COOKIE_SESSTION_TIME_OUT = 3000000;

	// ���� Ÿ�� (ID/PW ��� : 1, ������ : 3)
	private String TOA = "1";
	private String SSO_DOMAIN = ".sba.seoul.kr";

	private static final int timeout = 15000;
	private static NXContext context = null;
	static{
		List<String> serverurlList = new ArrayList<String>();
		serverurlList.add(ND_URL);

		context = new NXContext(serverurlList,timeout);
		CookieManager.setEncStatus(true);
		
		//NLS3 web.xml�� CookiePadding ���� ���ƾ� �Ѵ�. �ȱ׷� ���� ���ϳ�
		//InitechEamUID +"_V42" .... ���·� ��� ������
		SECode.setCookiePadding("_V42");
	}

	// ���� SSO ID ��ȸ
	public String getSsoId(HttpServletRequest request) {
		String sso_id = null;
		CookieManager.setEncStatus(true);
		sso_id = CookieManager.getCookieValue(SECode.USER_ID, request);
		//sso_id = CookieManager.getCookieValue("InitechEamUID_V42", request);
		return sso_id;
	}
	// ���� SSO �α��������� �̵�
	public void goLoginPage(HttpServletResponse response)throws Exception {
		CookieManager.addCookie(SECode.USER_URL, ASCP_URL, SSO_DOMAIN, response);
		CookieManager.addCookie(SECode.R_TOA, TOA, SSO_DOMAIN, response);
		
	       //��ü �α����� �Ұ�� �α��� ������ Setting
	    if(custom_url.equals(""))
	   	{
	    	//CookieManager.addCookie("CLP", "", SSO_DOMAIN, response);
	    }else{
	    	CookieManager.addCookie("CLP", custom_url , SSO_DOMAIN, response);
	    }
		
		response.sendRedirect(NLS_LOGIN_URL);
	}

	// �������� ������ üũ �ϱ� ���Ͽ� ���Ǵ� API
	public String getEamSessionCheckAndAgentVaild(HttpServletRequest request,HttpServletResponse response){
		String retCode = "";
		try {
			retCode = CookieManager.verifyNexessCookieAndAgentVaild(request, response, 10, COOKIE_SESSTION_TIME_OUT, PROVIDER_LIST, SERVER_URL, context);
		} catch(NullPointerException npe) {
			Malgn.errorLog("NullPointerException : " + npe.getMessage(), npe);
		} catch(Exception e) {
			Malgn.errorLog("Exception : " + e.getMessage(), e);
		}
		return retCode;
	}
	
	
	// �������� ������ üũ �ϱ� ���Ͽ� ���Ǵ� API(Agent ���� ���� �Լ�, �������)
	//@deprecated
	public String getEamSessionCheck(HttpServletRequest request,HttpServletResponse response){
		String retCode = "";
		try {
			retCode = CookieManager.verifyNexessCookie(request, response, 10, COOKIE_SESSTION_TIME_OUT,PROVIDER_LIST);
		} catch(NullPointerException npe) {
			Malgn.errorLog("NullPointerException : " + npe.getMessage(), npe);
		} catch(Exception e) {
			Malgn.errorLog("Exception : " + e.getMessage(), e);
		}
		return retCode;
	}
	
	
	//ND API�� ����ؼ� ��Ű�����ϴ°�(���� ǥ�ؿ����� ������, �ٵ� �ص� �Ǳ�� ��)
	public String getEamSessionCheck2(HttpServletRequest request,HttpServletResponse response)
	{
		String retCode = "";
		try {
			NXNLSAPI nxNLSAPI = new NXNLSAPI(context);
			retCode = nxNLSAPI.readNexessCookie(request, response, 10, COOKIE_SESSTION_TIME_OUT);
		} catch(NullPointerException npe) {
			Malgn.errorLog("NullPointerException : " + npe.getMessage(), npe);
		} catch(Exception e) {
			Malgn.errorLog("Exception : " + e.getMessage(), e);
		}
		return retCode;
	}

	// SSO ���������� URL
	public void goErrorPage(HttpServletResponse response, int error_code)throws Exception {
		CookieManager.removeNexessCookie(SSO_DOMAIN, response);
		CookieManager.addCookie(SECode.USER_URL, ASCP_URL, SSO_DOMAIN, response);
		response.sendRedirect(NLS_ERROR_URL + "?errorCode=" + error_code);
	}

%>
