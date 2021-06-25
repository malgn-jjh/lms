package dao;

import malgnsoft.db.*;
import java.util.Hashtable;

public class CourseSectionDao extends DataObject {

	public String[] statusList = { "1=>사용", "0=>중지" };
	public String[] statusListMsg = { "1=>list.course_section.status_list.1", "0=>list.course_section.status_list.0" };

	public CourseSectionDao() {
		this.table = "LM_COURSE_SECTION";
		this.PK = "id";
	}

	public boolean copySection(int oldCourseId, int newCourseId) {
		if(0 == oldCourseId || 0 == newCourseId) return false;

		CourseLessonDao courseLesson = new CourseLessonDao();
		Hashtable<Integer, Integer> sectionMap = new Hashtable<Integer, Integer>();

		DataSet slist = this.find("course_id = " + oldCourseId + " AND status = 1");
		while(slist.next()) {
			int newId = this.getSequence();
			this.item("id", newId);
			this.item("course_id", newCourseId);
			this.item("site_id", slist.i("site_id"));
			this.item("section_nm", slist.s("section_nm"));
			this.item("status", 1);
			if(!this.insert()) return false;
			sectionMap.put(slist.i("id"), newId);
		}

		DataSet cllist = courseLesson.find("course_id = " + newCourseId + " AND status != -1");
		while(cllist.next()) {
			courseLesson.item("section_id", sectionMap.containsKey(cllist.i("section_id")) ? sectionMap.get(cllist.i("section_id")) : 0);
			if(!courseLesson.update("course_id = " + newCourseId + " AND lesson_id = " + cllist.i("lesson_id"))) return false;
		}

		return true;
	}
}