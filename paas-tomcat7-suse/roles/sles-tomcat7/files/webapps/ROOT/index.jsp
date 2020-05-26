<%@ page import="java.util.Properties,java.util.Map" language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Tomcat 7 Welcome Page</title>
<style type="text/css">
        /*<![CDATA[*/
        body {
                background-color: #fff;
                color: #000;
                font-size: 0.9em;
                font-family: sans-serif,helvetica;
                margin: 0;
                padding: 0;
        }
        :link {
                color: #c00;
        }
        :visited {
                color: #c00;
        }
        a:hover {
                color: #f50;
        }
        h1 {
                text-align: center;
                margin: 0;
                padding: 0.6em 2em 0.4em;
                background-color: #D2A41C;
                color: #fff;
                font-weight: normal;
                font-size: 1.75em;
                border-bottom: 2px solid #000;
        }
        h1 strong {
                font-weight: bold;
        }
        h2 {
                font-size: 1.1em;
                font-weight: bold;
        }
        hr {
                display: none;
        }
        .content {
                padding: 1em 5em;
        }
        .content-columns {
                /* Setting relative positioning allows for
 *                 absolute positioning for sub-classes */
                position: relative;
                padding-top: 1em;
        }
        .content-column-left {
                /* Value for IE/Win; will be overwritten for other browsers */
                width: 47%;
                padding-right: 3%;
                float: left;
                padding-bottom: 2em;
        }
        .content-column-left hr {
                display: none;
        }
        .content-column-right {
                /* Values for IE/Win; will be overwritten for other browsers */
                width: 47%;
                padding-left: 3%;
                float: left;
                padding-bottom: 2em;
        }
        .content-columns>.content-column-left, .content-columns>.content-column-right {
                /* Non-IE/Win */
        }
        .code {
                font-family: "Courier New";
        }
        img {
                border: 2px solid #fff;
                padding: 2px;
                margin: 2px;
        }
        a:hover img {
                border: 2px solid #f50;
        }
        /*]]>*/
</style>
</head>

<body>
        <h1>Tomcat 7 Welcome Page</h1>
        <div class="content">
                <div class="content-middle">
                        <p>This page is used to test the proper operation of the Tomcat server after it has been installed. If you can read this page, it means that the Tomcat server installed at this site is working properly.</p>
                </div>
                <hr/>
                <h2>Important Details:</h2>
                <ul>
                        <li>CATALINA_HOME=<span class="code"><% out.println(System.getProperty("catalina.home")); %></span></li>
                        <li>CATALINA_BASE=<span class="code"><% out.println(System.getProperty("catalina.base")); %></span></li>
                        <li>The main config files are located in <span class="code"><% out.print(System.getProperty("catalina.base")); %>/conf</span></li>
                        <li>Environment variables (e.g. JAVA_OPTS) are defined in <span class="code">/etc/sysconfig/tomcat7</span></li>
                        <li>Logs are written to <span class="code"><% out.print(System.getProperty("catalina.base")); %>/logs</span></li>
			<li>Webapps can be deployed to <span class="code"><% out.print(System.getProperty("catalina.base")); %>/webapps</span></li>
                </ul>
                <p>Thanks for choosing Tomcat!</p>
        </div>
</body>
</html>
