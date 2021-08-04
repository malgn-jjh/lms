<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%@ page import="malgnsoft.json.*" %><%

KtRemoteDao ktRemote = new KtRemoteDao(); ktRemote.setDebug(out);

if(m.isPost() && f.validate()) {
    if("manual".equals(f.get("mode"))) {

        Http http = new Http(f.get("url"));
        http.setDebug(out);
        http.setHeader("Content-Type", "application/json");
        if(!"".equals(f.get("token"))) http.setHeader("Authorization", "Bearer " + f.get("token"));
        http.setData(f.get("data"));
        String jstr = http.send("POST");
        out.print(jstr);

    } else {

        String value = f.get("kvalue");
        String mode = f.get("mode");
        ktRemote.setAuthToken(ktRemote.getAuthToken());

        String ret = "";
        if("pcreate".equals(mode)) { //플랜 생성
            long now = m.getUnixTime();
//            ret = ktRemote.insertPlan("CLASS", "새 플랜", value, 1000, null, 0, now, now + (60 * 60 * 24));
            ret = ktRemote.insertPlan("CLASS", "test@test.com", now + (60 * 31), now + (60 * 60 * 24));
        } else if("pupdate".equals(mode)) { //플랜 수정
        //    ret = ktRemote.updatePlan(value) + "";
        } else if("pdelete".equals(mode)) { //플랜 삭제
            ret = ktRemote.deletePlan(value, "test@test.com") + "";
        } else if("cucreate".equals(mode)) { //수강생 출석 등록
            //ret = ktRemote.insertMember(value, "", "ㅇㅇㅇㅇ");
            ret = ktRemote.insertHost(value, userId, "호스트");
        } else if("cuupdate".equals(mode)) { //수강생 출석 수정
            ret = ktRemote.updateMember(value, "test@test.com", "호스트", "HOST", "USER") + "";
        } else if("cudelete".equals(mode)) { //수강생 출석 삭제
            ret = ktRemote.deleteMember(value, "test@test.com") + "";
        } else if("token".equals(mode)) { //수강생 토큰 생성
            ret = ktRemote.getUserToken(value, m.getUniqId());
        } else if("history".equals(mode)) { //플랜 생성 이력
            long now = m.getUnixTime();
            m.p(ktRemote.getPlanHistory(now - (60 * 60 * 24 * 30), now));
        } else if("attend".equals(mode)) { //플랜 출결 이력
            //ret = ktRemote.getAttendList(value);
            m.p(ktRemote.getAttendList(value));
        } else {
            ret = "API 찾을수 없음";
        }
        out.print(ret);
    }
}
%>