<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/init.jsp" %>
<%
	
	String filePath = f.get("filepath").replace("..", "");

	File image = new File(dataDir + "/file/" + filePath);
    if (image.exists()) {
        image.delete();
    }

    String absolutePath = image.getAbsolutePath();
    String thumbPath = absolutePath.substring(0, absolutePath.lastIndexOf(File.separator)+1);
    String thumbName = "thumb_" + absolutePath.substring(absolutePath.lastIndexOf(File.separator)+1);

	File thumb = new File(thumbPath+thumbName);
    if (thumb.exists()) {
        thumb.delete();
    }
%>