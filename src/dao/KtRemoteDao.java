package dao;

import malgnsoft.db.*;
import malgnsoft.util.*;
import malgnsoft.json.*;
import java.util.*;

final public class KtRemoteDao extends DataObject {

    private int siteId = 0;
    private String baseUrl = "https://211.253.11.217:30126/v2/link/";
    private String serviceId = "DEV_TH_MALGNSOFT";
    private String serviceIp = "0.0.0.0";
    private String contentType = "application/json";
    private String authToken = "";

    public KtRemoteDao() {

    }

    public KtRemoteDao(int siteId) {
        this.siteId = siteId;
    }

    public void setAuthToken(String authToken) {
        this.authToken = authToken;
    }

    public String getAuthToken() {
        String tokenTime = System.currentTimeMillis() + "";
        String authHash = "service_id=" + serviceId + "&time" + tokenTime + "&service_ip=" + serviceIp;

        JSONObject jsonObject = new JSONObject();
        jsonObject.put("serviceId", serviceId);
        jsonObject.put("tokenTime", tokenTime);
        jsonObject.put("authHash", Malgn.sha256(authHash));

        Http http = new Http(baseUrl + "auth");
        http.setHeader("Content-Type", contentType);
        http.setData(jsonObject.toString());

        Json j = new Json(http.send("POST"));
        if (200 != j.getInt("//code")) {
            Malgn.errorLog("KtRemoteDao.getAuthToken() : " + j.toString());
            return "";
        }
        return j.getString("//result/authToken");
    }

    public void setBaseUrl(String url) {
        this.baseUrl = url;
    }

    public String createPlan(String type, String title, int courseUserId, int maxUserCnt, DataSet members, int monitorType, long startDate, long endDate) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("type", type);
            jsonObject.put("title", title);
            jsonObject.put("userId", courseUserId);
            jsonObject.put("maxMembers", maxUserCnt);
            jsonObject.put("members", members);
            jsonObject.put("monitorType", monitorType);
            jsonObject.put("startDate", startDate);
            jsonObject.put("endDate", endDate);

            Http http = new Http(baseUrl + "plans/create");
            http.setHeader("Content-Type", contentType);
            http.setHeader("Authorization", "Bearer " + authToken);
            http.setData(jsonObject.toString());

