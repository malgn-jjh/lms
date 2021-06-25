package com.allat.util;
import java.util.*;
import java.io.*;

public class AllatSanctionExtra {
	///Fields

	///Constructot
	public AllatSanctionExtra(){}
	///Method

	///Main Method
	public static void main(String args[]){
		HashMap<String, Object> reqHm=new HashMap<String, Object>();
		HashMap<String, Object> resHm=null;
		String szReqMsg="";
		String szAllatEncData="";
		String szCrossKey="";

		// 매입 요청 정보
		//------------------------------------------------------------------------
		String szShopId="";
		String szOrderNo="";
		String szSeqNo="";

		// 정보 입력
		//------------------------------------------------------------------------
		szCrossKey="";	// 해당 CrossKey값
		szShopId="";	// ShopId 값(최대 20Byte)
		szOrderNo="";	//주문번호(최대 80Byte) : 쇼핑몰 고유 주문번호
		szSeqNo="";		//거래일련번호(최대 10Byte): 옵션필드임

		reqHm.put("allat_shop_id"   ,   szShopId    );
		reqHm.put("allat_order_no"  ,   szOrderNo   );
		reqHm.put("allat_seq_no"    ,   szSeqNo     );    //옵션 필드임(삭제 가능)
		reqHm.put("allat_test_yn"   ,   "N"         );    //테스트 :Y, 서비스 :N
		reqHm.put("allat_opt_pin"   ,   "NOUSE"     );    //수정금지(올앳 참조 필드)
		reqHm.put("allat_opt_mod"   ,   "APP"       );    //수정금지(올앳 참조 필드)

		AllatUtil util = new AllatUtil();

		szAllatEncData=util.setValue(reqHm);
		szReqMsg  = "allat_shop_id="   + szShopId
					+ "&allat_enc_data=" + szAllatEncData
					+ "&allat_cross_key="+ szCrossKey;

		resHm = util.sanctionReq(szReqMsg, "SSL");

		String sReplyCd   = (String)resHm.get("reply_cd");
		String sReplyMsg  = (String)resHm.get("reply_msg");

		/**************  결과 값 출력 ******************/
		if( sReplyCd.equals("0000") ){
			// reply_cd "0000" 일때만 성공
			String sSanctionYMDHMS    = (String)resHm.get("sanction_ymdhms");

			System.out.println("결과코드   : " + sReplyCd);
			System.out.println("결과메세지 : " + sReplyMsg);
			System.out.println("매입일시   : " + sSanctionYMDHMS);
		}else{
			// reply_cd 가 "0000" 아닐때는 에러 (자세한 내용은 매뉴얼참조)
			// reply_msg 가 실패에 대한 메세지
			System.out.println("결과코드   : " + sReplyCd);
			System.out.println("결과메세지 : " + sReplyMsg);
		}
	}
}
