package com.allat.util;
import java.util.*;
import java.io.*;

public class AllatEscrowCheckExtra {
	///Fields

	///Constructor
	public AllatEscrowCheckExtra(){};

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
		String szEscrowSendNo="";
		String szEscrowExpressNm="";
		String szPayType="";
		String szSeqNo="";

		szCrossKey="";			// 해당 CrossKey값
		szShopId="";			// ShopId 값(최대 20Byte)
		szOrderNo="";			// 배송등록 할 원거래건의 주문번호(최대 80Byte)
		szEscrowSendNo="";		// 배송 운송장 번호 (최대 50Byte)
		szEscrowExpressNm ="";	// 택배사명 (최대 30bytes)
		szPayType="";			// 카드(CARD), 계좌이체(ABANK) -> 현재, 에스크로는 계좌이체만 적용됨
		szSeqNo="";				// 올앳고유번호 ( 이 필드는 옵션임 );

		reqHm.put("allat_shop_id"           , szShopId          );
		reqHm.put("allat_order_no"          , szOrderNo         );
		reqHm.put("allat_escrow_send_no "   , szEscrowSendNo    );
		reqHm.put("allat_escrow_express_nm" , szEscrowExpressNm );
		reqHm.put("allat_pay_type"          , szPayType         );
		reqHm.put("allat_seq_no"            , szSeqNo           );
		reqHm.put("allat_test_yn"           , "N"               );  //테스트 :Y, 서비스 :N
		reqHm.put("allat_opt_pin"           , "NOUSE"           );  //수정금지(올앳 참조 필드)
		reqHm.put("allat_opt_mod"           , "APP"             );  //수정금지(올앳 참조 필드)

		AllatUtil util = new AllatUtil();

		szAllatEncData=util.setValue(reqHm);
		szReqMsg  = "allat_shop_id="   + szShopId
		+ "&allat_enc_data=" + szAllatEncData
		+ "&allat_cross_key="+ szCrossKey;

		resHm = util.escrowchkReq(szReqMsg, "SSL");

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
			String sEscrowCheckYmdhms = (String)resHm.get("escrow_check_ymdhms");

			System.out.println("결과코드				: " + sReplyCd           );
			System.out.println("결과메세지			: " + sReplyMsg          );
			System.out.println("에스크로 배송 개시일	: " + sEscrowCheckYmdhms );
		}else{
			// reply_cd 가 "0000" 아닐때는 에러 (자세한 내용은 매뉴얼참조)
			// reply_msg 가 실패에 대한 메세지
			System.out.println("결과코드		: " + sReplyCd    );
			System.out.println("결과메세지	: " + sReplyMsg   );
		}
	}
}
