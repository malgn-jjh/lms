<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

if(!Menu.accessible(31, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

String cd = m.rs("cd", "MEDIA");
//cd = "";

//String path = dataDir + "/Contents/" + cd;
String path = dataDir + "/Contents/" + siteinfo.i("id");

File dfd = new File(path);
if(!dfd.exists()) { dfd.mkdirs(); };

//폴더목록
DataSet list = new DataSet();
Vector v = getFileList(path);
result = null;
for(int i=0, max=v.size(); i<max; i++) {
	list.addRow((Hashtable)v.get(i));
	list.put("path_ec", m.encode(list.s("path")));
	list.put("id", m.encrypt(list.s("path")));
	File pfile = new File(list.s("path")).getParentFile();
	list.put("parent_id", null != pfile ? m.encrypt(pfile.toString()) : "");
}

//출력
p.setLayout("blank");
p.setBody("vod.choice_left");
p.setLoop("list", list);
p.setVar("root", m.encrypt(path));
p.setVar("del_query", m.qs("path"));
p.setVar("query", m.qs());
p.display(out);

%>
<%!
public int depth = 1;
public int id = 0;
public static Vector<Hashtable> result = null;
public Hashtable<String, Object> lmap = new Hashtable<String, Object>();
public Vector getFileList(String path) throws Exception {
	if(null != result) return result;
	else return getFileList(path, 0);
}
public Vector getFileList(String path, int pid) throws Exception {
	if(pid == 0) { result = new Vector<Hashtable>(); depth = 0; id = 0; lmap = new Hashtable<String, Object>(); }
	File[] files = null;
	File file = new File(path);
	if(file.isDirectory()) {
		files = file.listFiles(new MyFilter());
		//files = file.listFiles();
	} else {
		files = new File[1];
		files[0] = file;
	}
	if(null != files) {
		Arrays.sort(files);
		for(int i=0; i<files.length; i++) {
			boolean islink = false;
			if(files[i].getName().startsWith(".")) continue;
			if(!files[i].getAbsolutePath().equals(files[i].getCanonicalPath())) {
				islink = true;
				String key = files[i].getName();
				if(lmap.containsKey(key) && ((String)lmap.get(key)).equals(files[i].getCanonicalPath())) {
					continue;
				}
				lmap.put(key, files[i].getCanonicalPath());
			}
			Hashtable<String, Object> row = new Hashtable<String, Object>();
			row.put("id", ++id + "");
			row.put("parent_id", pid + "");
			row.put("path", files[i].toString() + "");
			row.put("name", files[i].getName() + "");
			row.put("time", files[i].lastModified() + "");
			row.put("depth", depth + "");
			result.add(row);
			depth++;
			if(files[i].isDirectory()) getFileList(files[i].toString(), id);
			depth--;
		}
	}
	return result;
}

class MyFilter implements FileFilter {
	public boolean accept(File file) {
		boolean flag = false;
		return file.isDirectory();
	}
}

%>