<!DOCTYPE html>
<%@include file="/WEB-INF/tags/decl.tagf"%>
<%@attribute name="styles" fragment="true" %>
<%@attribute name="dwr" %>
<%@attribute name="css" %>
<%@attribute name="js" %>
<%@attribute name="onload" %>
<%@attribute name="jqplugins" %>

<html>
<head>
  <title><c:choose>
    <c:when test="${!empty instanceDescription}">${instanceDescription}</c:when>
    <c:otherwise><fmt:message key="header.title"/></c:otherwise>
  </c:choose></title>
  
  <!-- Meta -->
  <meta charset="utf-8">
  <meta name="Copyright" content="ScadaLTS &copy;2018"/>
  <meta name="DESCRIPTION" content="ScadaLTS Software"/>
  <meta name="KEYWORDS" content="ScadaLTS Software"/>
  
  <!-- Style -->
  <link rel="icon" href="images/favicon.ico"/>
  <link rel="shortcut icon" href="images/favicon.ico"/>
  <link rel="stylesheet" type="text/css" href="assets/main.css">

  <!-- <link id="pagestyle" href="assets/common_deprecated.css" type="text/css" rel="stylesheet"/> -->
  <!-- <link id="pagestyle" href="assets/main.css" type="text/css" rel="stylesheet"/> -->
  <!-- <c:forTokens items="${css}" var="cssfile" delims=", ">
    <link href="resources/${cssfile}.css" type="text/css" rel="stylesheet"/>
  </c:forTokens> -->
  <jsp:invoke fragment="styles"/>
  
  <!-- Scripts -->
  <script type="text/javascript">
  	var djConfig = { isDebug: false, extraLocale: ['en-us', 'nl', 'nl-nl', 'ja-jp', 'fi-fi', 'sv-se', 'zh-cn', 'zh-tw','xx'] };
  	var ctxPath = "<%=request.getContextPath()%>";
  </script>
  <!-- script type="text/javascript" src="http://o.aolcdn.com/dojo/0.4.2/dojo.js"></script -->
  <script type="text/javascript" src="resources/dojo/dojo.js"></script>
  <script type="text/javascript" src="resources/jQuery/jquery-1.10.2.min.js"></script>
  <c:forTokens items="${jqplugins}" var="plugin" delims=", ">
    <script type="text/javascript" src="resources/jQuery/plugins/${plugin}.js"></script>
  </c:forTokens>
  <script type="text/javascript">
	var jQuery = $; 
	$ = null;
  </script> 
  <script type="text/javascript" src="dwr/engine.js"></script>
  <script type="text/javascript" src="dwr/util.js"></script>
  <script type="text/javascript" src="dwr/interface/MiscDwr.js"></script>
  <script type="text/javascript" src="resources/soundmanager2-nodebug-jsmin.js"></script>
  <script type="text/javascript" src="resources/common.js"></script>
  <c:forEach items="${dwr}" var="dwrname">
    <script type="text/javascript" src="dwr/interface/${dwrname}.js"></script></c:forEach>
  <c:forTokens items="${js}" var="jsname" delims=", ">
    <script type="text/javascript" src="resources/${jsname}.js"></script></c:forTokens>
  <script type="text/javascript">
    mango.i18n = <sst:convert obj="${clientSideMessages}"/>;
  </script>
  <c:if test="${!simple}">
    <script type="text/javascript" src="resources/header.js"></script>
    <script type="text/javascript">
    
	    function loadjscssfile(filename, filetype){
			if (filetype=="js"){ //if filename is a external JavaScript file
	    		var fileref=document.createElement('script')
	    		fileref.setAttribute("type","text/javascript")
	    		fileref.setAttribute("src", filename)
			} else if (filetype=="css"){ //if filename is an external CSS file
	    		var fileref=document.createElement("link")
	    		fileref.setAttribute("rel", "stylesheet")
	    		fileref.setAttribute("type", "text/css")
	    		fileref.setAttribute("href", filename)
			}
			if (typeof fileref!="undefined")
	    		document.getElementsByTagName("head")[0].appendChild(fileref)
		};
    
      dwr.util.setEscapeHtml(false);
      <c:if test="${!empty sessionUser}">
        dojo.addOnLoad(mango.header.onLoad);
        dojo.addOnLoad(function() { setUserMuted(${sessionUser.muted}); });
      </c:if>
      
      function setLocale(locale) {
          MiscDwr.setLocale(locale, function() { window.location = window.location });
      }
      
      function setHomeUrl() {
          MiscDwr.setHomeUrl(window.location.href, function() { alert("Home URL saved"); });
      }
      
      function goHomeUrl() {
          MiscDwr.getHomeUrl(function(loc) { window.location = loc; });
      }

      function swapStyleSheet(sheet) {
        document.getElementById("pagestyle").setAttribute("href", sheet); 
        localStorage.setItem('theme', sheet);
      }

      var opened = false;
      function toggleNav() {
        var x = document.getElementsByClassName("menuitem-text");
        var i;
        if (opened) {
          document.getElementById("Scada-menu").style.width = "75px";
          document.getElementById("Scada-content").style.marginLeft = "75px";
          opened = false;
          for (i = 0; i < x.length; i++) {
            x[i].style.display = "none";
          }
        } else {
          document.getElementById("Scada-menu").style.width = "300px";
          document.getElementById("Scada-content").style.marginLeft = "300px";
          opened = true;
          for (i = 0; i < x.length; i++) {
            if(x[i].parentNode.parentElement.tagName == "LI") {
              x[i].style.display = "block";
            }
          
          } 

        }
        
      }
    </script>
  </c:if>
