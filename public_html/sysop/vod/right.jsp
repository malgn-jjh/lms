<%@ page import="java.io.FileNotFoundException" %>
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

if(!Menu.accessible(31, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

String path = m.decode(m.rs("path"));
int ln = 200;

if(m.isPost()) {
	try{
		//새폴더
		if("CREATE_DIR".equals(m.rs("mode"))) {
			String newfolder = "newfoloder";
			String nPath = "";
			File file = new File(path + "/" + newfolder + "/tmp.tmp");
			int i = 0;
			do {
				nPath = file.getParentFile().getParentFile().toString() + "/" + newfolder + (i > 0 ? i + "" : "") + "/tmp.tmp";
				file = new File(nPath);
				i++;
			} while(file.getParentFile().exists());

			if(!file.getParentFile().isDirectory()) {
				file.getParentFile().mkdirs();
			}

			m.setCookie("NEWFOLDER", m.encode(file.getParentFile().toString()));
			out.print("<script>parent.parent._LEFT.location.href = parent.parent._LEFT.location.href;</script>");
			out.print("<script>parent.location.href = parent.location.href;</script>");
			return;
		}
		//이름변경
		if("RENAME".equals(m.rs("mode"))) {
			if("".equals(m.rs("new_name").trim())) {
				m.jsAlert("이름을 입력하세요.");
				return;
			}
			File file = new File(new File(path) + "/" + m.rs("new_name").trim());
			if(file.exists()) {
				m.jsAlert("동일한 이름의 존재합니다.");
				return;
			} else {
				new File(path + "/" + m.rs("org_name")).renameTo(file);
				out.print("<script>parent.parent._LEFT.location.href = parent.parent._LEFT.location.href;</script>");
				out.print("<script>parent.location.href = parent.location.href;</script>");
				return;
			}
		}
	}catch(FileNotFoundException fnfe) {
		out.print("<script>top.location.href = top.location.href;</script>");
		return;
	}catch(Exception e) {
		out.print("<script>top.location.href = top.location.href;</script>");
		return;
	}
}

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
	list.put("id", m.encrypt(list.s("path")));
	list.put("is_new", list.s("path_ec").equals(m.getCookie("NEWFOLDER")));
}

//출력
p.setLayout(ch);
p.setBody("vod.right");
p.setVar("form_script", f.getScript());
p.setLoop("list", list);
p.setVar("query", m.qs());
p.setVar("list_total", fm.getTotalString());
p.setVar("pagebar", fm.getTotalNum() <= ln ? "" : fm.getPaging());
p.setVar("SYS_BODY_STR", " oncontextmenu=\"new MContextMenu('context', event, { path_ec:'' }); return false;\"");
p.setVar("decode_path", path);
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