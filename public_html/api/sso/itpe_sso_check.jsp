<%@ page contentType="text/javascript; charset=utf-8" %><%@ include file="/init.jsp" %>
var auth = GetCookie('MLMS142937');
var uid = <%= userId %>;
if(auth == null && uid > 0) location.href = 'https://www.itpe.co.kr/api/sso/itpe_sso.jsp';
//else if(auth != null && uid == 0) location.href = '/member/logout.jsp';