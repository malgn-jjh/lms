<%@ page contentType = "text/html;charset=utf-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.security.*" %>
<%@ page import="java.io.UnsupportedEncodingException" %>
<%@ page import="malgnsoft.util.*" %>

<%!
	//SHA256 해쉬 함수
	public String encryptSHA256(String value){
		try{
	        byte[] plainText = value.getBytes("UTF-8");
	        byte[] hashValue = null;
	        
	        MessageDigest md = MessageDigest.getInstance("SHA-256");
	        hashValue = md.digest(plainText);
   
	        return toHexString(hashValue);
        } catch(NoSuchAlgorithmException nsae){
			Malgn.errorLog("[encryptSHA256]NoSuchAlgorithmException : " + nsae.getMessage(), nsae);
		}catch(UnsupportedEncodingException uee){
			Malgn.errorLog("[encryptSHA256]UnsupportedEncodingException : " + uee.getMessage(), uee);
		}catch(Exception e){
			Malgn.errorLog("[encryptSHA256]Exception : " + e.getMessage(), e);
		}

        
        return "";
	}
	//16진수 변환 함수
	public String toHexString(byte[] letter){
		StringBuffer sbHex = new StringBuffer();
        for (int j = 0; j <letter.length; j++) {             
            String hexValue = Integer.toHexString((int)letter[j] & 0xff); 
            
            if(hexValue.length() == 1) sbHex.append("0");
            sbHex.append(hexValue.toUpperCase());
        } 
        
        return sbHex.toString();
	}

	//파라미터 정렬
	public String makeAllParam(HashMap<String, String> reqTemp){

		int listSize = 1;
		StringBuffer reqParam = new StringBuffer();

		List<String> reqList = new ArrayList<String>();


		try{
			reqList = new ArrayList<String>(reqTemp.keySet());
			Collections.sort(reqList);

			for (String str : reqList) {	
				String key = str;
				String value = (String) reqTemp.get(str);  
				
				if ("fgkey".equals(key))  {
					listSize++;
					continue;
				}			
				if(reqList.size() ==  listSize)
					reqParam.append(key).append("=").append(value);
				else 
					reqParam.append(key).append("=").append(value).append("&");   
				listSize++;
			}
			System.out.println("[makeReqAllParam]sorting : "+reqParam.toString());
			return reqParam.toString();



		}catch(ArrayIndexOutOfBoundsException aioobe){
			Malgn.errorLog("[makeReqAllParam]ArrayIndexOutOfBoundsException : " + aioobe.getMessage(), aioobe);
		}catch(Exception e){
			Malgn.errorLog("[makeReqAllParam]Exception : " + e.getMessage(), e);
		}
		System.out.println("[makeReqAllParam]return : "+reqParam.toString());
		return reqParam.toString();
	}
	//null 체크 함수
	public String checkNull(Object obj){
		if(obj == null) return "";
		else return (String)obj;
	}
%>
<%
	request.setCharacterEncoding("utf-8");

	/** 
		아래 설정 된 값은 테스트용 mid: 1849705C64 에 대한 secretKey 입니다.
		테스트로만 진행 하시고 발급 받으신 값으로 변경 하셔야 됩니다.
	*/
	String secretKey = "289F40E6640124B2628640168C3C5464";//테스트용 가맹점용
	String reqURL = "https://secureapi.test.eximbay.com/Gateway/BasicProcessor.krp"; //EXIMBAY TEST 서버 요청 URL입니다.
	String fgkey = "";//fgkey검증키 관련
	String sortingParams = "";//파라미터 정렬 관련

	//fgkey 검증키 생성
	Enumeration param1 = request.getParameterNames();
	HashMap<String, String> reqTemp = new HashMap<String, String>();
	while(param1.hasMoreElements()){
		String name = (String)param1.nextElement();
		String value = request.getParameter(name);
		System.out.println(name + ":" + value);	
		reqTemp.put(name, value);

	}
	sortingParams = makeAllParam(reqTemp);
	fgkey = encryptSHA256(secretKey+"?"+sortingParams);
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<body leftmargin="0" topmargin="0" align="center" onload="javascript://document.regForm.submit();">
<form name="regForm" method="post" action="<%=reqURL%>">
<input type="hidden" name="fgkey" value="<%=fgkey%>" />	<!--필수 값-->
<%
Enumeration param = request.getParameterNames();
while(param.hasMoreElements()){
	String name = (String)param.nextElement();
	String value = request.getParameter(name);
%>
	<input type="hidden" name="<%=name%>" value="<%=value%>">
<%}%>	
	<div style="text-align:left; font-size:14px;">
	<br>fgkey : <%=fgkey%>
	<br>secret key : <%=secretKey%>
	<br>sorting params : <%=sortingParams%>
	</div>
</form>
</body>
</html>
