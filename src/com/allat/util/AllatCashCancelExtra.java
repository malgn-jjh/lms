package com.allat.util;
import java.util.*;
import java.io.*;

public class AllatCashCancelExtra {
	///Fields

	///Constructor
	public AllatCashCancelExtra(){};
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
		String szCashBillNo="";
		String szSupplyAmt="";
		String szVatAmt="";
		String szRegBusinessNo="";

		szCrossKey="";		// 해당 CrossKey값
		szShopId="";		// ShopId 값(최대 20Byte)
		szCashBillNo="";	// 현금영수증일련번호(최대 10Byte)
		szSupplyAmt="";		// 취소공급가액(최대 10Byte)
		szVatAmt="";		// 취소VAT금액(최대 10Byte)
		szRegBusinessNo="";	// 등록할 사업자 번호(최대 10Byte):상점 ID와 다른경우

		reqHm.put("allat_shop_id"           , szShopId       );
		reqHm.put("allat_cash_bill_no"      , szCashBillNo   );
		reqHm.put("allat_supply_amt"        , szSupplyAmt    );
		reqHm.put("allat_vat_amt"           , szVatAmt       );
		reqHm.put("allat_reg_business_no"   , szRegBusinessNo);
		reqHm.put("allat_test_yn"           , "N"            );  //테스트 :Y, 서비스 :N
		reqHm.put("allat_opt_pin"           , "NOUSE"        );  //수정금지(올앳 참조 필드)
		reqHm.put("allat_opt_mod"           , "APP"          );  //수정금지(올앳 참조 필드)

		AllatUtil util = new AllatUtil();

		szAllatEncData=util.setValue(reqHm);
		szReqMsg  = "allat_shop_id="   + szShopId
					+ "&allat_enc_data=" + szAllatEncData
					+ "&allat_cross_key="+ szCrossKey;

		resHm = util.cashcanReq(szReqMsg, "SSL");

		String sReplyCd		= (String)resHm.get("reply_cd");
		String sReplyMsg	= (String)resHm.get("reply_msg");

		if( sReplyCd.equals("0000") ){
			// reply_cd "0000" 일때만 성공
			String sCancelYMDHMS      = (String)resHm.get("cancel_ymdhms");
			String sPartCancelFlag    = (String)resHm.get("part_cancel_flag");
			String sRemainAmt         = (String)resHm.get("remain_amt");

			System.out.println("결과코드		: " + sReplyCd   );
			System.out.println("결과메세지	: " + sReplyMsg  );
			System.out.println("취소일시		: " + sCancelYMDHMS);
			System.out.println("취소구분		: " + sPartCancelFlag);
			System.out.println("잔액			: " + sRemainAmt);
		}else{
			// reply_cd 가 "0000" 아닐때는 에러 (자세한 내용은 매뉴얼참조)
			// reply_msg 가 실패에 대한 메세지
			System.out.println("결과코드		: " + sReplyCd   );
			System.out.println("결과메세지	: " + sReplyMsg  );
		}
	}
}
