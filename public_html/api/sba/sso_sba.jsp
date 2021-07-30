<%@ page contentType="text/html; charset=utf-8" %><%@ include file="/init.jsp" %><%@page import="com.initech.eam.api.NXNLSAPI,com.initech.eam.smartenforcer.SECode,java.util.Vector,com.initech.eam.nls.CookieManager,java.util.ArrayList,java.util.List,com.initech.eam.api.NXContext"%>
<%@ page import="javax.crypto.BadPaddingException" %>
<%!
/**[INISAFE NEXESS JAVA AGENT]**********************************************************************
* 업무시스템 설정 사항 (업무 환경에 맞게 변경)
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

	// 인증 타입 (ID/PW 방식 : 1, 인증서 : 3)
	private String TOA = "1";
	private String SSO_DOMAIN = ".sba.seoul.kr";

	private static final int timeout = 15000;
	private static NXContext context = null;
	static{
		List<String> serverurlList = new ArrayList<String>();
		serverurlList.add(ND_URL);

		context = new NXContext(serverurlList,timeout);
		CookieManager.setEncStatus(true);
		
		//NLS3 web.xml의 CookiePadding 값과 같아야 한다. 안그럼 검증 페일남
		//InitechEamUID +"_V42" .... 형태로 쿠명 생성됨
		SECode.setCookiePadding("_V42");
	}

	// 통합 SSO ID 조회
	public String getSsoId(HttpServletRequest request) {
		String sso_id = null;
		CookieManager.setEncStatus(true);
		sso_id = CookieManager.getCookieValue(SECode.USER_ID, request);
		//sso_id = CookieManager.getCookieValue("InitechEamUID_V42", request);
		return sso_id;
	}
	// 통합 SSO 로그인페이지 이동
	public void goLoginPage(HttpServletResponse response)throws Exception {
		CookieManager.addCookie(SECode.USER_URL, ASCP_URL, SSO_DOMAIN, response);
		CookieManager.addCookie(SECode.R_TOA, TOA, SSO_DOMAIN, response);
		
	       //자체 로그인을 할경우 로그인 페이지 Setting
	    if(custom_url.equals(""))
	   	{
	    	//CookieManager.addCookie("CLP", "", SSO_DOMAIN, response);
	    }else{
	    	CookieManager.addCookie("CLP", custom_url , SSO_DOMAIN, response);
	    }
		
		response.sendRedirect(NLS_LOGIN_URL);
	}

	// 통합인증 세션을 체크 하기 위하여 사용되는 API
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
	
	
	// 통합인증 세션을 체크 하기 위하여 사용되는 API(Agent 인증 없는 함수, 사용자제)
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
	
	
	//ND API를 사용해서 쿠키검증하는것(현재 표준에서는 사용안함, 근데 해도 되기는 함)
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

	// SSO 에러페이지 URL
	public void goErrorPage(HttpServletResponse response, int error_code)throws Exception {
		CookieManager.removeNexessCookie(SSO_DOMAIN, response);
		CookieManager.addCookie(SECode.USER_URL, ASCP_URL, SSO_DOMAIN, response);
		response.sendRedirect(NLS_ERROR_URL + "?errorCode=" + error_code);
	}

%><%

	//변수
	String ssoId = getSsoId(request);
	String loginUrl = "https://www.sba.seoul.kr/kr/sbme01s9";

	//처리
	if(ssoId == null || ssoId.equals("")) {
		//이동-SBA로그인
		//goLoginPage(response);
		m.jsReplace(loginUrl);
		return;

	} else {

		//4.쿠키 유효성 확인 :0(정상)
		/*
		String retCode = getEamSessionCheck2(request,response);
		out.println("*================== [retCode]  retCode = " + retCode);
	
		if(!retCode.equals("0")){
			out.println(retCode);
			//goErrorPage(response, Integer.parseInt(retCode));
			return;
		}
		*/

		//변수-SSL
		String sslDomain = request.getServerName().indexOf(".malgn.co.kr") > 0 ? "ssl.malgn.co.kr" : "ssl.malgnlms.com";
		boolean isSSL = "https".equals(request.getScheme()) && sslDomain.equals(request.getServerName()) && !"".equals(f.get("domain"));
		if(siteinfo.b("ssl_yn")) {
			sslDomain = siteinfo.s("domain");
			isSSL = false;
		}
		
		//폼입력
		String returl = m.rs("returl");
		String paramId = m.rs("uid");
		String paramNm = m.rs("unm");
		if("".equals(paramId) || "".equals(paramNm)) {
			//m.jsAlert("로그인 정보가 없습니다. 다시 로그인 해 주세요.");
			m.jsReplace(loginUrl);
			return;
		}
		paramId = m.replace(paramId, " ", "+");
		paramNm = m.replace(paramNm, " ", "+");

		//복호화
		try {
			paramId = CookieManager.decryptWithSEED(paramId);
			paramNm = CookieManager.decryptWithSEED(paramNm);
		} catch(BadPaddingException bpe) {
			System.out.println("BadPaddingException : " + bpe.getMessage());
			m.jsAlert("로그인 정보에 오류가 있습니다. 다시 로그인 해 주세요. [1]");
			m.jsReplace(loginUrl);
			return;
		} catch(Exception e) {
			m.jsAlert("로그인 정보에 오류가 있습니다. 다시 로그인 해 주세요. [1]");
			m.jsReplace(loginUrl);
			return;
		}

		if(!paramId.equals(ssoId)) {
			m.jsAlert("로그인 정보에 오류가 있습니다. 다시 로그인 해 주세요. [2]");
			m.jsReplace(loginUrl);
			return;
		}

		//객체
		UserDao user = new UserDao();

		//정보
		DataSet info = user.find("login_id = 'sba_" + ssoId + "' AND site_id = " + siteId + "");
		if(info.next()) {
			//세션
			mSession.put("login_method", "oauth-sba");
			mSession.save();

			//로그인
			String accessToken = m.md5(m.getUniqId());
			String ek = m.encrypt(accessToken + sslDomain + m.time("yyyyMMdd"));
			user.item("access_token", accessToken);
			if(!user.update("id = " + info.i("id") + " AND site_id = " + siteId)) {
				m.jsErrClose(_message.get("alert.member.error_find"));
				return;
			}

			//이동-로그인
			m.jsReplace("../../" + (!m.isMobile() ? "member" : "mobile") + "/login.jsp?returl=" + returl + "&access_token=" + accessToken + "&ek=" + ek);
			m.js("window.close();");
			return;
		}

		//해시맵
		HashMap<String, String> oauthMap = new HashMap<String, String>();
		oauthMap.put("vendor", "sba");
		oauthMap.put("id", ssoId);
		oauthMap.put("name", paramNm);

		//세션
		mSession.put("join_method", "oauth");
		mSession.put("join_vendor", "sba");
		mSession.put("join_vendor_nm", "SBA");
		mSession.put("join_data", Json.encode(oauthMap));
		mSession.save();

		//이동-가입
		m.jsReplace("../../member/agreement.jsp?mode=oauth");
	}

%>