            Json j = new Json(http.send("POST"));
            if (200 != j.getInt("//code")) {
                Malgn.errorLog("KtRemoteDao.createPlan() : " + j.toString());
                return "";
            }
            return j.getString("//result/planId");
        } catch (NullPointerException npe) {
            Malgn.errorLog("KtRemoteDao.createPlan() : " + npe.getMessage());
            return "";
        }
    }

    public boolean updatePlan(String planId, String title, int courseUserId, int maxUserCnt, DataSet members, int monitorType, int[] fields, long startDate, long endDate) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("planId", planId);
            jsonObject.put("title", title);
            jsonObject.put("userId", courseUserId);
            jsonObject.put("maxMembers", maxUserCnt);
            jsonObject.put("members", members);
            jsonObject.put("fields", fields);
            jsonObject.put("startDate", startDate);
            jsonObject.put("endDate", endDate);

            Http http = new Http(baseUrl + "plans/update");
            http.setHeader("Content-Type", contentType);
            http.setHeader("Authorization", "Bearer " + authToken);
            http.setData(jsonObject.toString());

            Json j = new Json(http.send("POST"));
            if (200 != j.getInt("//code")) {
                Malgn.errorLog("KtRemoteDao.updatePlan() : " + j.toString());
                return false;
            }
            return true;
         } catch (NullPointerException npe) {
            Malgn.errorLog("KtRemoteDao.createPlan() : " + npe.getMessage());
            return false;
        }
    }

    public boolean deletePlan(String planId, int courseUserId) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("planId", planId);
            jsonObject.put("userId", courseUserId);

            Http http = new Http(baseUrl + "plans/delete");
            http.setHeader("Content-Type", contentType);
            http.setHeader("Authorization", "Bearer " + authToken);
            http.setData(jsonObject.toString());

            Json j = new Json(http.send("POST"));
            if (200 != j.getInt("//code")) {
                Malgn.errorLog("KtRemoteDao.deletePlan() : " + j.toString());
                return false;
            }
            return true;
        } catch (NullPointerException npe) {
            Malgn.errorLog("KtRemoteDao.deletePlan() : " + npe.getMessage());
            return false;
        }
    }

    public String uploadFile(String planId) {
        String method = "POST";
        String url = planId + "/files";
        return "";
    }

    public String insertMember(String planId, int courseUserId, String nickName, String userType, String mobile, String userToken) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("userId", courseUserId);
            jsonObject.put("name", nickName);
            jsonObject.put("userType", userType);
            jsonObject.put("phone", mobile);
            jsonObject.put("userToken", userToken);

            Http http = new Http(baseUrl + "plans/" + planId + "/members/create");
            http.setHeader("Content-Type", contentType);
            http.setHeader("Authorization", "Bearer " + authToken);
            http.setData(jsonObject.toString());

            Json j = new Json(http.send("POST"));
            if (200 != j.getInt("//code")) {
                Malgn.errorLog("KtRemoteDao.insertMember() : " + j.toString());
                return "";
            }
            return !"".equals(userToken) ? j.getString("//result/linkUrl") : "";
        } catch (NullPointerException npe) {
            Malgn.errorLog("KtRemoteDao.insertMember() : " + npe.getMessage());
            return "";
        }
    }

    public String insertMembers(String planId, DataSet courseUsers) {
        return "";
    }

    public boolean updateMember(String planId, int courseUserId ,String nickName, String userType, String mobile) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("userId", courseUserId);
            jsonObject.put("name", nickName);
            jsonObject.put("userType", userType);
            jsonObject.put("phone", mobile);

            Http http = new Http(baseUrl + "plans/" + planId + "/members/update");
            http.setHeader("Content-Type", contentType);
            http.setHeader("Authorization", "Bearer " + authToken);
            http.setData(jsonObject.toString());

            Json j = new Json(http.send("POST"));
            if (200 != j.getInt("//code")) {
                Malgn.errorLog("KtRemoteDao.updateMember() : " + j.toString());
                return false;
            }
            return true;
        } catch (NullPointerException npe) {
            Malgn.errorLog("KtRemoteDao.updateMember() : " + npe.getMessage());
            return false;
        }
    }

    public String updateMembers(String planId, DataSet courseUsers) {
        return "";
    }

    public boolean deleteMember(String planId, int courseUserId) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("userId", courseUserId);

            Http http = new Http(baseUrl + "plans/" + planId + "/members/delete");
            http.setHeader("Content-Type", contentType);
            http.setHeader("Authorization", "Bearer " + authToken);
            http.setData(jsonObject.toString());

            Json j = new Json(http.send("POST"));
            if (200 != j.getInt("//code")) {
                Malgn.errorLog("KtRemoteDao.deleteMember() : " + j.toString());
                return false;
            }
            return true;
        } catch (NullPointerException npe) {
            Malgn.errorLog("KtRemoteDao.deleteMember() : " + npe.getMessage());
            return false;
        }
    }

    public String deleteMembers(String planId, DataSet courseUsers) {
        return "";
    }

    public String getUserToken(String planId, int courseUserId) {
        try {
            //토큰 만드는 로직 필요
            String userToken = courseUserId + "";

            JSONObject jsonObject = new JSONObject();
            jsonObject.put("userToken", userToken);

            Http http = new Http(baseUrl + "plans/" + planId + "/members/" + courseUserId + "/token");
            http.setHeader("Content-Type", contentType);
            http.setHeader("Authorization", "Bearer " + authToken);
            http.setData(jsonObject.toString());

            Json j = new Json(http.send("POST"));
            if (200 != j.getInt("//code")) {
                Malgn.errorLog("KtRemoteDao.getUserToken() : " + j.toString());
                return "";
            }
            return j.getString("//result/linkUrl");
        } catch (NullPointerException npe) {
            Malgn.errorLog("KtRemoteDao.getUserToken() : " + npe.getMessage());
            return "";
        }
    }

    public DataSet getAttendList() {
        DataSet list = new DataSet();
        return list;
    }

    public DataSet getPlanHistory(int siteId) {
        DataSet list = new DataSet();
        return list;
    }
}