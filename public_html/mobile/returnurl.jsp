<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%><%@ page import="java.util.*" %>
<html>
<head>
	<script type="text/javascript">
		function setLGDResult() {
			if( parent.LGD_window_type == "iframe" ){
				parent.setLGDResult();
			} else {
				opener.setLGDResult();
				window.close();
			}
		}

	</script>
</head>
<body onload="setLGDResult()">
<%
   	Map parameters = request.getParameterMap();
    for (Iterator it = parameters.keySet().iterator(); it.hasNext(); ) {
        String name = (String) it.next();
        int i = ((String[])parameters.get(name)).length;
        for ( int k = 0 ; k<i ; k++){
            String value = ((String[]) parameters.get(name))[k];
    		out.println("<input type='hidden' id='" + name + "' value='" + value + "'>" );
        }
   	}
%>
</body>
</html>