<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="javax.imageio.IIOImage" %>
<%@ page import="javax.imageio.ImageIO" %>
<%@ page import="javax.imageio.ImageWriteParam" %>
<%@ page import="javax.imageio.ImageWriter" %>
<%@ page import="javax.imageio.stream.FileImageOutputStream" %>
<%@ page import="javax.imageio.stream.ImageOutputStream" %>
<%@ include file="/init.jsp" %>
<%

String SAVE_DIR = dataDir + "/file/";

if(!m.isPost()) return;


long fileSize = 0;
String saveFileName = f.get("randomname");
String fileName = f.get("origname");
String fileType = "image/";
String base64Img = f.get("filehtml5");

String ext = m.getFileExt(saveFileName).toLowerCase();
if(!"gif".equals(ext) && !"jpg".equals(ext) && !"jpeg".equals(ext) && !"png".equals(ext)) {
	throw new Exception("-ERR: No Image File");
}

if (!"".equals(base64Img)) {
	base64Img = base64Img.substring(base64Img.indexOf(",")+1, base64Img.length());
	byte[] buffer = Base64Coder.dec(base64Img);
	float quality = 1.0f;

	saveFileName = f.get("randomname");
	File file = new File(SAVE_DIR + saveFileName);

	OutputStream oStream = new FileOutputStream(file);
	BufferedImage image = ImageIO.read(new ByteArrayInputStream(buffer));

	String format = saveFileName.substring(saveFileName.lastIndexOf(".") + 1);
	fileType += format;
	Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName(format);
	if (!writers.hasNext()) {
		throw new IllegalStateException("-ERR: No writers found");
	}

	ImageWriter writer = (ImageWriter)writers.next();
	ImageOutputStream ios = ImageIO.createImageOutputStream(oStream);
	writer.setOutput(ios);

	ImageWriteParam param = null;
	if (format.equalsIgnoreCase("jpg")) {
		param = writer.getDefaultWriteParam();
		param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
		param.setCompressionQuality(quality);
	}

	writer.write(null, new IIOImage(image, null, null), param);
	oStream.close();
	ios.close();
	writer.dispose();

	fileSize = file.length();
}
else {

	//File file = f.saveFile("file", SAVE_DIR + saveFileName);
	File file = f.saveFile("file");
	if (file == null) {
		throw new Exception("-ERR: No File");
	}
	fileSize = file.length();
	fileName = f.getFileName("file");
	fileType = f.getFileType("file");
	saveFileName = file.getName();
}

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
fileDao.item("filename", fileName);
fileDao.item("filetype", fileType);
fileDao.item("filesize", fileSize);
fileDao.item("realname", saveFileName);
fileDao.item("main_yn", "N");
fileDao.item("download_yn", "N");
fileDao.item("reg_date", m.getTimeString("yyyyMMddHHmmss"));
fileDao.item("status", 1);
fileDao.insert();

if(fileSize > 500000) {
	try {
		String imgPath = SAVE_DIR + saveFileName;
		String cmd = "convert -resize 1200x\\> " + imgPath + " " + imgPath;
		Runtime.getRuntime().exec(cmd);
		Thread.sleep(500);
	}
	catch(Exception e) { }
}
String rData = String.format("{\"fileUrl\":\"%s%s\", \"filePath\":\"%s\", \"fileName\":\"%s\", \"fileSize\":\"%d\"}"
						, ("mail".equals(m.rs("mode")) ? "http://" + request.getServerName() : "")
						+ "/data/file/", saveFileName, saveFileName, saveFileName, fileSize);

//m.log("chupload", rData);
out.println(rData);


%>