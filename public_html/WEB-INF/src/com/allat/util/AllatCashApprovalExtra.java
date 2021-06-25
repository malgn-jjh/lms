package com.allat.util;
import java.util.*;
import java.io.*;

public class AllatCashApprovalExtra {
	///Fields

	///Constructor
	public AllatCashApprovalExtra(){};
	///Method

	///Main Method
	public static void main(String args[]){
		HashMap<String, Object> reqHm=new HashMap<String, Object>();
		HashMap<String, Object> resHm=null;
		String szReqMsg="";
		String szAllatEncData="";
		String szCrossKey="";

		// 결제 요청 정보
		//------------------------------------------------------------------------
		String szShopId="";
		String szApplyYMDHMS="";
		String szShopMemberId="";
		String szCertNo="";
		String szSupplyAmt="";
		String szVatAmt="";
		String szProductNm="";
		String szReceiptType="";
		String szSeqNo="";
		String szRegBusinessNo="";
		String szBuyerIp="";

		szCrossKey="";		// 해당 CrossKey값
		szShopId="";		// ShopId 값(최대 20Byte)
		szApplyYMDHMS="";	// 거래요청일자(최대 14Byte)
		szShopMemberId="";	// 쇼핑몰의 회원ID(최대 20Byte)
		szCertNo="";		// 인증정보(최대 13Byte) : 핸드폰번호,주민번호,사업자번호
		szSupplyAmt="";		// 공급가액(최대 10Byte) : 과세 + 면세
		szVatAmt="";		// VAT금액(최대 10Byte)
		szProductNm="";		// 상품명(최대 100Byte)
		szReceiptType="";	// 현금영수증구분(최대 6Byte):계좌이체(ABANK),무통장(NBANK)
		szSeqNo="";			// 거래일련번호(최대 10Byte)
		szRegBusinessNo="";	// 등록할 사업자 번호(최대 10Byte):상점 ID와 다른경우
		szBuyerIp="";		// 결제자 IP(최대 15Byte) : BuyerIp를 넣을수 없다면 "Unknown"으로 세팅

		reqHm.put("allat_shop_id"           , szShopId       );
		reqHm.put("allat_apply_ymdhms"      , szApplyYMDHMS  );
		reqHm.put("allat_shop_member_id"    , szShopMemberId );
		reqHm.put("allat_cert_no"           , szCertNo       );
		reqHm.put("allat_supply_amt"        , szSupplyAmt    );
		reqHm.put("allat_vat_amt"           , szVatAmt       );
		reqHm.put("allat_receipt_type"      , szReceiptType  );
		reqHm.put("allat_product_nm"        , szProductNm    );
		reqHm.put("allat_seq_no"            , szSeqNo        );
		reqHm.put("allat_reg_business_no"   , szRegBusinessNo);
		reqHm.put("allat_buyer_ip"          , szBuyerIp      );
		reqHm.put("allat_test_yn"           , "N"            );
		reqHm.put("allat_opt_pin"           , "NOUSE"        );
		reqHm.put("allat_opt_mod"           , "APP"          );

		AllatUtil util = new AllatUtil();

		szAllatEncData=util.setValue(reqHm);
		szReqMsg  = "allat_shop_id="   + szShopId
					+ "&allat_enc_data=" + szAllatEncData
					+ "&allat_cross_key="+ szCrossKey;

		resHm = util.cashappReq(szReqMsg, "SSL");

		String sReplyCd     = (String)resHm.get("reply_cd");
		String sReplyMsg  = (String)resHm.get("reply_msg");

		if( sReplyCd.equals("0000") ){
			// reply_cd "0000" 일때만 성공
			String sApprovalNo      = (String)resHm.get("approval_no");
			String sCashBillNo      = (String)resHm.get("cash_bill_no");

			System.out.println("결과코드   : " + sReplyCd   );
			System.out.println("결과메세지 : " + sReplyMsg  );
			System.out.println("승인번호   : " + sApprovalNo);
			System.out.println("일련번호   : " + sCashBillNo);
		}else{
			// reply_cd 가 "0000" 아닐때는 에러 (자세한 내용은 매뉴얼참조)
			// reply_msg 가 실패에 대한 메세지
			System.out.println("결과코드   : " + sReplyCd   );
			System.out.println("결과메세지 : " + sReplyMsg  );
		}
	}
}
