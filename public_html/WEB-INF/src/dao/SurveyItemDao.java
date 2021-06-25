package dao;

import malgnsoft.db.*;

public class SurveyItemDao extends DataObject {

	public SurveyItemDao() {
		this.table = "LM_SURVEY_ITEM";
		this.PK = "survey_id,question_id";
	}
}