<%@ page import="java.util.Properties,java.util.Map" language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" session="false" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Tomcat Health Check</title>
<style>
    body{font-family:"arial";font-size:8pt;}
    #title{font-size:18pt;font-weight:bold;}
    #status{font-size:16pt;font-weight:bold;}
    .heading{font-weight:bold;text-decoration:underline;}
</style>
</head>
<body>

<span id="title">Tomcat Status Page</span>

<br/>
<hr/>
<span id="status">Status: OK</span>
<hr/>
<br/>

<span class="heading">Heap Properties:</span>
<br/><br/>
<%
 int mb = 1024*1024;
 Runtime runtime = Runtime.getRuntime();
 out.println("Used Memory=" + (runtime.totalMemory() - runtime.freeMemory()) / mb +"<br/>");
 out.println("Free Memory=" + runtime.freeMemory() / mb +"<br/>");
 out.println("Total Memory=" + runtime.totalMemory() / mb +"<br/>");
 out.println("Max Memory=" + runtime.maxMemory() / mb +"<br/>");
%>
<br/><br/>

<span class="heading">System Properties:</span>
<br/><br/>
<%
    Properties p = System.getProperties();
    for(String key : p.stringPropertyNames()) {
        String value = p.getProperty(key);
        out.println(key + "=" + value + "<br/>");
    }
    out.flush();
%>
<br/>

<span class="heading">Java Opts:</span>
<br/><br/>
<%
    out.println(System.getenv().get("JAVA_OPTS") + "<br/>");
    out.flush();
%>

</body>
</html>
