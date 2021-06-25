package com.allat.util;
import java.util.*;
import java.io.*;

public class AllatCancelExtra {
  ///Fields

  ///Constructot
  public AllatCancelExtra(){}
  ///Method

  ///Main Method
  public static void main(String args[]){
    HashMap<String, Object> reqHm=new HashMap<String, Object>();
    HashMap<String, Object> resHm=null;
    String szReqMsg="";
    String szAllatEncData="";
    String szCrossKey="";

// 취소 요청 정보
//------------------------------------------------------------------------
    String szShopId ="";
    String szAmt    ="";
    String szOrderNo="";
    String szPayType="";
    String szSeqNo  ="";

// 정보 입력
//------------------------------------------------------------------------
    szCrossKey      ="CROSSKEY";    //해당 CrossKey값
    szShopId        ="SHOPID";      //ShopId 값               (최대  20 자리)
    szAmt           ="1000";        //취소 금액               (최대  10 자리)
    szOrderNo       ="test00001";   //주문번호                (최대  80 자리)
    szPayType       ="CARD";        //원거래건의 결제방식[카드:CARD,계좌이체:ABANK]
    szSeqNo         ="10000003";    //거래일련번호:옵션필드   (최대  10자리)

    reqHm.put("allat_shop_id" ,  szShopId );
    reqHm.put("allat_order_no",  szOrderNo);
    reqHm.put("allat_amt"     ,  szAmt    );
    reqHm.put("allat_pay_type",  szPayType);
    reqHm.put("allat_test_yn" ,  "N"      );    //테스트 :Y, 서비스 :N
    reqHm.put("allat_opt_pin" ,  "NOUSE"  );    //수정금지(올앳 참조 필드)
    reqHm.put("allat_opt_mod" ,  "APP"    );    //수정금지(올앳 참조 필드)
    reqHm.put("allat_seq_no"  ,  szSeqNo  );    //옵션 필드( 삭제 가능함 )

    AllatUtil util = new AllatUtil();

    szAllatEncData=util.setValue(reqHm);
    szReqMsg  = "allat_shop_id="   + szShopId
              + "&allat_amt="      + szAmt
              + "&allat_enc_data=" + szAllatEncData
              + "&allat_cross_key="+ szCrossKey;

    resHm = util.cancelReq(szReqMsg, "SSL");

    String sReplyCd   = (String)resHm.get("reply_cd");
    String sReplyMsg  = (String)resHm.get("reply_msg");

    if( sReplyCd.equals("0000") ){
    // reply_cd "0000" 일때만 성공
      String sCancelYMDHMS    = (String)resHm.get("cancel_ymdhms");
      String sPartCancelFlag  = (String)resHm.get("part_cancel_flag");
      String sRemainAmt       = (String)resHm.get("remain_amt");
      String sPayType         = (String)resHm.get("pay_type");

      System.out.println("결과코드        : " + sReplyCd          );
      System.out.println("결과메세지      : " + sReplyMsg         );
      System.out.println("취소일시        : " + sCancelYMDHMS     );
      System.out.println("취소구분        : " + sPartCancelFlag   );
      System.out.println("잔액            : " + sRemainAmt        );
      System.out.println("거래방식구분    : " + sPayType          );

    }else{
    // reply_cd 가 "0000" 아닐때는 에러 (자세한 내용은 매뉴얼참조)
    // reply_msg 가 실패에 대한 메세지
      System.out.println("결과코드   : " + sReplyCd);
      System.out.println("결과메세지 : " + sReplyMsg);
    }
  }
}
