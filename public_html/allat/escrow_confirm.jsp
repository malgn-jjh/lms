<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>New All@PayPro 주문정보 입력(통합)</title>
<style><!--
body { font-family:굴림체; font-size:12px; }
td   { font-family:굴림체; font-size:12px; }
.title { font-family:굴림체; font-size:16px; }
.head { background-color:#EFF7FC; padding: 3 3 0 5 }
.body { background-color:#FFFFFF; padding: 3 3 0 5  }
.nbody { background-color:#FFFFCC; padding: 3 3 0 5  }
//--></style>

<script language=JavaScript charset='utf-8' src="http://tx.allatpay.com/common/NonAllatPayREPlus.js"></script>

<script language=Javascript>
// 결제창 호출
function ftn_app(dfm) {
	Allat_Plus_Escrow(dfm, "0", "0"); /* 포지션 지정 (결제창 크기, 320*360) */ 
}

// 결과값 반환( receive 페이지에서 호출 )
function result_submit(result_cd,result_msg,enc_data) {
	Allat_Plus_Close();

	if(result_cd != '0000') {
		alert(result_cd + " : " + result_msg);
	} else {
		sendFm.allat_enc_data.value = enc_data;

		sendFm.action = "allat_escrowconfirm.jsp";
		sendFm.method = "post";
		sendFm.target = "_self";
		sendFm.submit();
	}
}
</script>

</head>
<body>
<p align="center" class="title"><u>New All@Pay™ 에스크로 고객확인 예제페이지</u></p>

<!-- HTML : Form 설정 -->
<form name="sendFm"  method="POST">
<!-- 승인요청 및 결과수신페이지 지정 -->
<table border="0" cellpadding="0" cellspacing="1" bgcolor="#606060" width="1152" align="center" style="TABLE-LAYOUT: fixed;">
</br>
	<font color="red">◆ 필수 정보 : <b>결제 필수 항목(공통)</b></font>
	<tr>
		<td width="140" class="head">항목</td>
		<td width="160" class="head">예시 값</td>
		<td width="70"  class="head">&nbsp최대길이<br>(영문기준)</td>
		<td width="150"  class="head">변수명</td>
		<td class="head">변수 설명</td>
	</tr>
	<tr>
		<td class="head">상점 ID</td>
		<td class="body"><input type="text" name="allat_shop_id" value="" size="19" maxlength="20"></td>
		<td class="body">20</td>
		<td class="body">allat_shop_id</td>
		<td class="body">Allat에서 발급한 고유 상점 ID</td>
	</tr>
	<tr>
		<td class="head">주문번호</td>
		<td class="body"><input type="text" name="allat_order_no" value="" size="19" maxlength="80"></td>
		<td class="body">80</td>
		<td class="body">allat_order_no</td>
		<td class="body">쇼핑몰에서 사용하는 고유 주문번호 : 공백,작은따옴표('),큰따옴표(") 사용 불가</td>
	</tr>
	<tr>
		<td class="head">결제방식</td>
		<td class="body"><input type="text" name="allat_pay_type" value="" size="19" maxlength="6"></td>
		<td class="body">16</td>
		<td class="body">allat_pay_type</td>
		<td class="body">카드(CARD), 계좌이체(ABANK), 가상계좌(VBANK), 휴대폰(HP), 상품권(TICKET)</td>
	</tr>
	<tr>
		<td class="head">인증정보수신URL<br>(shop_receive_url)</td>
		<td class="body"><input type="text" name="shop_receive_url" value="" size="19" maxlength="120"></td>
		<td class="body">120</td>
		<td class="body">shop_receive_url</td>
		<td class="body"></td>
	</tr>
	<tr>
		<td class="head">주문정보암호화필드</td>
		<td class="body"><font color="red">값은 자동으로 설정됨</font></td>
		<td class="body">-</td>
		<td class="body">allat_enc_data</td>
		<td class="body"><font color="red">&ltinput type=hidden name=allat_enc_data value=''&gt<br>
		※결제정보가 암호화되어 설정되는값.</br>hidden field로 설정해야함</font>
		</td>
	<input type=hidden name="allat_enc_data" value="">
	</tr>
	<tr>
		<td class="head">올앳참조필드</td>
		<td class="body">NOUSE<input type="hidden" name="allat_opt_pin" value="NOUSE" size="19"></td>
		<td class="body">-</td>
		<td class="body">allat_opt_pin</td>
		<td class="body">NOUSE 고정</td>
	</tr>
	<tr>
		<td class="head">올앳참조필드</td>
		<td class="body">APP<input type="hidden" name="allat_opt_mod" value="APP" size="19"></td>
		<td class="body">-</td>
		<td class="body">allat_opt_mod</td>
		<td class="body">APP 고정</td>
	</tr>
</table>
<br>
<!-- 결제 옵션 정보 -->
<table border="0" cellpadding="0" cellspacing="1" bgcolor="#606060" width="1152" align="center" style="TABLE-LAYOUT: fixed;">
	<font color=blue>◆ 결제 옵션 정보 : <b>결제 옵션 항목(공통)</b></font>
	<tr>
		<td width="140" class="head">거래일련번호</td>
		<td width="160" class="body"><input type=text name="allat_seq_no" value="" size="19" maxlength="10"></td>
		<td width="70"  class="body">1</td>
		<td width="150" class="body">allat_seq_no</td>        
		<td class="body"></td>
	</tr>	
	<tr>
		<td class="head">테스트 여부</td>
		<td class="body"><input type=text name="allat_test_yn" value="N" size="19" maxlength="1"></td>
		<td class="body">1</td>
		<td class="body">allat_test_yn</td>        
		<td class="body"></td>
	</tr>
</table>
</div>

<p align="center">
<table border="0" cellpadding="0" cellspacing="1" width="1152" align="center">
	<tr>
		<td align="center">
		<input type="button" value=" 결제 요청 " name="app_btn" onClick="javascript:ftn_app(document.sendFm);">
		</td>
	</tr>
</table>
</p>
</form>
</body>
</html>
