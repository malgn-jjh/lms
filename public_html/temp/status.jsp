<%@ page contentType = "text/html;charset=utf-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.security.*" %>
<%@ page import="java.io.UnsupportedEncodingException" %>
<%!
//SHA256 해쉬 함수
	public String encryptSHA256(String value){
		try{
	        byte[] plainText = value.getBytes("UTF-8");
	        byte[] hashValue = null;
	        
	        MessageDigest md = MessageDigest.getInstance("SHA-256");
	        hashValue = md.digest(plainText);
   
	        return toHexString(hashValue);
        }catch(NoSuchAlgorithmException nsae){
			System.out.println("[encryptSHA256]NoSuchAlgorithmException : " + nsae);
		}catch(UnsupportedEncodingException uee){
			System.out.println("[encryptSHA256]UnsupportedEncodingException : " + uee);
		}catch(Exception e){
        	System.out.println("[encryptSHA256]Exception : " + e);
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
			System.out.println("[makeAllParam]sorting : "+reqParam.toString());
			return reqParam.toString();

		}catch(ArrayIndexOutOfBoundsException aioobe){
			System.out.println("[makeReqAllParam]ArrayIndexOutOfBoundsException : " + aioobe);
		}catch(Exception e){
			System.out.println("[makeAllParam]Exception : " + e);
		}
		System.out.println("[makeAllParam]return : "+reqParam.toString());
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
		아래 설정 된 값은 테스트용 secretKey입니다.
		테스트로만 진행하시고 발급 받으신 값으로 변경하셔야 됩니다.
	*/
	String secretKey = "289F40E6640124B2628640168C3C5464";//가맹점 secretkey

	String rescode = checkNull(request.getParameter("rescode"));//0000 : 정상 
	String resmsg = checkNull(request.getParameter("resmsg"));//결제 결과 메세지
	String fgkey = checkNull(request.getParameter("fgkey"));//파라미터 유효성 검증키 값
	String sortingParams = "";//파라미터 정렬 관련
	String newFgkey = "";//응답 받은 파라미터 검증 fgkey
	HashMap<String, String> reqTemp = new HashMap<String, String>();
	System.out.println("--------------status-------------------");
	Enumeration param1 = request.getParameterNames();
	
	while(param1.hasMoreElements()){
		String name = (String)param1.nextElement();
		String value = request.getParameter(name);
		System.out.println(name + ":" + value);	
		reqTemp.put(name, value);

	}

	//rescode=0000 일때 fgkey 확인
	if(rescode.equals("0000")){
		sortingParams = makeAllParam(reqTemp);
		newFgkey = encryptSHA256(secretKey+"?"+sortingParams);
		System.out.println("fgkey : "+fgkey+", newfgkey : "+newFgkey);
		//fgkey 검증 실패 시 에러 처리
		if(!fgkey.equals(newFgkey)){
			rescode = "ERROR";
			resmsg = "Invalid transaction";
		}		
	}
	
	
	if(rescode.equals("0000")){
		//가맹점 측 DB 처리하는 부분
		//해당 페이지는 Back-End로 처리되기 때문에 스크립트, 세션, 쿠키 사용이 불가능 합니다.
	}
%>