</head>

<body>
  <header>
    <div class="main-menu" id="Scada-header">
      <div class="logo-box">
        <div>
          <img id="logo" src="assets/logo.png" alt="Logo" onclick="goHomeUrl()"/>
        </div>
      </div>

      <div class="event-box">
        <c:if test="${!simple}">
          <div id="eventsRow">
            <a href="events.shtm">
              <span id="__header__alarmLevelDiv" style="display:none;">
                <img id="__header__alarmLevelImg" src="images/spacer.gif" alt="" border="0" title=""/>
                <span id="__header__alarmLevelText"></span>
              </span>
            </a>
          </div>
        </c:if>
        <c:if test="${!empty instanceDescription}">
          <td align="right" valign="bottom" class="projectTitle" style="padding:5px; white-space: nowrap;">${instanceDescription}</td>
        </c:if>
      </div>

      <div class="utils-box">
          <div>
          <c:if test="${!empty sessionUser}">
            
          <tag:img id="userMutedImg" onclick="MiscDwr.toggleUserMuted(setUserMuted)" onmouseover="hideLayer('localeEdit')"/>
          <tag:img png="house_link" title="header.setHomeUrl" onclick="setHomeUrl()" onmouseover="hideLayer('localeEdit')"/>
          </c:if>
          
          <div style="display:inline;" class="ptr" onmouseover="showMenu('localeEdit', -40, 10);">
            <tag:img png="world" title="header.changeLanguage"/>
            <div id="localeEdit" style="visibility:hidden;left:0px;top:15px;" class="labelDiv" onmouseout="hideLayer(this)">
              <c:forEach items="${availableLanguages}" var="lang">
                <a class="ptr" onclick="setLocale('${lang.key}')">${lang.value}</a><br/>
              </c:forEach>
            </div>
          </div>  
          <tag:menuItem href="logout.htm" png="control_stop_blue" key="header.logout"/>
        </div>
        <div>
          <c:if test="${empty sessionUser}">
            <tag:menuItem href="login.htm" png="control_play_blue" key="header.login"/>
          </c:if>  
          <c:if test="${!empty sessionUser}">
            <span class="copyTitle"><fmt:message key="header.user"/>:</span>
            <span class="userName"><b>${sessionUser.username}</b></span>
          </c:if>
          <div id="headerMenuDescription" class="labelDiv" style="position:absolute;display:none;"></div>
        </div>
      </div>

    </div>
  </header>

  <c:if test="${!simple}">
  <div class="side-menu" id="Scada-menu">
    <c:if test="${!empty sessionUser}">
      <div class="toggle-nav-button">
          <span onclick="toggleNav()">&#9776;</span>
      </div>
      <ul>
        <li><tag:menuItem href="watch_list.shtm" png="eye" key="header.watchlist"/></li>
        <li><tag:menuItem href="views.shtm" png="icon_view" key="header.views"/></li>
        <li><tag:menuItem href="events.shtm" png="flag_white" key="header.alarms"/></li>
        <li><tag:menuItem href="reports.shtm" png="report" key="header.reports"/></li>
      </ul>

      <c:if test="${sessionUser.dataSourcePermission}">
        <ul>
          <li><tag:menuItem href="event_handlers.shtm" png="cog" key="header.eventHandlers"/></li>
          <li><tag:menuItem href="data_sources.shtm" png="icon_ds" key="header.dataSources"/></li>
          <li><tag:menuItem href="scheduled_events.shtm" png="clock" key="header.scheduledEvents"/></li>
          <li><tag:menuItem href="compound_events.shtm" png="multi_bell" key="header.compoundEvents"/></li>
          <li><tag:menuItem href="point_links.shtm" png="link" key="header.pointLinks"/></li>
          <li><tag:menuItem href="scripting.shtm" png="script_gear" key="header.scripts"/></li>
        </ul>
      </c:if>
      <c:if test="${sessionUser.admin}">
          <ul>
              <li><tag:menuItem href="usersProfiles.shtm" png="user_ds" key="header.usersProfiles"/></li>
              <li><tag:menuItem href="pointHierarchySLTS" png="folder_brick" key="header.pointHierarchy"/></li>
              <li><tag:menuItem href="mailing_lists.shtm" png="book" key="header.mailingLists"/></li>
              <li><tag:menuItem href="publishers.shtm" png="transmit" key="header.publishers"/></li>
              <li><tag:menuItem href="maintenance_events.shtm" png="hammer" key="header.maintenanceEvents"/></li>
              <li><tag:menuItem href="system_settings.shtm" png="application_form" key="header.systemSettings"/></li>
              <li><tag:menuItem href="emport.shtm" png="script_code" key="header.emport"/></li>
              <li><tag:menuItem href="sql.shtm" png="script" key="header.sql"/></li>
          </ul>
      </c:if>
      <ul>
        <li><tag:menuItem href="users.shtm" png="user" key="header.users"/></li>
        <li><tag:menuItem href="help.shtm" png="help" key="header.help"/></li>
      </ul>
    </c:if>
  </div>
  </c:if>
  
  <div class="content" id="Scada-content">
    <jsp:doBody/>
  </div>
  <div class="footer">
      <span>&copy;2012-2018 Scada-LTS <fmt:message key="footer.rightsReserved"/><span>
  </div>
  <c:if test="${!empty onload}">
    <script type="text/javascript">dojo.addOnLoad(${onload});</script>
  </c:if>
</body>
</html>
