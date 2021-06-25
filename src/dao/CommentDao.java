package dao;

import malgnsoft.db.*;

public class CommentDao extends DataObject {
	
	public String[] skins = {"common=>일반형", "simple=>단순형"};

	public CommentDao() {
		this.table = "TB_COMMENT";
	}

}