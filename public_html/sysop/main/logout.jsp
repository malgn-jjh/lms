<%@ page contentType="text/html; charset=utf-8" %><%@ include file="../init.jsp" %><%

mSession.delSession();
auth.delAuthInfo();

UserLoginDao userLogin = new UserLoginDao();

userLogin.item("id", userLogin.getSequence());
userLogin.item("site_id", siteId);
userLogin.item("user_id", userId);
userLogin.item("admin_yn", "Y");
userLogin.item("login_type", ("session".equals(m.rs("mode")) ? "S" : "O"));
userLogin.item("ip_addr", request.getRemoteAddr());
userLogin.item("agent", request.getHeader("user-agent"));
userLogin.item("device", userLogin.getDeviceType(request.getHeader("user-agent")));
userLogin.item("log_date", m.time("yyyyMMdd"));
userLogin.item("reg_date", m.time("yyyyMMddHHmmss"));
if(!userLogin.insert()) {}

m.jsReplace("../main/login.jsp", "top");

%>