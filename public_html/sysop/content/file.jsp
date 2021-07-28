<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//접근권한
if(!Menu.accessible(29, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//다운로드
if("DOWNLOAD".equals(m.rs("mode"))) {
	String path = m.decode(m.rs("path"));
	File file = new File(path);
	if(file.exists()){
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
	}
	return;
}

//기본키
int cid = m.ri("cid");
if(cid == 0) { m.jsError("기본키는 반드시 지정해야 합니다."); return; }
if(cid == -999) { m.redirect("lesson_list.jsp?cid="+cid); return; }

//객체
ContentDao content = new ContentDao();

//정보
DataSet cinfo = content.find("id = " + cid + " AND site_id = " + siteId + "");
if(!cinfo.next()) { m.jsError("해당 정보가 없습니다."); return; }

//컨텐츠폴더생성
String contentDir = dataDir + "/Contents"; //임시
File rootDir = new File(contentDir + "/" + cinfo.s("id"));
if(!rootDir.exists()) rootDir.mkdirs();
String cRoot = rootDir.toString();

//폴더삭제
if("DIR_DEL".equals(m.rs("mode"))) {
	String path = m.decode(m.rs("path"));
	File file = new File(path);
	if(file.isDirectory() && file.listFiles().length > 0) {
		m.jsAlert("비어있는 폴더만 삭제가능합니다.");
		return;
	} else {
		file.delete();
		out.print("<script>");
		out.print("parent.parent.left.location.reload();");
		out.print("parent.location.href = 'file.jsp?MN=" + m.rs("MN")
			+ "&mode=FILE_LIST&cid=" + m.rs("cid")
			+ "&path=" + m.encode(file.toString().equals(cRoot) ? cRoot : file.getParentFile().toString()) + "';");
		out.print("</script>");
	}
	return;
}
//파일삭제
if(m.isPost() && "FILE_DEL".equals(f.get("md"))) {
	String[] idx = f.getArr("idx");
	for(int i=0; i<idx.length; i++) {
		File file = new File(m.decode(idx[i]));
		if(file.exists()) file.delete();
	}
	out.print("<script>");
	out.print("parent.location.href = parent.location.href");
	out.print("</script>");
	return;
}

//구분별출력
String mode = m.rs("mode");
if("DIR_LIST".equals(mode)) {

	Vector tree = getFileList(cRoot, 0);
	DataSet list = new DataSet();
	for(int i=0; i<tree.size(); i++) {
		Hashtable row = (Hashtable)tree.get(i);
		row.put("path_ec", m.encode((String)row.get("path")));
		list.addRow(row);
	}
	p.setLayout("blank");
	p.setBody("content.file");
	p.setLoop("list", list);
	p.setVar("path_ec", m.encode(cRoot));
	p.setVar("dir_block", true);
	p.display();

} else if("FILE_LIST".equals(mode)) {
	String dir = m.decode(m.rs("path"));

	//폼체크
	f.addElement("folder", null, "hname:'폴더명', required:'Y'");

	//폴더생성
	if(m.isPost() && f.validate()) {
		File nf = new File(dir + "/" + f.get("folder"));
		if(nf.exists()) {
			m.jsAlert("존재하는 폴더명 입니다.");
			return;
		} else {
			nf.mkdirs();
		}
		out.print("<script>");
		out.print("parent.parent.left.location.reload();");
		out.print("parent.location.href = parent.location.href;");
		out.print("</script>");
		return;
	}

	FilenameFilter fileFilter = new FilenameFilter() {
		public boolean accept(File dir, String name) {
			return !new File(dir + "/" + name).isDirectory();
		}
	};
	File file = new File(dir);
	File[] files = file.listFiles(fileFilter);
	DataSet list = new DataSet();
	if(files != null) {
		Arrays.sort(files);
		for(int i=0; i<files.length; i++) {
			list.addRow();
			String path = files[i].toString();
			list.put("id", i);
			list.put("path", path);
			list.put("path_ec", m.encode(path));
			list.put("name", files[i].getName());
			list.put("time", files[i].lastModified());
			list.put("date", m.getTimeString("yyyy-MM-dd HH:mm:ss", new Date(files[i].lastModified())));
			list.put("size", m.getFileSize(files[i].length()));
			list.put("ext", list.s("name").substring(list.s("name").lastIndexOf(".") + 1).toLowerCase());
		}
	}

	p.setLayout("blank");
	p.setBody("content.file");
	p.setLoop("list", list);
	p.setVar("dir_conv", "ROOT" + m.replace(m.replace(dir, "\\", "/"), contentDir + "/" + cid, ""));
	p.setVar("file_block", true);
	p.setVar("del_query", m.qs("mode"));
	p.setVar("form_script", f.getScript());
	p.setVar("path", m.encode(dir));
	p.display();
} else {
	p.setLayout(ch);
	p.setBody("content.file");
	p.setVar("p_title", "콘텐츠관리");
	p.setVar("cinfo", cinfo);
	p.setVar("idx_block", true);
	p.setVar("path_ec", m.encode(cRoot));
	p.display();
}

%>
<%!
int depth = 0;
int id = 0;
Vector result = new Vector();
Hashtable lmap = new Hashtable();
public Vector getFileList(String path, int pid) throws Exception {
	if(pid == 0) { result = new Vector(); depth = 0; id = 0; lmap = new Hashtable(); }
	File[] files = null;
	File file = new File(path);
	if(file.isDirectory()) {
		files = file.listFiles();
	} else {
		files = new File[1];
		files[0] = file;
	}
	if(null != files) {
		Arrays.sort(files);
		for(int i=0; i<files.length; i++) {
			boolean islink = false;
			if(files[i].isDirectory()) {
				if(files[i].getName().startsWith(".")) continue;
				if(!files[i].getAbsolutePath().equals(files[i].getCanonicalPath())) {
					islink = true;
					String key = files[i].getName();
					if(lmap.containsKey(key) && ((String)lmap.get(key)).equals(files[i].getCanonicalPath())) {
						continue;
					}
					lmap.put(key, files[i].getCanonicalPath());
				}
				Hashtable row = new Hashtable();
				row.put("id", ++id + "");
				row.put("parent_id", pid + "");
				row.put("path", files[i].toString() + "");
				row.put("name", files[i].getName() + "");
				row.put("time", files[i].lastModified() + "");
				row.put("depth", depth + "");
				result.add(row);
				depth++;
				getFileList(files[i].toString(), id);
				depth--;
			}
		}
	}
	return result;
}
public String getFileSize(long size) {
	if(size >= 1024 * 1024 * 1024) return (int)Math.ceil(size / (1024.0 * 1024 * 1024)) + "GB";
	else if(size >= 1024 * 1024) return (int)Math.ceil(size / (1024.0 * 1024)) + "MB";
	else if(size >= 1024) return (int)Math.ceil(size / 1024.0) + "KB";
	else return (int)Math.ceil(size * 1.0) + "B";
}
%>