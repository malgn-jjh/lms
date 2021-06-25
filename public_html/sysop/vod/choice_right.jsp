<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

if(!Menu.accessible(31, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

String cd = m.rs("cd", "MEDIA");

String path = m.decode(m.rs("path"));

if("".equals(path)) path = dataDir + "/Contents/" + cd;

int ln = 200;

//폼체크
f.addElement("s_field", null, null);
f.addElement("s_keyword", null, null);

//파일목록
FileListManager fm = new FileListManager(path);
fm.setRequest(request);
fm.setMode("ALL");
fm.setListNum(ln);
fm.addSearch("name", f.get("s_keyword"), "like");
//fm.addSearch("type", f.get("s_ft"), "");
//fm.addBetween("field", "svalue", "evalue");
fm.setOrderBy(!"".equals(m.request("ord")) ? m.request("ord").trim() : "name ASC");
DataSet list = fm.getDataSet();

//포멧팅
while(list.next()) {
	list.put("date_conv", m.time("yyyy-MM-dd HH:mm:ss", list.s("date")));
	list.put("length", getFileSize(list.l("length")));
	list.put("path_ec", m.encode(list.s("path")));
	list.put("url", m.replace(list.s("path"), docRoot, Config.getWebUrl()));
	list.put("id", m.encrypt(list.s("path")));
	list.put("is_new", list.s("path_ec").equals(m.getCookie("NEWFOLDER")));
}


//출력
p.setLayout(ch);
p.setBody("vod.choice_right");
p.setVar("form_script", f.getScript());
p.setLoop("list", list);
p.setVar("query", m.qs());
p.setVar("list_total", fm.getTotalString());
p.setVar("pagebar", fm.getTotalNum() <= ln ? "" : fm.getPaging());
p.setVar("decode_path", path);
p.setVar("sel_left",  m.encrypt(path));
p.setVar("SYS_TABLE_WIDTH", "100%");
p.setVar("field", "MOBILE_A".equals(cd) ? "mobile_a" : ("MOBILE_I".equals(cd) ? "mobile_i" : "start_url"));
p.setVar("choice_block", true);
p.display(out);

%>
<%!
public String getFileSize(long size) {
	if(size >= 1024 * 1024 * 1024) return (int)Math.ceil(size / (1024.0 * 1024 * 1024)) + " GB";
	else if(size >= 1024 * 1024) return (int)Math.ceil(size / (1024.0 * 1024)) + " MB";
	else if(size >= 1024) return (int)Math.ceil(size / 1024.0) + " KB";
	else return (int)Math.ceil(size * 1.0) + " B";
}
%>