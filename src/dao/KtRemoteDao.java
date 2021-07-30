package dao;

import malgnsoft.db.*;
import malgnsoft.util.*;
import malgnsoft.json.*;
import java.util.*;
import java.io.*;

final public class KtRemoteDao extends DataObject {

    private int siteId = 0;
    private String baseUrl = "https://211.253.11.217:30126/v2/link/";
    private String serviceId = "DEV_TH_MALGNSOFT";
    private String serviceIp = "0.0.0.0";
    private String contentType = "application/json";
    private String authToken = "";

    private Http http = new Http();

    public KtRemoteDao() {

    }

    public KtRemoteDao(int siteId) {
        this.siteId = siteId;
    }

    public void setDebug(Writer out) {
        this.http.setDebug(out);
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

        http.setUrl(baseUrl + "auth");
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

    public String createPlan(String type, String title, String courseUserId, int maxUserCnt, DataSet members, int monitorType, long startDate, long endDate) {
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

            http.setUrl(baseUrl + "plans/create");
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

    public boolean updatePlan(String planId) {
        return updatePlan(planId, null, null, 0, null, 0, null, 0, 0);
    }

    public boolean updatePlan(String planId, String title, String courseUserId, int maxUserCnt, DataSet members, int monitorType, int[] fields, long startDate, long endDate) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("planId", planId);
            if(null != title) jsonObject.put("title", title);
            if(null != courseUserId) jsonObject.put("userId", courseUserId);
            if(0 != maxUserCnt) jsonObject.put("maxMembers", maxUserCnt);
            if(null != members) jsonObject.put("members", members);
            if(0 != monitorType) jsonObject.put("monitorType", monitorType);
            if(null != fields) jsonObject.put("fields", fields);
            if(0 != startDate) jsonObject.put("startDate", startDate);
            if(0 != endDate) jsonObject.put("endDate", endDate);

            http.setUrl(baseUrl + "plans/update");
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

    public boolean deletePlan(String planId, String courseUserId) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("planId", planId);
            jsonObject.put("userId", courseUserId);

            http.setUrl(baseUrl + "plans/delete");
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

    public String insertMember(String planId, String courseUserId, String nickName, String userType, String mobile, String userToken) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("userId", courseUserId);
            jsonObject.put("name", nickName);
            jsonObject.put("userType", userType);
            jsonObject.put("phone", mobile);
            jsonObject.put("userToken", userToken);

            http.setUrl(baseUrl + "plans/" + planId + "/members/create");
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

    public boolean updateMember(String planId, String courseUserId ,String nickName, String userType, String mobile) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("userId", courseUserId);
            jsonObject.put("name", nickName);
            jsonObject.put("userType", userType);
            jsonObject.put("phone", mobile);

            http.setUrl(baseUrl + "plans/" + planId + "/members/update");
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

    public boolean deleteMember(String planId, String courseUserId) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("userId", courseUserId);

            http.setUrl(baseUrl + "plans/" + planId + "/members/delete");
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

    public String getUserToken(String planId, String courseUserId) {
        try {
            //토큰 만드는 로직 필요
            String userToken = courseUserId + "";

            JSONObject jsonObject = new JSONObject();
            jsonObject.put("userToken", userToken);

            http.setUrl(baseUrl + "plans/" + planId + "/members/" + courseUserId + "/token");
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

    public DataSet getAttendList(long startTime, long endTime) {
        DataSet result = new DataSet();
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("start_time", startTime);
            jsonObject.put("end_time", endTime);

            http.setUrl(baseUrl + "logs/plans");
            http.setHeader("Content-Type", contentType);
            http.setHeader("Authorization", "Bearer " + authToken);
            http.setData(jsonObject.toString());

            Json j = new Json(http.send("GET"));
            if (200 != j.getInt("//code")) {
                Malgn.errorLog("KtRemoteDao.getAttendList() : " + j.toString());
                return result;
            }
            result.unserialize(j.getString("//result"));
            return result;
        } catch (NullPointerException npe) {
            Malgn.errorLog("KtRemoteDao.getAttendList() : " + npe.getMessage());
            return result;
        }
    }

    public DataSet getPlanHistory(String planId) {
        DataSet result = new DataSet();
        try {
            http.setUrl(baseUrl + "logs/plans/" + planId);
            http.setHeader("Content-Type", contentType);
            http.setHeader("Authorization", "Bearer " + authToken);

            Json j = new Json(http.send("GET"));
            if (200 != j.getInt("//code")) {
                Malgn.errorLog("KtRemoteDao.getPlanHistory() : " + j.toString());
                return result;
            }

            result.unserialize(j.getString("//result/members"));
            return result;
        } catch (NullPointerException npe) {
            Malgn.errorLog("KtRemoteDao.getPlanHistory() : " + npe.getMessage());
            return result;
        }
    }
}