$(function() {
	var rule = {
		'#mypage': CourseList,
		'#lesson': LessonList,
		'#cnotice': CNoticeList,
		'#cnotice_view': CNoticeView,
		'#notice': NoticeList,
		'#notice_view': NoticeView,
		'#faq': FaqList,
		'#faq_view': FaqView,
		'#logout': Logout
	};
	$( "body>[data-role='panel']" ).panel();
	//$( window ).hashchange(function() { dispacher(rule); });
	dispacher(rule);
	try { init(); } catch(e) {}
});

var _sessId = GetCookie("SESSID");
var _param = {};
var pn = 0;

/* Document Onload */
$(document).ready(function() {
//	CheckLogin();
});

/*** PhoneGap interaction ***/
function init() {

	// 이벤트 등록
	//alert(device.phonegap);
	$(document).on("deviceready", onDeviceready);
}

function onDeviceready() {
	// 이벤트 등록 (동영상 플레이어 버튼)
	alert(device.phonegap);
	$("#moviePlayer").on("click", callViewer);
}

function callViewer(url, cuid, chapter, lid, curr_time, last_time) {
	// 폰갭 plugin 실행
	// 맑은 소프트에서 MU로 전달할 값입니다
	//var pluginEcho = new MGPluginEcho();

	// 샘플
	//pluginEcho.echo("cuid", "chapter", "lid", "curr_time", "last_time", "study_time");
	
	// 동영상 강제 재생
	//pluginEcho.echo(url, cuid, chapter, lid, curr_time, last_time);
	cordova.exec(null, null, "MGPluginEcho", "callViewer", [url, cuid, chapter, lid, curr_time, last_time]);
}

/*** Common Functions ***/
jQuery.fn.extend({
	template: function(src, data) {
		var tpl = _.template($(src).html());
		this.html("");
		var that = this;
		if(_.isArray(data)) {
			_.each(data, function(row) {
			that.append(tpl(row));
		});
		} else if(_.isObject(data)) {
			this.append(tpl(data));
		}
		return this;
	}
});
function dispacher(obj) {
	var arr = location.hash.split("?");
	var page = arr[0] || '#main';
	var search = /([^&=]+)=?([^&]*)/g;
	var query = arr[1] || '';
	var decode = function(s) { return decodeURIComponent(s.replace(/\+/g, " ")); }
	var match = null;
	while(match = search.exec(query)) {
		_param[decode(match[1])] = decode(match[2]);
	}
	var func = obj[page] || null;
	//if(func != null) func(_param);
	if(func != null) func();
}
function request(name) {
	if(name) return _param[name] || '';
	else return _param;
}
/*
function call(url, param, callback) {
	var rows = [
		{course_id:1, img_url:'http://demos.jquerymobile.com/1.4.2/_assets/img/album-bb.jpg', course_nm:'전산학개론'},
		{course_id:2, img_url:'http://demos.jquerymobile.com/1.4.2/_assets/img/album-bb.jpg', course_nm:'전산학개론'},
		{course_id:3, img_url:'http://demos.jquerymobile.com/1.4.2/_assets/img/album-bb.jpg', course_nm:'전산학개론'}
	];
	callback(rows);
}
*/
function call(url, param, callback) {
	param['ssid'] = _sessId;
	$.ajax({
		url : url + "?" + (new Date()).getTime(),
		type : "POST",
		crossDomain: true,
		beforeSend : function() {$.mobile.loading('show')},
		complete   : function() {$.mobile.loading('hide')},
		dataType : "json",
		data : param,
		success : function result(data){
			var edata = data.error;
			if(edata.error_code == "2100") {
				alert(edata.error_msg);
				$.mobile.changePage("#login", { transition:'slide' });
				return;
			} else if(edata.error_code != "0000") {
				alert(edata.error_msg);
				return;
			} else {
				callback(data.data);
			}
		},
		error : function(r) {
			alert('ERROR!!');
		}
	});
}

/*** Logic Functions ***/
function CheckLogin() {
	if(_sessId == null || _sessId == "") {
		$.mobile.changePage("#login", { transition:'slide' });
		return false;
	} else {
		return true;
	}
}
function Login(el) {
	var param = {id: el['id'].value, passwd: el['passwd'].value};
	call("login.jsp", param, function(data) {
		_sessId = data.ssid;
		SetCookie("SESSID", _sessId);
		$.mobile.changePage("#main", { transition:'slide' });

	});
	return false;
}
function Logout() {
	_sessId = null;
	SetCookie("SESSID", "");
	call("logout.jsp", {}, function(data) {
		$.mobile.changePage("#main", { transition:'slide' });
	});
	return true;
}
function CourseList(type) {
	if(!CheckLogin()) return false;
	if(!type) type = request("type") ? request("type") : "on";
	var param = {type: type};
	call("mypage.jsp", param, function(rows) {
		$("#my_course_list").template("#my_course_list_tpl", rows).listview().listview('refresh');
		$("#mypage-link-" + type).addClass("ui-btn-active");
	});
	window.location.hash = "#mypage?type=" + type;
	return true;
}
function LessonList(cuid) {
	if(!CheckLogin()) return false;
	if(!cuid) cuid = request("cuid");
	var param = {cuid: cuid};
	call("lesson.jsp", param, function(data) {
		$(".course_name").html(data.course_nm);
		$("#lesson_list").template("#lesson_list_tpl", data.list).listview().listview('refresh');
		$("#lesson_tab1").attr("href", "#lesson?cuid=" + cuid).attr("onclick", "return LessonList(" + cuid + ")");
		$("#lesson_tab2").attr("href", "#cnotice?cuid=" + cuid).attr("onclick", "return CNoticeList(" + cuid + ")");
		/*
		$(document).scroll(function() { 
			alert($(window).scrollTop() + " || " + $(document).height() + " || " + $(window).height());
			if ($(window).scrollTop() > 0 && $(window).scrollTop() >= $(document).height() - $(window).height()) { 
				alert("Next Page");
			} 
		});
		*/
	});
	return true;
}

