window.on_not_installed = function() {
    var status = document.getElementById("status");
    // status.innerHTML = "미설치 / 설치 가이드 표시";
    //location.href="/inc/72_neob_antirecording/detect.jsp?Type=install";
    try {
        parent.location.href = "/inc/72_neob_antirecording/detect.jsp?Type=install";
    } catch {
        location.href = "/inc/72_neob_antirecording/detect.jsp?Type=install";
    }

};
window.on_detection_ready = function() {
    var status = document.getElementById("status");
    //  status.innerHTML = "연결 됨 / 동영상을 표시하셔도 좋습니다.";
};
window.on_detection_success = function(e) {
    var status = document.getElementById("status");
    console.log(e);
    //  status.innerHTML = "탐지 성공 / " + e;
    //location.href="/inc/72_neob_antirecording/detect.jsp?detect="+e;
    try {
        parent.location.href = "/inc/72_neob_antirecording/detect.jsp?detect="+e;
    } catch {
        location.href = "/inc/72_neob_antirecording/detect.jsp?detect="+e;
    }


};
window.on_kill_success = function(e) {
    var status = document.getElementById("status");
    console.log(e);
    //  status.innerHTML = "제거 성공 / " + e;
};
window.on_detection_error = function(){
    var status = document.getElementById("status");
    // status.innerHTML = "연결 끊김 / 에러 페이지로 이동해야 합니다.";
    //location.href="/inc/72_neob_antirecording/detect.jsp?Type=error";
    try {
        parent.location.href = "/inc/72_neob_antirecording/detect.jsp?Type=error";
    } catch {
        location.href = "/inc/72_neob_antirecording/detect.jsp?Type=error";
    }

};
