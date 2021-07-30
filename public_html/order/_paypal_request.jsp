<%@ page contentType="text/html; charset=utf-8"%><%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>
<%@ include file="init.jsp" %><%

String merchantKey      = f.get("merchantkey");
String actionurl        = f.get("actionurl");
String timestamp        = f.get("timestamp");
String mid              = f.get("mid");
String webordernumber   = f.get("webordernumber");
String goodname         = f.get("goodname");     
String currency         = f.get("currency");
String price            = f.get("price");
String buyername        = f.get("buyername");
String buyertel         = f.get("buyertel");
String buyeremail       = f.get("buyeremail");
String returnurl        = f.get("returnurl");
String reqtype          = f.get("reqtype");
String logourl          = f.get("logourl");

String shiptoname        = f.get("shiptoname");
String shiptostreet      = f.get("shiptostreet");
String shiptostreet2     = f.get("shiptostreet2");
String shiptocity        = f.get("shiptocity");
String shiptostate       = f.get("shiptostate");
String shiptocountrycode = f.get("shiptocountrycode");
String shiptozip         = f.get("shiptozip");
	
String plainText = timestamp + mid + reqtype + webordernumber + currency + price + merchantKey;
String hashData  = encryptSHA512(timestamp + mid + reqtype + webordernumber + currency + price + merchantKey);

if("".equals(actionurl)) return;

%><!doctype html>
<html lang="ko">
<head>
<title>Please Wait...</title>
<meta charset="utf-8">
<script>
function submit() {        
	document.ini.submit();
}
</script>
</head>
Please Wait...
<body onload="javascript:submit();">

<form name="ini" method="post" action="<%=actionurl%>">
<input type="hidden" name="mid"             value="<%=mid%>">
<input type="hidden" name="timestamp"       value="<%=timestamp%>">
<input type="hidden" name="webordernumber"  value="<%=webordernumber%>">
<input type="hidden" name="goodname"        value="<%=goodname%>">
<input type="hidden" name="currency"        value="<%=currency%>">
<input type="hidden" name="price"           value="<%=price%>">
<input type="hidden" name="buyername"       value="<%=buyername%>">
<input type="hidden" name="buyertel"        value="<%=buyertel%>">
<input type="hidden" name="buyeremail"      value="<%=buyeremail%>">
<input type="hidden" name="reqtype"         value="<%=reqtype%>">
<input type="hidden" name="returnurl"       value="<%=returnurl%>">
<input type="hidden" name="hashdata"        value="<%=hashData%>">
<input type="hidden" name="logourl"         value="<%=logourl%>">

<input type="hidden" name="shiptoname"        value="<%=shiptoname%>">       
<input type="hidden" name="shiptostreet"      value="<%=shiptostreet%>">       
<input type="hidden" name="shiptostreet2"     value="<%=shiptostreet2%>">       
<input type="hidden" name="shiptocity"        value="<%=shiptocity%>">       
<input type="hidden" name="shiptostate"       value="<%=shiptostate%>">       
<input type="hidden" name="shiptocountrycode" value="<%=shiptocountrycode%>">       
<input type="hidden" name="shiptozip"         value="<%=shiptozip%>">  
</form>
</body>
</html>
<%!
public String encryptSHA512(String input) {
	String output = "";

	StringBuffer sb = new StringBuffer();
	MessageDigest md  = null;

	try {
		md = MessageDigest.getInstance("SHA-512");
		md.update(input.getBytes());
	} catch(NullPointerException npe) {
		System.out.println("NullPointerException : " + npe.getMessage());
		return null;
	} catch(NoSuchAlgorithmException nsae) {
		System.out.println("NoSuchAlgorithmException : " + nsae.getMessage());
		return null;
	} catch(Exception e) {
		System.out.println("Exception : " + e.getMessage());
		return null;
	}

	return byteArrayToHex(md.digest());
}

public String byteArrayToHex(byte[] ba) {
	if(ba == null || ba.length == 0) return null;

	StringBuffer sb = new StringBuffer(ba.length * 2);
	String hexNumber;
	for(int x = 0; x < ba.length; x++) {
		hexNumber = "0" + Integer.toHexString(0xff & ba[x]);
		sb.append(hexNumber.substring(hexNumber.length() - 2));
	}
	return sb.toString();
}
%>