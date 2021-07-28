<%@ page import="java.io.IOException" %>
<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

if(!Menu.accessible(31, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

String path = m.rs("path");
if("".equals(path)) {
	m.jsAlert("경로는 반드시 지정해야 합니다.");
	return;
}

path = m.decode(path);

//객체
FileLogDao fileLog = new FileLogDao(request);
File file = new File(path);
if(file.exists()){
	if(!fileLog.addLog(userId, fileLog.file2info(siteId, file))) { }
	try{
		String filename = file.getName();
		response.setContentType( "application/octet-stream;" );
		response.setContentLength( (int)file.length() );
		response.setHeader( "Content-Disposition", "attachment; filename=\"" + new String(filename.getBytes("KSC5601"),"8859_1") + "\"" );
	//  response.setHeader( "Content-Disposition", "attachment; filename=\"" + filename + "\"" );

		byte[] bbuf = new byte[2048];
		BufferedInputStream fin = new BufferedInputStream(new FileInputStream(file));
		BufferedOutputStream outs = new BufferedOutputStream(response.getOutputStream());
		int read = 0;
		while ((read = fin.read(bbuf)) != -1){
			outs.write(bbuf, 0, read);
		}
		outs.close();
		fin.close();
	}catch(IOException ioe) {
		m.jsAlert("File I/O Error. " + ioe.getMessage());
	}catch(Exception e) {
		m.jsAlert("File I/O Error. " + e.getMessage());
	}

} else {
	m.jsAlert("해당 파일이 존재하지 않습니다.");
	return;
}

%>