function MGPluginEcho(){}

MGPluginEcho.prototype.echo = function(cuid, chapter, lid, curr_time, last_time, study_time){
	cordova.exec(null, null, "MGPluginEcho", "callViewer", [cuid, chapter, lid, curr_time, last_time, study_time]);
}

MGPluginEcho.prototype.setWebPage = function(pageNo){
	cordova.exec(null, null, "MGPluginEcho", "setWebPage", [pageNo]);
}
	
MGPluginEcho.prototype.setWebComplete = function(){
	cordova.exec(null, null, "MGPluginEcho", "setWebComplete", []);
}
