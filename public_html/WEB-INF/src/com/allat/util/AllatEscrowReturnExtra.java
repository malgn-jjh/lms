package com.allat.util;
import java.util.*;
import java.io.*;

public class AllatEscrowReturnExtra {
	///Fields

	///Constructor
	public AllatEscrowReturnExtra(){};

	///Method

	///Main Method
	public static void main(String args[]){
		HashMap<String, Object> reqHm=new HashMap<String, Object>();
		HashMap<String, Object> resHm=null;
		String  szReqMsg="";
		String  szAllatEncData="";
		String  szCrossKey="";

		// 결제 요청 정보
		//------------------------------------------------------------------------
		String szShopId="";
		String szOrderNo="";
		String szPayType="";
		String szEsReturnFlag="";
		String szReturnYmd="";
		String szCustomBankNm="";
		String szCustomAccountNo="";
		String szReturnAmt="";
		String szReturnAddr="";
		String szReturnExpressNm="";
		String szReturnSendNo="";
		String szCustomTelNo="";
		String szSeqNo="";

		szCrossKey="";			// 해당 CrossKey값
		szShopId="";			// ShopId 값(최대 20Byte리)
		szOrderNo="";			// 배송등록 할 원거래건의 주문번호(최대 80Byte)
		szPayType="";			// 카드(CARD), 계좌이체(ABANK) -> 현재, 에스크로는 계좌이체만 적용됨
		szEsReturnFlag="";		// 교환처리(C), 반품처리(R)
		szReturnYmd="";			// YYYYMMDD
		szCustomBankNm="";		// 고객에게 환불해준 은행명(반품처리시 필수필드)
		szCustomAccountNo="";	// 고객에게 환불해준 계좌번호(반품처리시 필수필드)
		szReturnAmt="";			// 고객에게 환불해준 금액(반품처리시 필수필드)
		szReturnAddr="";		// 교환처리주소(교환처리시 필수필드)
		szReturnExpressNm="";	// 교환처리 이용택배사(교환처리시 필수필드)
		szReturnSendNo="";		// 교환처리 운송장번호(교환처리시 필수필드)
		szCustomTelNo="";		// 교환처리 고객연락처(교환처리시 필수필드)
		szSeqNo="";				// 올앳고유번호 ( 이 필드는 옵션임 );

		reqHm.put("allat_shop_id"           , szShopId          );
		reqHm.put("allat_order_no"          , szOrderNo         );
		reqHm.put("allat_pay_type"          , szPayType         );
		reqHm.put("allat_es_return_flag"    , szEsReturnFlag    );
		reqHm.put("allat_return_ymd"        , szReturnYmd       );
		reqHm.put("allat_custom_bank_nm"    , szCustomBankNm    );
		reqHm.put("allat_custom_account_no" , szCustomAccountNo );
		reqHm.put("allat_return_amt"        , szReturnAmt       );
		reqHm.put("allat_return_addr"       , szReturnAddr      );
		reqHm.put("allat_return_express_nm" , szReturnExpressNm );
		reqHm.put("allat_return_send_no"    , szReturnSendNo    );
		reqHm.put("allat_custom_tel_no"     , szCustomTelNo     );
		reqHm.put("allat_seq_no"            , szSeqNo           );
		reqHm.put("allat_test_yn"           , "N"               );  //테스트 :Y, 서비스 :N
		reqHm.put("allat_opt_pin"           , "NOUSE"           );  //수정금지(올앳 참조 필드)
		reqHm.put("allat_opt_mod"           , "APP"             );  //수정금지(올앳 참조 필드)

		AllatUtil util = new AllatUtil();

		szAllatEncData=util.setValue(reqHm);
		szReqMsg  = "allat_shop_id="   + szShopId
		+ "&allat_enc_data=" + szAllatEncData
		+ "&allat_cross_key="+ szCrossKey;

		resHm = util.escrowRetReq(szReqMsg, "SSL");

		String sReplyCd   = (String)resHm.get("reply_cd");
		String sReplyMsg  = (String)resHm.get("reply_msg");

		/* 결과값 처리
		--------------------------------------------------------------------------
		결과 값이 '0000'이면 정상임. 단, allat_test_yn=Y 일경우 '0001'이 정상임.
		실제 결제   : allat_test_yn=N 일 경우 reply_cd=0000 이면 정상
		테스트 결제 : allat_test_yn=Y 일 경우 reply_cd=0001 이면 정상
		--------------------------------------------------------------------------*/
		if( sReplyCd.equals("0000") ){
			// reply_cd "0000" 일때만 성공
			System.out.println("결과코드				: " + sReplyCd           );
			System.out.println("결과메세지			: " + sReplyMsg          );
		}else{
			// reply_cd 가 "0000" 아닐때는 에러 (자세한 내용은 매뉴얼참조)
			// reply_msg 가 실패에 대한 메세지
			System.out.println("결과코드		: " + sReplyCd    );
			System.out.println("결과메세지	: " + sReplyMsg   );
		}
	}
}
