<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//객체
SitemapDao sitemap = new SitemapDao();

//목록
if(!subset.containsKey("_root_")) {
	DataSet rs = sitemap.find(
		"site_id = " + siteId + " AND code != 'member'"
		+ " AND display_type IN " + (userId > 0 ? "('A', 'I')" : "('A', 'O')")
		+ " AND display_yn = 'Y' AND status = 1 "
		, "code, parent_cd, menu_nm, link, target"
		, "depth,sort ASC"
	);

	while(rs.next()) {
		String pcd = rs.s("parent_cd");
		if("".equals(pcd)) pcd = "_root_";
		if(!subset.containsKey(pcd)) subset.put(pcd, new DataSet());
		subset.get(pcd).addRow(rs.getRow());
	}
}

StringBuilder sb = new StringBuilder();
createList(sb, "_root_", 1);
out.print(sb.toString());

%><%!

static HashMap<String, DataSet> subset = new HashMap<String, DataSet>();

public void createList(StringBuilder sb, String pcode, int no) {
	DataSet rs = subset.get(pcode);
	rs.first();
	sb.append("<ul class='depth" + no + "'>");
	while(rs.next()) {
		sb.append("<li>");
		sb.append("<a href='");
		sb.append(rs.s("link"));
		sb.append("' target='");
		sb.append(rs.s("target"));
		sb.append("'>");
		sb.append(rs.s("menu_nm"));
		sb.append("</a>");
		if(subset.containsKey(rs.s("code"))) {
			createList(sb, rs.s("code"), no + 1);
		}
		sb.append("</li>");	
	}
	sb.append("</ul>");
}

%>