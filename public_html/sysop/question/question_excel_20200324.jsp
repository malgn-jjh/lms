<%@ page contentType="text/html; charset=utf-8" %><%@ include file="init.jsp" %><%

//접근권한
if(!Menu.accessible(32, userId, userKind)) { m.jsError("접근 권한이 없습니다."); return; }

//객체
QuestionDao question = new QuestionDao();

//등록
if(m.isPost()) {

	//배열
	String[] fields = {
		"col0=>category_id", "col1=>grade", "col2=>question_type"
		, "col3=>question", "col4=>question_text", "col5=>item_cnt"
		, "col6=>item1", "col7=>item2", "col8=>item3", "col9=>item4", "col10=>item5"
		, "col11=>answer", "col12=>description", "col13=>status"
	};

	String[] required = { "col0", "col1", "col2", "col3", "col5", "col11", "col13" };

	//목록
	if("register".equals(f.get("mode"))) {
		//변수
		int success = 0;

		//폼입력
		String[] idx = f.getArr("idx");
		question.item("site_id", siteId);
		question.item("manager_id", 0);
		question.item("reg_date", m.time("yyyyMMddHHmmss"));
		question.item("status", 1);

		for(int i = 0; i < idx.length; i++) {
			int key = m.parseInt(idx[i]) - 1;
			question.item("category_id", f.getArr("category_id")[key]);
			question.item("grade", f.getArr("grade")[key]);
			question.item("question_type", f.getArr("question_type")[key]);
			question.item("question", f.getArr("question")[key]);
			question.item("question_text", f.getArr("question_text")[key]);
			question.item("item_cnt", f.getArr("item_cnt")[key]);
			question.item("item1", f.getArr("item1")[key]);
			question.item("item2", f.getArr("item2")[key]);
			question.item("item3", f.getArr("item3")[key]);
			question.item("item4", f.getArr("item4")[key]);
			question.item("item5", f.getArr("item5")[key]);
			question.item("answer", f.getArr("answer")[key]);
			question.item("description", f.getArr("description")[key]);

			if(question.insert()) success++;
		}

		m.jsAlert("총 " + idx.length + " 개 중 " + success + " 개가 등록되었습니다.");
		m.jsReplace("question.jsp", "parent");
		return;

	} else if(f.validate() && "list".equals(f.get("mode"))) {
		File f1 = f.saveFile("file");
		if(f1 != null) {
			String path = m.getUploadPath(f.getFileName("file"));
			DataSet records = new ExcelReader(path).getDataSet(1);
			if(!"".equals(path)) m.delFileRoot(path);

			//포맷팅
			DataSet list = new DataSet();
			DataSet tmp = m.arr2loop(fields);
			int i = 0;
			while(records.next()) {
				boolean flag = true;
				for(int j = 0; j < required.length; j++) {
					if("".equals(records.s(required[j]))) flag = false;
				}

				if(flag) {
					tmp.first();
					while(tmp.next()) {
						records.put(tmp.s("name"), records.s(tmp.s("id")));
					}

					records.put("item_cnt", records.i("question_type") > 2 || records.i("question_type") == 0 ? 1 : records.i("item_cnt"));
					records.put("question_conv", m.addSlashes(records.s("question")));
					records.put("question_text_conv", m.addSlashes(records.s("question_text")));
					records.put("question_type_conv", m.getItem(records.s("question_type"), question.types));
					records.put("grade_conv", m.getItem(records.s("grade"), question.grades));
					records.put("status_conv", m.getItem(records.s("status"), question.statusList));
					records.put("__ord", ++i);

					list.addRow(records.getRow());
				}
			}

			//출력
			p.setLayout("blank");
			p.setBody("question.question_excel");
			p.setVar("query", m.qs());
			p.setVar("list_query", m.qs("id"));
			p.setVar("form_script", f.getScript());

			p.setLoop("list", list);
			p.setVar("list_area", true);
			p.display();

			return;
		} else {
			m.jsAlert("엑셀파일을 읽는 중 오류가 발생했습니다.");
			return;
		}
	}
}


//출력
p.setBody("question.question_excel");
p.setVar("query", m.qs());
p.setVar("list_query", m.qs("id"));
p.setVar("form_script", f.getScript());

p.setVar("upload_area", true);
p.display();

%>