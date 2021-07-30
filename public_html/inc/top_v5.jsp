<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//객체
SitemapDao sitemap = new SitemapDao();
HashMap<String, DataSet> subset = new HashMap<String, DataSet>();

//목록
DataSet rs = sitemap.find(
	"site_id = " + siteId + " AND code != 'member'"
	+ " AND display_type IN " + (userId > 0 ? "('A', 'I')" : "('A', 'O')")
	+ " AND display_yn = 'Y' AND status = 1 "
	, "code, parent_cd, menu_nm, link, target"
	, "depth,sort ASC"
);

DataSet list = new DataSet();
while(rs.next()) {
	String pcd = rs.s("parent_cd");
	if("".equals(pcd)) {
		pcd = "_root_";
		list.addRow(rs.getRow());
	}
	if(!subset.containsKey(pcd)) subset.put(pcd, new DataSet());
	subset.get(pcd).addRow(rs.getRow());
}

StringBuilder sb = new StringBuilder();
createList(subset, sb, "_root_", 1);

p.setLayout(null);
p.setBody("layout.top");
p.setVar("gnb_menu", sb.toString());
p.setLoop("top_menu", list);
p.display();

%><%!

public void createList(HashMap<String, DataSet> subset, StringBuilder sb, String pcode, int no) {
	DataSet rs = subset.get(pcode);
	rs.first();
	sb.append("<ul ");
	if(no == 1) sb.append("id='gnb' ");
	sb.append("class='depth");
	sb.append(Integer.toString(no));
	sb.append("'>");
	while(rs.next()) {
		sb.append("<li id='gnb_");
		sb.append(rs.s("code"));
		sb.append("'>");
		sb.append("<a href='");
		sb.append(rs.s("link"));
		sb.append("' target='");
		sb.append(rs.s("target"));
		sb.append("'>");
		sb.append(rs.s("menu_nm"));
		sb.append("</a>");
		if(subset.containsKey(rs.s("code"))) {
			createList(subset, sb, rs.s("code"), no + 1);
		}
		sb.append("</li>");	
	}
	sb.append("</ul>");
}

%>