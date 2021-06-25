<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../init.jsp" %><%

//���Է�
String module = m.rs("md", "post");
int moduleId = m.ri("mid");
String tgt = m.rs("tgt", "content");

String allow = m.rs("allow", "image,media,file");

//��ü
FileDao file = new FileDao();
PostDao post = new PostDao();

//����
if("del".equals(m.rs("mode")) && m.ri("id") > 0) {

	DataSet info = file.get(m.ri("id"));
	if(!info.next()) {
		m.jsError("�ش� ������ �����ϴ�.");
		return;
	}
	if(file.delete(info.i("id"))) {
		if(!"".equals(info.s("filename"))) m.delFileRoot(m.getUploadPath(info.s("filename")));
	}
	m.jsReplace("attach.jsp?" + m.qs("id, mode"));
	return;
}

//��ǥ�̹�������
if("mod".equals(m.rs("mode")) && m.ri("id") > 0) {
	DataSet info = file.get(m.ri("id"));
	if(!info.next()) {
		m.jsError("�ش� ������ �����ϴ�.");
		return;
	}
	if(-1 != file.execute("UPDATE " + file.table + " SET main_yn = 'N' WHERE module = '" + module + "' AND module_id = '" + moduleId + "'")) {
		file.item("main_yn", "Y");
		if(!file.update()) { }
	}
	m.jsReplace("attach.jsp?" + m.qs("id, mode"));
	return;
}

//�Խù��� �������� ������Ʈ
if(module.equals("post") && moduleId > 0) post.updateFileCount(moduleId);

//��ǥ�̹�������˻�
boolean exists = file.findCount("module = '" + module + "' AND module_id = '" + moduleId + "' AND main_yn = 'Y'") == 1;

//���
DataSet list = file.query(
	"SELECT a.* FROM " + file.table + " a"
	+ " WHERE a.module = '" + module + "' AND a.module_id = '" + moduleId + "'"
	+ " ORDER BY a.id ASC"
);

//������
int no = 0;
while(list.next()) {
	boolean isImage = list.s("filename").toLowerCase().matches("^(.+)\\.(jpg|jpeg|gif|png)$");
	if(!exists && isImage) { //��ǥ�̹����� ���°�� ù ��° �̹����� �ڵ�����
		file.execute("UPDATE " + file.table + " SET main_yn = 'Y' WHERE id = " + list.i("id"));
		list.put("main_yn", "Y");
		exists = true;
	}
	list.put("__idx", ++no);
	list.put("reg_date_conv", m.time("yyyy.MM.dd HH:mm", list.s("reg_date")));
	list.put("checked", "Y".equals(list.s("main_yn")) ? "checked" : "");
	list.put("ext", file.getFileIcon(list.s("filename")));
	list.put("ek", m.encrypt(list.s("id")));
	list.put("filename_conv", m.urlencode(Base64Coder.encode(list.s("filename"))));
	list.put("fileurl", m.getUploadUrl(list.s("filename")));
	if("manual".equals(module)) list.put("fileurl", "http://" + Site.getCenterWebUrl() + m.getUploadUrl(list.s("filename")));
	list.put("is_img", isImage);
}

//����Ÿ��
Hashtable<String, String> types = new Hashtable<String, String>();
types.put("image", "false"); types.put("media", "false"); types.put("file", "false");
String[] allows = !"".equals(allow) ? allow.split("\\,") : null;
if(null != allows) {
	for(int i=0; i<allows.length; i++) if(types.containsKey(allows[i])) types.put(allows[i], "true");
}

//���
p.setLayout("blank");
p.setBody("content.attach");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("del_query", m.qs("id, mode"));
p.setVar("mod_query", m.qs("id, mode"));

p.setLoop("list", list);
p.setVar("use_img", (String)types.get("image"));
p.setVar("use_movie", (String)types.get("media"));
p.setVar("use_file", (String)types.get("file"));
p.setVar("use_desc", 1 != m.ri("nodesc"));
p.setVar("tgt", tgt);
p.setVar("contentwidth", post.getContentWidth() - 20);
p.display();

%>