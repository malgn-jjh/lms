<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/init.jsp" %>
<%

if(!m.isPost()) return;

String saveFileName = f.getFileName("file");
String fileType = "image/" + m.getFileExt(saveFileName);

String ext = m.getFileExt(saveFileName).toLowerCase();
if(!"gif".equals(ext) && !"jpg".equals(ext) && !"jpeg".equals(ext) && !"png".equals(ext)) {
    throw new Exception("-ERR: No Image File");
}

File file = f.saveFile("file", dataDir + "/file/" + saveFileName);
if (file == null) {
    throw new Exception("-ERR: No File");
}

long fileSize = file.length();
if (fileSize < 1) {
    throw new Exception("-ERR: File Size 0");
}

String module = mSession.s("file_module");
int moduleId = mSession.i("file_module_id");

FileDao fileDao = new FileDao();
if(!"".equals(module) && moduleId != 0) {
    fileDao.item("module", module);
    fileDao.item("module_id", moduleId);
} else {
    fileDao.item("module", "editor");
    fileDao.item("module_id", 0);
}
fileDao.item("site_id", siteId);
fileDao.item("filename", saveFileName);
fileDao.item("filetype", fileType);
fileDao.item("filesize", fileSize);
fileDao.item("realname", saveFileName);
fileDao.item("main_yn", "N");
fileDao.item("download_yn", "N");
fileDao.item("reg_date", m.getTimeString("yyyyMMddHHmmss"));
fileDao.item("status", 1);
fileDao.insert();

try {
    String imgPath = dataDir + "/file/" + saveFileName;
    String cmd = "convert -resize 1100x> " + imgPath + " " + imgPath;
    Runtime.getRuntime().exec(cmd);
}
catch(RuntimeException re) { m.errorLog("RuntimeException : " + re.getMessage(), re); }
catch(Exception e) { m.errorLog("Exception : " + e.getMessage(), e); }

String rData = String.format("{\"fileUrl\":\"%s%s\", \"filePath\":\"%s\", \"fileName\":\"%s\", \"fileSize\":\"%d\"}", ("mail".equals(m.rs("mode")) ? "http://" + request.getServerName() : ""), "/data/file/" + saveFileName, saveFileName, saveFileName, fileSize);

out.println(rData);


%>