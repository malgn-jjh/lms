<%@ page contentType="text/html; charset=euc-kr" %><%@ include file="../init.jsp" %>
<!-- �þܰ��� �Լ� Import //-->
<%@ page import="java.util.*,java.net.*,com.allat.util.AllatUtil" %>

<%
  //Request Value Define
  //----------------------

  // Service Code
  String sCrossKey = siteinfo.s("pg_key");	//�����ʿ� [����Ʈ ���� - http://www.allatpay.com/servlet/AllatBiz/support/sp_install_guide_scriptapi.jsp#shop]
  String sShopId   = siteinfo.s("pg_id");		//�����ʿ�
  String sAmount   = "1000";				//���� �ݾ��� �ٽ� ����ؼ� ������ ��(��ŷ����)  ( session, DB ��� )

  String sEncData  = request.getParameter("allat_enc_data");
  String strReq = "";
m.jsAlert(sEncData);
if(true)return;
  // ��û ������ ����
  //----------------------
  strReq  ="allat_shop_id="   +sShopId;
  strReq +="&allat_amt="      +sAmount;
  strReq +="&allat_enc_data=" +sEncData;
  strReq +="&allat_cross_key="+sCrossKey;

  // �þ� ���� ������ ���  : AllatUtil.approvalReq->����Լ�, HashMap->�����
  //-----------------------------------------------------------------------------
  AllatUtil util = new AllatUtil();
  HashMap hm     = null;
  //hm = util.approvalReq(strReq, "NOSSL");
  hm = util.approvalReq(strReq, "SSL");

  // ���� ��� �� Ȯ��
  //------------------
  String sReplyCd     = (String)hm.get("reply_cd");
  String sReplyMsg    = (String)hm.get("reply_msg");

  /* ����� ó��
  --------------------------------------------------------------------------
     ��� ���� '0000'�̸� ������. ��, allat_test_yn=Y �ϰ�� '0001'�� ������.
     ���� ����   : allat_test_yn=N �� ��� reply_cd=0000 �̸� ����
     �׽�Ʈ ���� : allat_test_yn=Y �� ��� reply_cd=0001 �̸� ����
  --------------------------------------------------------------------------*/
  if( sReplyCd.equals("0000") ){
    // reply_cd "0000" �϶��� ����
    String sOrderNo        = (String)hm.get("order_no");
    String sAmt            = (String)hm.get("amt");
    String sPayType        = (String)hm.get("pay_type");
    String sApprovalYmdHms = (String)hm.get("approval_ymdhms");
    String sSeqNo          = (String)hm.get("seq_no");
    String sApprovalNo     = (String)hm.get("approval_no");
    String sCardId         = (String)hm.get("card_id");
    String sCardNm         = (String)hm.get("card_nm");
    String sSellMm         = (String)hm.get("sell_mm");
    String sZerofeeYn      = (String)hm.get("zerofee_yn");
    String sCertYn         = (String)hm.get("cert_yn");
    String sContractYn     = (String)hm.get("contract_yn");
    String sSaveAmt        = (String)hm.get("save_amt");
    String sBankId         = (String)hm.get("bank_id");
    String sBankNm         = (String)hm.get("bank_nm");
    String sCashBillNo     = (String)hm.get("cash_bill_no");
    String sCashApprovalNo = (String)hm.get("cash_approval_no");
    String sEscrowYn       = (String)hm.get("escrow_yn");
    String sAccountNo      = (String)hm.get("account_no");
    String sAccountNm      = (String)hm.get("account_nm");
    String sIncomeAccNm    = (String)hm.get("income_account_nm");
    String sIncomeLimitYmd = (String)hm.get("income_limit_ymd");
    String sIncomeExpectYmd= (String)hm.get("income_expect_ymd");
    String sCashYn         = (String)hm.get("cash_yn");
    String sHpId           = (String)hm.get("hp_id");
    String sTicketId       = (String)hm.get("ticket_id");
    String sTicketPayType  = (String)hm.get("ticket_pay_type");
    String sTicketNm       = (String)hm.get("ticket_nm");
    String sPointAmt       = (String)hm.get("point_amt");

    out.println("����ڵ�               : " + sReplyCd          + "<br>");
    out.println("����޼���             : " + sReplyMsg         + "<br>");
    out.println("�ֹ���ȣ               : " + sOrderNo          + "<br>");
    out.println("���αݾ�               : " + sAmt              + "<br>");
    out.println("���Ҽ���               : " + sPayType          + "<br>");
    out.println("�����Ͻ�               : " + sApprovalYmdHms   + "<br>");
    out.println("�ŷ��Ϸù�ȣ           : " + sSeqNo            + "<br>");
    out.println("����ũ�� ���� ����     : " + sEscrowYn         + "<br>");
	out.println("==================== �ſ� ī�� ===================<br>");
    out.println("���ι�ȣ               : " + sApprovalNo       + "<br>");
    out.println("ī��ID                 : " + sCardId           + "<br>");
    out.println("ī���                 : " + sCardNm           + "<br>");
    out.println("�Һΰ���               : " + sSellMm           + "<br>");
    out.println("�����ڿ���             : " + sZerofeeYn        + "<br>");   //������(Y),�Ͻú�(N)
    out.println("��������               : " + sCertYn           + "<br>");   //����(Y),������(N)
    out.println("�����Ϳ���             : " + sContractYn       + "<br>");   //3�ڰ�����(Y),��ǥ������(N)
    out.println("���̺� ���� �ݾ�       : " + sSaveAmt          + "<br>");
    out.println("����Ʈ ���� �ݾ�       : " + sPointAmt         + "<br>");
	out.println("=============== ���� ��ü / ������� =============<br>");
    out.println("����ID                 : " + sBankId           + "<br>");
    out.println("�����                 : " + sBankNm           + "<br>");
    out.println("���ݿ����� �Ϸ� ��ȣ   : " + sCashBillNo       + "<br>");
    out.println("���ݿ����� ���� ��ȣ   : " + sCashApprovalNo   + "<br>");
    out.println("===================== ������� ===================<br>");
    out.println("���¹�ȣ               : " + sAccountNo        + "<br>");
    out.println("�Ա� ���¸�            : " + sIncomeAccNm      + "<br>");
    out.println("�Ա��ڸ�               : " + sAccountNm        + "<br>");
    out.println("�Աݱ�����             : " + sIncomeLimitYmd   + "<br>");
    out.println("�Աݿ�����             : " + sIncomeExpectYmd  + "<br>");
    out.println("���ݿ�������û ����    : " + sCashYn           + "<br>");
    out.println("===================== �޴��� ���� ================<br>");
    out.println("�̵���Ż籸��         : " + sHpId             + "<br>");
    out.println("===================== ��ǰ�� ���� ================<br>");
    out.println("��ǰ��ID               :" + sTicketId          + "<br>");
    out.println("��ǰ�� �̸�            :" + sTicketPayType     + "<br>");
    out.println("��������               :" + sTicketNm          + "<br>");

	// ������������ ���� ��ų�� //////////////////////////////////////////
	String sPartcancelYn  = (String)hm.get("partcancel_yn");
	String sBCCertNo      = (String)hm.get("bc_cert_no");
	String sCardNo        = (String)hm.get("card_no");
	String sIspFullCardCd = (String)hm.get("isp_full_card_cd");
	String sCardType      = (String)hm.get("card_type");
	String sBankAccountNm = (String)hm.get("bank_account_nm");
    out.println("===================== ���������� ================<br>");
	out.println("�ſ�ī�� �κ���Ұ��ɿ��� : " + sPartcancelYn  + "<br>"); 
	out.println("BC������ȣ                : " + sBCCertNo      + "<br>");
	out.println("ī���ȣ Return           : " + sCardNo        + "<br>");
	out.println("ISP ��ü ī���ڵ�         : " + sIspFullCardCd + "<br>");
	out.println("ī�屸��                  : " + sCardType      + "<br>");
	out.println("������ü �����ָ�         : " + sBankAccountNm + "<br>");
	//////////////////////////////////////////////////////////////////////

  }else{
    // reply_cd �� "0000" �ƴҶ��� ���� (�ڼ��� ������ �Ŵ�������)
    // reply_msg �� ���п� ���� �޼���
    out.println("����ڵ�               : " + sReplyCd  + "<br>");
    out.println("����޼���             : " + sReplyMsg + "<br>");
  }
