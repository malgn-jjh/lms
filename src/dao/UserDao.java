package dao;

import malgnsoft.db.*;
import malgnsoft.util.*;
import java.util.Arrays;

public class UserDao extends DataObject {

	public String[] statusList = { "1=>정상", "0=>중지", "30=>휴면대상", "-2=>탈퇴" };
	public String[] kinds = { "U=>회원", "C=>과정운영자", "D=>소속운영자", "A=>운영자", "S=>최고관리자" };
	public String[] adminKinds = { "C=>과정운영자", "D=>소속운영자", "A=>운영자", "S=>최고관리자" };
	//public String[] bkinds = { "A=>운영자", "C=>과정운영자", "T=>강사", "U=>회원" };
	//public String[] adminList = {"T=>담당강사", "A=>관리자"};
	public String[] genders = { "1=>남성", "2=>여성" };
	public String[] receiveYn = { "Y=>수신동의", "N=>수신거부" };
	public String[] displayYn = { "Y=>노출", "N=>숨김" };

	public String[] statusListMsg = { "1=>list.user.status_list.1", "0=>list.user.status_list.0", "30=>list.user.status_list.30" };
	public String[] kindsMsg = { "U=>list.user.kinds.U", "C=>list.user.kinds.C", "D=>list.user.kinds.D", "A=>list.user.kinds.A", "S=>list.user.kinds.S" };
	public String[] adminKindsMsg = { "C=>list.user.admin_kinds.C", "D=>list.user.admin_kinds.D", "A=>list.user.admin_kinds.A", "S=>list.user.admin_kinds.S" };
	public String[] gendersMsg = { "1=>list.user.genders.1", "2=>list.user.genders.2" };
	public String[] receiveYnMsg = { "Y=>list.user.receive_yn.Y", "N=>list.user.receive_yn.N" };
	public String[] displayYnMsg = { "Y=>list.user.display_yn.Y", "N=>list.user.display_yn.N" };

	public String[] ordList = {
								"id asc=>a.id asc", "id desc=>a.id desc", "nm asc=>a.user_nm asc", "nm desc=>a.user_nm desc"
								, "rg asc=>a.reg_date asc", "rg desc=>a.reg_date desc", "st asc=>t.sort asc", "st desc=>t.sort desc"
							};

	//배열-삭제필드검색용-오름차순으로
	//public String[] deleteWhiteList = {"conn_date", "dept_id", "id", "login_id", "reg_date", "site_id", "sleep_date", "status", "user_kind", "user_nm"};
	//public String[] deleteIntList = {};

	public UserDao() {
		this.table = "TB_USER";
		this.PK = "id";
	}
	
	public DataSet getManagers(int siteId) {
		return getManagers(siteId, "C|A|S");
	}

	public DataSet getManagers(int siteId, String userKind) {
		DataSet list = find(
			"status = 1 AND user_kind IN ('" + Malgn.join("', '", Malgn.split("|", userKind)) + "') AND site_id = " + siteId + ""
			, "*", "user_kind ASC, user_nm ASC"
		);
		while(list.next()) {
			list.put("kind_conv", Malgn.getItem(list.s("user_kind"), this.kinds));
		}
		list.first();
		return list;
	}

	public String maskName(String value, int pointer) {
		return value.replaceAll("(?<=.{" + pointer + "}).", "*");
	}

	public boolean deleteUser(int userId) {
		if(0 == userId) return false;
		DataSet uinfo = this.find("id = " + userId + " AND status != -1");
		if(!uinfo.next()) return false;

		this.item("user_nm", "[탈퇴]");
		this.item("email", "");
		this.item("mobile", "");
		this.item("passwd", "");
		this.item("access_token", "");
		this.item("gender", "");
		this.item("birthday", "");
		this.item("zipcode", "");
		this.item("addr", "");
		this.item("new_addr", "");
		this.item("addr_dtl", "");
		this.item("etc1", "");
		this.item("etc2", "");
		this.item("etc3", "");
		this.item("etc4", "");
		this.item("etc5", "");
		this.item("dupinfo", "");
		this.item("oauth_vendor", "");
		this.item("status", -1);
		return this.update("id = " + userId);
	}
}