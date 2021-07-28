package dao;

import malgnsoft.db.*;
import malgnsoft.util.*;
import java.util.*;

final public class KtRemoteDao extends DataObject {

    private int siteId = 0;
    private String baseUrl = "https://211.253.11.217:30126/v2/link/";
    private String authHash = "";

    public KtRemoteDao(int siteId) {
        this.siteId = siteId;
    }

    public void setAuthHash(String authHash) {
        this.authHash = authHash;
    }

    public String getAuthHash() {
        return authHash;
    }

    public void setBaseUrl(String url) {
        this.baseUrl = url;
    }

    public String createPlan() {
        return "";//planId
    }

    public boolean updatePlan() {
        return false;
    }

    public boolean deletePlan(String planId, int cuid) {
        return false;
    }

    public String uploadFile(String planId) {
        String method = "POST";
        String url = planId + "/files";
        return "";
    }

    public String insertMember(DataSet courseUser) {
        return "";
    }

    public String updateMember(DataSet courseUser) {
        return "";
    }

    public String deleteMember(int courseUserId) {
        return "";
    }

}