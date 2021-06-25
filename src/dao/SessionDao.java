package dao;

import java.util.*;
import java.net.URLEncoder;
import java.net.URLDecoder;

import malgnsoft.util.*;
import malgnsoft.json.*;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class SessionDao {

	private HttpServletRequest request;
	private HttpServletResponse response;
	private static String encoding = Config.getEncoding();
	private String sessionId;
	private String dataString = "";
	private JSONObject dataJson;

	private String keyName = "_sessdata";
	public int maxAge = -1;

	public SessionDao(HttpServletRequest request, HttpServletResponse response) {
		this.request = request;
		this.response = response;

		Cookie[] cookies = request.getCookies();
		if(cookies != null) {
			for(int i = 0; i < cookies.length; i++) {
				if(cookies[i].getName().equals(keyName)) {
					dataString = decodeData(cookies[i].getValue());
					dataJson = new JSONObject(dataString);
				}
			}
		}

		if("".equals(dataString)) {
			sessionId = Malgn.sha1("" + System.currentTimeMillis() + Malgn.getUniqId());
			dataString = "{\"id\":\"" + sessionId + "\"}";
			dataJson = new JSONObject(dataString);
			Cookie cookie = new Cookie(keyName, encodeData(dataString));
			cookie.setMaxAge(maxAge);
			cookie.setPath("/");
			if(request.isSecure()) cookie.setSecure(true);
			response.addCookie(cookie);
		}
	}

	private final String decodeData(String encodedString) {
		try {
			return URLDecoder.decode(SimpleAES.decrypt(encodedString), "UTF-8");
		} catch(Exception e) {
			Malgn.errorLog("SessionDao.decodeData() : " + e.getMessage(), e);
			return "";
		}

	}

	private final String encodeData(String dataString) {
		try {
			return SimpleAES.encrypt(URLEncoder.encode(dataString, "UTF-8"));
		} catch(Exception e) {
			Malgn.errorLog("SessionDao.encodeData() : " + e.getMessage(), e);
			return "";
		}
	}

	public boolean delSession() {
		Cookie cookie = new Cookie(keyName, "");
		cookie.setMaxAge(0);
		cookie.setPath("/");
		response.addCookie(cookie);
		return true;
	}

	public String getData() { return dataString; }

	public void save() {
		try {
			dataString = dataJson.toString();
			Cookie cookie = new Cookie(keyName, encodeData(dataString));
			cookie.setPath("/");
			if(request.isSecure()) cookie.setSecure(true);
			response.addCookie(cookie);
		} catch(Exception e) {
			Malgn.errorLog("SessionDao.save() : " + e.getMessage(), e);
		}
	}

	public String s(String key) {
		return getString(key);
	}

	public int i(String key) {
		return getInt(key);
	}

	public int getInt(String key) {
		return dataJson.isNull(key) ? 0 : dataJson.getInt(key);
	}

	public String getString(String key) {
		return dataJson.isNull(key) ? "" : dataJson.getString(key);
	}

	public void put(String key, Object value) {
		dataJson.put(key, value);
	}
}