function CNoticeList(cuid, pn) {
	if(!CheckLogin()) return false;
	if(!cuid) cuid = request("cuid");
	if(!pn) pn = request("pn") ? request("pn") : 1;
	var param = {cuid: cuid, pn: pn};
	call("cnotice_list.jsp", param, function(data) {
		$(".course_name").html(data.course_nm);
		$("#cnotices").template("#cnotices_tpl", data.list).listview().listview('refresh');
		$("#cnotice_tab1").attr("href", "#lesson?cuid=" + cuid).attr("onclick", "return LessonList(" + cuid + ")");
		$("#cnotice_tab2").attr("href", "#cnotice?cuid=" + cuid).attr("onclick", "return CNoticeList(" + cuid + ")");
		if((data.pn * data.ln) < data.list_cnt) $(".moreArea").show();
		else $(".moreArea").hide();
	});
	window.location.hash = "#cnotice?cuid=" + cuid + "&pn=" + pn;
	pn++;
	$("#cnoticeMore").attr("href", "#cnotice?cuid=" + cuid + "&pn=" + pn).attr("onclick", "return CNoticeList(" + cuid + "," + pn + ")");
	return true;
}

function CNoticeView(cuid, pid, pn) {
	if(!CheckLogin()) return false;
	if(!cuid) cuid = request("cuid");
	if(!pid) pid = request("id");
	if(!pn) pn = request("pn");
	var param = {cuid: cuid, id: pid, pn: pn};
	call("cnotice_view.jsp", param, function(info) {
		$(".subject").html(info.subject);
		$("#cnotice_info").template("#cnotice_info_tpl", info).listview().listview('refresh');
		$("#cnotice_view_tab1").attr("href", "#lesson?cuid=" + cuid).attr("onclick", "return LessonList(" + cuid + ")");
		$("#cnotice_view_tab2, #cnotices-back").attr("href", "#cnotice?cuid=" + cuid + "&pn=" + pn).attr("onclick", "return CNoticeList(" + cuid + ", '" + pn + "')");
	});
	return true;
}

function NoticeList(pn) {
	if(!pn) pn = request("pn") ? request("pn") : 1;
	var param = {pn: pn};
	call("notice.jsp", param, function(data) {
		$("#notice_list").template("#notice_list_tpl", data.list).listview().listview('refresh');
		if((data.pn * data.ln) < data.list_cnt) $(".moreArea").show();
		else $(".moreArea").hide();
	});
	window.location.hash = "#notice?pn=" + pn;
	pn++;
	$("#noticeMore").attr("href", "#notice?pn=" + pn).attr("onclick", "return NoticeList(" + pn + ")");
	return true;
}
function NoticeView(pid, pn) {
	if(!pid) pid = request("id");
	if(!pn) pn = request("pn");
	var param = {id: pid, pn: pn};
	call("notice_view.jsp", param, function(info) {
		$(".subject").html(info.subject);
		$("#notice_info").template("#notice_info_tpl", info).listview().listview('refresh');
		$("#notice-back").attr("href", "#notice?pn=" + info.pn).attr("onclick", "return NoticeList(" + info.pn + ")");
	});
	return true;
}

function FaqList(cid) {
	if(!cid) cid = request("s_category");
	var param = {s_category: cid};
	call("faq.jsp", param, function(rows) {
		$("#faq_list").template("#faq_list_tpl", rows.list).listview().listview('refresh');
		$("#faq-link-" + cid).addClass("ui-btn-active");
	});
	window.location.hash = "#faq?s_category=" + cid;
	return true;
}
function FaqView(pid, cid) {
	if(!CheckLogin()) return false;
	if(!pid) pid = request("id");
	if(!cid) cid = request("s_category");
	var param = {id: pid, s_category: cid};
	call("faq_view.jsp", param, function(info) {
		$(".subject").html(info.subject);
		$("#faq_info").template("#faq_info_tpl", info).listview().listview('refresh');
		$("#faq-back").attr("href", "#faq?s_category=" + cid).attr("onclick", "return FaqList(" + cid + ")");
	});
	return true;
}

function SetCookie(name, value, expires, path, domain, secure) { //expires : 초
	var date = new Date();
	date.setSeconds(date.getSeconds() + expires);

	document.cookie= name + "=" + escape(value) + "; path=" + ((path) ? path : "/") +
	((expires) ? "; expires=" + date.toGMTString() : "") +
	((domain) ? "; domain=" + domain : "") +
	((secure) ? "; secure" : "");
}

function GetCookie(name) {
	var dc = document.cookie;
	var prefix = name + "=";
	var begin = dc.indexOf("; " + prefix);
	if (begin == -1) {
		begin = dc.indexOf(prefix);
		if (begin != 0) return null;
	} else {
		begin += 2;
	}
	var end = document.cookie.indexOf(";", begin);
	if (end == -1) {
		end = dc.length;
	}
	return unescape(dc.substring(begin + prefix.length, end));
}