%>

<%--
    [�ſ�ī�� ��ǥ��� ����]

    ������ ���������� �Ϸ�Ǹ� �Ʒ��� �ҽ��� �̿��Ͽ�, ������ �ſ�ī�� ��ǥ�� ������ �� �ֽ��ϴ�.
    ��ǥ ��½� �������̵�� �ֹ���ȣ�� �����Ͻñ� �ٶ��ϴ�.

    var urls ="http://www.allatpay.com/servlet/AllatBizPop/member/pop_card_receipt.jsp?shop_id=�������̵�&order_no=�ֹ���ȣ";
    window.open(urls,"app","width=410,height=650,scrollbars=0");

    ���ݿ����� ��ǥ �Ǵ� �ŷ�Ȯ�μ� ��¿� ���� ���Ǵ� �þ����� ����Ʈ�� 1:1����� �̿��Ͻðų�
    02) 3788-9990 ���� ��ȭ �ֽñ� �ٶ��ϴ�.

    ��ǥ��� �������� ���� �þ� Ȩ�������� �Ϻην�, Ȩ������ ���� ���� ������ ���Ͽ� ������ ���� �Ǵ� URL ������ ���� ��
    �ֽ��ϴ�. Ȩ������ ���� ���� ������ ���� ���, ��ǥ��� URL�� Ȯ���Ͻñ� �ٶ��ϴ�.
--%>
