<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../init.jsp" %><%

if(!Menu.accessible(31, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

if("CALL".equals(m.rs("mode"))) {

	String line;
	String cmd = "df -h";
	Process proc = Runtime.getRuntime().exec(cmd);
	BufferedReader input = new BufferedReader(new InputStreamReader(proc.getInputStream()));
	DataSet disk = new DataSet();
	DataSet info = new DataSet();
	int cnt = 0;
	while((line = input.readLine()) != null) {
		if(cnt > 0) {
			disk.addRow();
			String[] tmp = line.split("\\s+");
			if(tmp.length == 6) {
				disk.put("filesystem", tmp[0]);
				disk.put("size", tmp[1]);
				disk.put("used", tmp[2]);
				disk.put("avail", tmp[3]);
				disk.put("p_used", m.replace(tmp[4], "%", ""));
				disk.put("p_avail", 100 - disk.i("p_used"));
				disk.put("mountedon", tmp[5]);
			}
			if(disk.s("mountedon").equals("/home")) {
				info.addRow(disk.getRow());
			}
		}
		cnt++;
	}
	input.close();

	out.print("<table class=\"disk01\" cellpadding=\"0\" cellspacing=\"0\">");
	out.print("<tr><td colspan=\"2\" style=\"text-align:center;\">");
	out.print(
		"<img width=\"170\" height=\"118\" src=\"http://chart.apis.google.com/chart?cht=p3"
		+ "&chco=FF00DD&chd=t:" + info.i("p_used")
		+ "," + info.i("p_avail")
		+ "&chs=170x118\">"
	);
	out.print("</td></tr>");
	out.print("<tr><th>Size:</th><td>" + info.s("size") + "</td></tr>");
	out.print("<tr><th>Used:</th><td>" + info.s("used") + " (" + info.s("p_used") + "%)</td></tr>");
	out.print("<tr><th>Avail:</th><td>" + info.s("avail") + "</td></tr>");
	out.print("<tr height=\"10\"><td colspan=\"2\"></td></tr>");
	out.print("</table>");

	return;

}

String path = m.decode(m.rs("path"));
File attach = f.saveFile("filename", path);
if(null != attach) {
	if("zip".equals(m.getFileExt(f.getFileName("filename")).toLowerCase())) {

		Zip zip = new Zip();

		String tmpf = f.getFileName("filename").substring(0, f.getFileName("filename").lastIndexOf("."));
		if(!"".equals(tmpf)) tmpf = "/" + tmpf;

		File dfd = new File(path + tmpf);
		if(!dfd.exists()) { dfd.mkdirs(); };
		zip.extract(attach, path + tmpf);
	}
}

//업로드제한
String deny = "jsp;java";

//출력
p.setLayout("blank");
p.setBody("vod.upload");
p.setVar("p_title", "파일올리기");
p.setVar("form_script", f.getScript());
p.setVar("list_query", m.getQueryString("id"));
p.setVar("query", m.getQueryString(""));
p.setVar("max_file_size", m.reqInt("fs", 1024 * 1000 * 2));
p.setVar("web_url", Config.getWebUrl());
p.setVar("limit_str", !"".equals(deny) ? ";" + deny.replace("|", ";") : "");
p.display(out);


%>