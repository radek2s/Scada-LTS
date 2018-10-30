<%--
    Mango - Open Source M2M - http://mango.serotoninsoftware.com
    Copyright (C) 2006-2011 Serotonin Software Technologies Inc.
    @author Matthew Lohbihler

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/.
--%>
<%@ include file="/WEB-INF/jsp/include/tech.jsp" %>
<%@page import="com.serotonin.mango.Common"%>
<%@page import="com.serotonin.mango.view.ShareUser"%>
<tag:page dwr="WatchListDwr" js="view" onload="init">
  <jsp:attribute name="styles">
    <style>
    html > body .dojoTreeNodeLabelSelected {
        background-color: inherit;
        color: inherit;
    }
    .watchListAttr {
        min-width:600px;
    }
    .rowIcons img {
        padding-right: 3px;
    }
    html > body .dojoSplitContainerSizerH {
        border: 1px solid #FFFFFF;
        background-color: #39B54A;
        margin-top:4px;
        margin-bottom:4px;
    }
    .wlComponentMin {
        top:0px;
        left:0px;
        position:relative;
        margin:0px;
        padding:0px;
        width:16px;
        height:16px;
    }
    </style>
  </jsp:attribute>

  <jsp:body>
    <script type="text/javascript">
      dojo.require("dojo.widget.SplitContainer");
      dojo.require("dojo.widget.ContentPane");
      mango.view.initWatchlist();
      mango.share.dwr = WatchListDwr;
      var owner;
      var pointNames = {};
      var watchlistChangeId = 0;
      var isChartLive = false;
      var webLocation;

      function init() {
          webLocation = window.location.protocol 
            + "//" + window.location.host 
            + "/" + window.location.pathname.split("/")[1] + "/";

          WatchListDwr.init(function(data) {
              mango.share.users = data.shareUsers;

              // Create the point tree.
              var rootFolder = data.pointFolder;
              var tree = dojo.widget.manager.getWidgetById('tree');
              var i;

              for (i=0; i<rootFolder.subfolders.length; i++)
                  addFolder(rootFolder.subfolders[i], tree);

              for (i=0; i<rootFolder.points.length; i++)
                  addPoint(rootFolder.points[i], tree);

              /*  addPointsToSelectList(rootFolder, "");
              jQuery("#dpSelector").chosen({
            	  placeholder_text_single: " ",
            	  search_contains: true
              });  */

              hide("loadingImg");
              show("treeDiv");
              document.getElementById("chartContainer").style.height = "auto";

              addPointNames(rootFolder);

              // Add default points.
              displayWatchList(data.selectedWatchList);
              maybeDisplayDeleteImg();
          });
          WatchListDwr.getDateRangeDefaults(<c:out value="<%= Common.TimePeriods.DAYS %>"/>, 1, function(data) { setDateRange(data); });
          var handler = new TreeClickHandler();
          dojo.event.topic.subscribe("tree/titleClick", handler, 'titleClick');
          dojo.event.topic.subscribe("tree/expand", handler, 'expand');
      }

      //
      // Populating filterable data point list
      //
      function addPointsToSelectList(rootFolder, path){
    	  var options = "";
    	  for (var i=0; i<rootFolder.points.length; i++){
              options += "<option value=" + rootFolder.points[i].key + ">" + path + rootFolder.points[i].value + "</option>";
    	  }
    	  $("dpSelector").innerHTML += options;
    	  for (var i=0; i<rootFolder.subfolders.length; i++){
    		  addPointsToSelectList(rootFolder.subfolders[i], path + rootFolder.subfolders[i].name + "/");
    	  }
      }

      //
      // Populating data point hierarchy list
      //
      function addPointNames(folder) {
          var i;
          for (i=0; i<folder.points.length; i++)
              pointNames[folder.points[i].key] = folder.points[i].value;
          for (i=0; i<folder.subfolders.length; i++)
              addPointNames(folder.subfolders[i]);
      }

      function addFolder(folder, parent) {
          var folderNode = dojo.widget.createWidget("TreeNode", {
                  title: "<img src='images/folder_brick.png'/> "+ folder.name,
                  isFolder: "true",
                  lazyLoadData: folder
          });
          parent.addChild(folderNode);
      }

      function populateFolder(folderNode, lazyLoadData) {
          // Turn this off so as not to confuse the tree node.
          folderNode.isExpanded = false;

          var i;
          for (i=0; i<lazyLoadData.subfolders.length; i++)
              addFolder(lazyLoadData.subfolders[i], folderNode);

          for (i=0; i<lazyLoadData.points.length; i++) {
              addPoint(lazyLoadData.points[i], folderNode);
              if ($("p"+ lazyLoadData.points[i].key))
                  togglePointTreeIcon(lazyLoadData.points[i].key, false);
          }

          folderNode.expand();
      }

      function addPoint(point, parent) {
          var pointNode = dojo.widget.createWidget("TreeNode", {
                  title: "<img src='images/icon_comp.png'/> <span id='ph"+ point.key +"Name'>"+ point.value +"</span> "+
                          "<img src='images/bullet_go.png' id='ph"+ point.key +"Image' title='<fmt:message key="watchlist.addToWatchlist"/>'/>",
                  object: point
          });
          parent.addChild(pointNode);
          $("ph"+ point.key +"Image").mangoName = "pointTreeIcon";
      }

      var TreeClickHandler = function() {
          this.titleClick = function(message) {
              var widget = message.source;
              if (!widget.isFolder)
                  addToWatchList(widget.object.key);
          },

          this.expand = function(message) {
              if (message.source.lazyLoadData) {
                  var lazyLoadData = message.source.lazyLoadData;
                  delete message.source.lazyLoadData;
                  populateFolder(message.source, lazyLoadData);
              }
          }
      }

      function displayWatchList(data) {
          if (!data.points)
              // Couldn't find the watchlist. Reload the page
              window.location.reload();

          var points = data.points;
          owner = data.access == <c:out value="<%= ShareUser.ACCESS_OWNER %>"/>;

          // Add the new rows.
          for (var i=0; i<points.length; i++) {
              if (!pointNames[points[i]]) {
                  // The point id isn't in the list. Refresh the page to ensure we have current data.
                  window.location.reload();
                  return;
              }
              addToWatchListImpl(points[i]);
          }

          fixRowFormatting();
          mango.view.watchList.reset();

          var select = $("watchListSelect");
          var txt = $("newWatchListName");
          $set(txt, select.options[select.selectedIndex].text);

          // Display controls based on access
          var iconSrc;
          if (owner) {
              show("wlEditDiv", "inline");
              //Disabled for userProfiles apply function
              hide("usersEditDiv", "inline");

              // Set the share users.
              //mango.share.writeSharedUsers(data.users);
              iconSrc = "images/bullet_go.png";
          }
          else {
              hide("wlEditDiv");
              hide("usersEditDiv");
              iconSrc = "images/bullet_key.png";
          }

          var icons = getElementsByMangoName($("treeDiv"), "pointTreeIcon");
          for (var i=0; i<icons.length; i++)
              icons[i].src = iconSrc;
      }


      function showWatchListEdit() {
          openLayer("wlEdit");
          $("newWatchListName").select();
      }

      function saveWatchListName() {
          var name = $get("newWatchListName");
          var select = $("watchListSelect");
          select.options[select.selectedIndex].text = name;
          WatchListDwr.updateWatchListName(name);
          hideLayer("wlEdit");
      }

      function watchListChanged() {
          // Clear the list.
          var rows = getElementsByMangoName($("watchListTable"), "watchListRow");
          for (var i=0; i<rows.length; i++)
              removeFromWatchListImpl(rows[i].id.substring(1));

          watchlistChangeId++;
          var id = watchlistChangeId;
          WatchListDwr.setSelectedWatchList($get("watchListSelect"), function(data) {
        	  if (id == watchlistChangeId)
                  displayWatchList(data);
          });
      }

      function addWatchList(copy) {
    	  var copyId = ${NEW_ID};
    	  if (copy)
              copyId = $get("watchListSelect");

          WatchListDwr.addNewWatchList(copyId, function(watchListData) {
              var wlselect = $("watchListSelect");
              wlselect.options[wlselect.options.length] = new Option(watchListData.value, watchListData.key);
              $set(wlselect, watchListData.key);
              watchListChanged();
              maybeDisplayDeleteImg();
          });
      }

      function deleteWatchList() {
          var wlselect = $("watchListSelect");
          var deleteId = $get(wlselect);
          wlselect.options[wlselect.selectedIndex] = null;

          watchListChanged();
          WatchListDwr.deleteWatchList(deleteId);
          maybeDisplayDeleteImg();
      }

      function maybeDisplayDeleteImg() {
          var wlselect = $("watchListSelect");
          display("watchListDeleteImg", wlselect.options.length > 1);
      }

      function showWatchListUsers() {
          openLayer("usersEdit");
      }

      function openLayer(nodeId) {
          var nodeDiv = $(nodeId);
          closeLayers(nodeId);
          var divBounds = getNodeBounds(nodeDiv);
          var ancBounds = getNodeBounds(findRelativeAncestor(nodeDiv));
          nodeDiv.style.left = (ancBounds.w - divBounds.w - 30) +"px";
          showLayer(nodeDiv, true);
      }

      function closeLayers(exclude) {
          if (exclude != "wlEdit")
              hideLayer("wlEdit");
          if (exclude != "usersEdit")
              hideLayer("usersEdit");
      }

      function addSelectedToWatchList(){
    	  var pointId = $("dpSelector").value;
    	  if(pointId > 0){
    	      addToWatchList(pointId);
    	  }
      }


      //
      // Watch list membership
      //
      function addToWatchList(pointId) {
          // Check if this point is already in the watch list.
          if ($("p"+ pointId) || !owner)
              return;
          addToWatchListImpl(pointId);
          WatchListDwr.addToWatchList(pointId, mango.view.watchList.setDataImpl);
          fixRowFormatting();
      }

      var watchListCount = 0;
      function addToWatchListImpl(pointId) {
          watchListCount++;

          // Add a row for the point by cloning the template row.
          var pointContent = createFromTemplate("p_TEMPLATE_", pointId, "watchListTable");
          pointContent.mangoName = "watchListRow";

          if (owner) {
              show("p"+ pointId +"MoveUp");
              show("p"+ pointId +"MoveDown");
              show("p"+ pointId +"Delete");
          }

          $("p"+ pointId +"Name").innerHTML = pointNames[pointId];

          // Disable the element in the point list.
          togglePointTreeIcon(pointId, false);
      }

      function removeFromWatchList(pointId) {
          removeFromWatchListImpl(pointId);
          fixRowFormatting();
          WatchListDwr.removeFromWatchList(pointId);
      }

      function removeFromWatchListImpl(pointId) {
          watchListCount--;
          var pointContent = $("p"+ pointId);
          var watchListTable = $("watchListTable");
          watchListTable.removeChild(pointContent);

          // Enable the element in the point list.
          togglePointTreeIcon(pointId, true);
      }

      function togglePointTreeIcon(pointId, enable) {
          var node = $("ph"+ pointId +"Image");
          if (node) {
              if (enable)
                  dojo.html.setOpacity(node, 1);
              else
                  dojo.html.setOpacity(node, 0.2);
          }
      }

      //
      // List state updating
      //
      function moveRowDown(pointId) {
          var watchListTable = $("watchListTable");
          var rows = getElementsByMangoName(watchListTable, "watchListRow");
          var i=0;
          for (; i<rows.length; i++) {
              if (rows[i].id == pointId)
                  break;
          }
          if (i < rows.length - 1) {
              if (i == rows.length - 1)
                  watchListTable.append(rows[i]);
              else
                  watchListTable.insertBefore(rows[i], rows[i+2]);
              WatchListDwr.moveDown(pointId.substring(1));
              fixRowFormatting();
          }
      }

      function moveRowUp(pointId) {
          var watchListTable = $("watchListTable");
          var rows = getElementsByMangoName(watchListTable, "watchListRow");
          var i=0;
          for (; i<rows.length; i++) {
              if (rows[i].id == pointId)
                  break;
          }
          if (i != 0) {
              watchListTable.insertBefore(rows[i], rows[i-1]);
              WatchListDwr.moveUp(pointId.substring(1));
              fixRowFormatting();
          }
      }

      function fixRowFormatting() {
          var rows = getElementsByMangoName($("watchListTable"), "watchListRow");
          if (rows.length == 0) {
              show("emptyListMessage");
          }
          else {
              hide("emptyListMessage");
              for (var i=0; i<rows.length; i++) {
                  if (i == 0) {
                      hide(rows[i].id +"BreakRow");
                      hide(rows[i].id +"MoveUp");
                  }
                  else {
                      show(rows[i].id +"BreakRow");
                      if (owner)
                          show(rows[i].id +"MoveUp");
                  }

                  if (i == rows.length - 1)
                      hide(rows[i].id +"MoveDown");
                  else if (owner)
                      show(rows[i].id +"MoveDown");
              }
          }
      }

      function showChart(mangoId, event, source) {
    	  if (isMouseLeaveOrEnter(event, source)) {
              // Take the data in the chart textarea and put it into the chart layer div
              $set('p'+ mangoId +'ChartLayer', $get('p'+ mangoId +'Chart'));
              showMenu('p'+ mangoId +'ChartLayer', 4, 12);
    	  }
      }

      function hideChart(mangoId, event, source) {
          if (isMouseLeaveOrEnter(event, source))
        	  hideLayer('p'+ mangoId +'ChartLayer');
      }

      //
      // Image chart
      //
      function getImageChart() {
    	  isChartLive=false;
        document.getElementById("chartContainer").style.height = "500px";
    	  jQuery("#imageChartLiveImg").attr('src', 'images/control_play_blue.png');
          var width = dojo.html.getContentBox($("imageChartDiv")).width - 20;
          var height = dojo.html.getContentBox($("chartContainer")).height - 80;
    	  height = height < 100 ? 100 : height;
          startImageFader($("imageChartImg"));
          WatchListDwr.getImageChartData(getChartPointList(), $get("fromYear"), $get("fromMonth"), $get("fromDay"),
        		  $get("fromHour"), $get("fromMinute"), $get("fromSecond"), $get("fromNone"), $get("toYear"),
        		  $get("toMonth"), $get("toDay"), $get("toHour"), $get("toMinute"), $get("toSecond"), $get("toNone"),
        		  width, height, function(data) {
              $("imageChartDiv").innerHTML = data;
              stopImageFader($("imageChartImg"));

              // Make sure the length of the chart doesn't mess up the watch list display. Do async to
              // make sure the rendering gets done.
              setTimeout('dojo.widget.manager.getWidgetById("splitContainer").onResized()', 2000);
          });
      }

      function getImageChartLive(period) {
    	  var dataT;
    	  var width = dojo.html.getContentBox($("imageChartDiv")).width - 20;
    	  var height = dojo.html.getContentBox($("chartContainer")).height - 80;
    	  height = height < 200 ? 200 : height;
    	  $("imageChartDiv").height=height;
    	  var sourcet = "\"chart/"+Date.now()+"_"+period;
    	  var pointIds = $get("chartCB");
    	  if(isChartLive){
          	for (var i=0; i<pointIds.length; i++) {
          	    if (pointIds[i] == "_TEMPLATE_") {
          	    }else{
          	    	sourcet +="_"+pointIds[i];
          	    }
          	}
    	  	sourcet += ".png?w="+width+"&h="+height+"\"";
    	  	dataT = "<img id=chartTemp src="+sourcet+" onload=\"switchChart()\"/>";
    	  	$("temp").innerHTML = dataT;
    	  }
      }

      function getChartData() {
    	  var pointIds = getChartPointList();
    	  if (pointIds.length == 0)
    		  alert("<fmt:message key="watchlist.noExportables"/>");
    	  else {
              startImageFader($("chartDataImg"));
              WatchListDwr.getChartData(getChartPointList(), $get("fromYear"), $get("fromMonth"), $get("fromDay"),
                      $get("fromHour"), $get("fromMinute"), $get("fromSecond"), $get("fromNone"), $get("toYear"),
                      $get("toMonth"), $get("toDay"), $get("toHour"), $get("toMinute"), $get("toSecond"), $get("toNone"),
                      function(data) {
                  stopImageFader($("chartDataImg"));
                  window.location = "chartExport/watchListData.csv";
              });
    	  }
      }

      function getChartPointList() {
          var pointIds = $get("chartCB");
          for (var i=pointIds.length-1; i>=0; i--) {
              if (pointIds[i] == "_TEMPLATE_") {
                  pointIds.splice(i, 1);
              }
          }
          return pointIds;
      }

      // change from static to live
      function switchChartMode(){
    	  if(isChartLive){
    		  isChartLive=false;
    		  jQuery("#imageChartLiveImg").attr('src', 'images/control_play_blue.png');
          document.getElementById("imageChartDiv").style.display = "none";
    	   } else {
    		  isChartLive=true;
    		  jQuery("#imageChartLiveImg").attr('src', 'images/control_stop_blue.png');
    		  getImageChartLive(calculatePeriod());
          document.getElementById("imageChartDiv").style.display = "table-cell";
          document.getElementById("chartContainer").style.height = getCookie("chart_container_height")
    	  }
      }

      // insert new (loaded) chart
      function switchChart(){
    	  if(isChartLive){
    	  	var datan = "<img src="+jQuery("#chartTemp").attr('src')+"/>";
	  	  	$("imageChartDiv").innerHTML = datan;
	  	  	setTimeout(function(){getImageChartLive(calculatePeriod());}, 2500);
	  	  }
      }

      // calculate period for live chart
      function calculatePeriod(){
          let period
          if(!isNaN($get("prevPeriodCount"))) {
              period=$get("prevPeriodCount")*1000*60;
          } else {
              period=1*1000*60;
          }

    	  let type=$get("prevPeriodType");

    	  if(type>2)
			  period*=60;
		  if(type>3)
			  period*=24;
		  if(type==5)
			  period*=7;
		  else if(type==6)
			  period*=30;
		  else if(type==7)
			  period*=365;

		  return period;
      }

      //
      // Create report
      //
      function createReport() {
          window.location = "reports.shtm?wlid="+ $get("watchListSelect");
      }

      //
      // Cookies handling
      //
      function setCookie(cname, cvalue) {
    	    document.cookie = cname + "=" + cvalue + ";";
   	  }

      function getCookie(cname) {
    	    var name = cname + "=";
    	    var ca = document.cookie.split(';');
    	    for(var i=0; i<ca.length; i++) {
    	        var c = ca[i];
    	        while (c.charAt(0)==' ') c = c.substring(1);
    	        if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
    	    }
    	    return "";
      }

      function saveDivHeightsToCookieOnChange(){
    	  if(splitContainerHeight != jQuery("#splitContainer").height()){
    		  setCookie("split_container_height", jQuery("#splitContainer").height());
    		  splitContainerHeight = jQuery("#splitContainer").height();
  		  }
    	  if(chartContainerHeight != jQuery("#chartContainer").height()){
    		  setCookie("chart_container_height", jQuery("#chartContainer").height());
    		  chartContainerHeight = jQuery("#chartContainer").height();
  		  }
      }

      var splitContainerHeight;
      var chartContainerHeight;

      jQuery(document).ready(function(){
    	  (function($) {
    		loadjscssfile("resources/jQuery/plugins/chosen/chosen.min.css","css");
    		loadjscssfile("resources/jQuery/plugins/chosen/chosen.jquery.min.js","js");

    		splitContainerHeight = parseInt(getCookie("split_container_height"));
    		if(splitContainerHeight != null){
    			jQuery("#splitContainer").height(splitContainerHeight);
    		}
    		chartContainerHeight = parseInt(getCookie("chart_container_height"));
    		if(chartContainerHeight != null){
    			jQuery("#chartContainer").height(chartContainerHeight);
    		}

    		window.setInterval(saveDivHeightsToCookieOnChange, 2000);
   	  	})(jQuery);


             
   	});

    /** ChartJS section **/

    /** --- Variable Section --- **/
    var SECOND  = 1000;
    var MINUTE  = 60000;
    var HOUR    = 3600000;
    var DAY     = 86400000;

    var data_chartJS;

    var myChart;
    var z = document.getElementById("time_refresh");
    var refreshTime = z.options[e.selectedIndex].value;

    

    function multiTime(optionValue) {

        var timeBlock = optionValue.split("_");
        if (timeBlock[0] == "sec") {
            return SECOND * parseInt(timeBlock[1]);
        } else if (timeBlock[0] == "min") {
            return MINUTE * parseInt(timeBlock[1]);
        } else if (timeBlock[0] == "hour") {
            return HOUR * parseInt(timeBlock[1]);
        } else {
            return DAY * parseInt(timeBlock[1]);
        }

    }

    /** Data Download from API **/

    function loadDataFromApi(timestamp, dp_id,i) {

        var e = document.getElementById("time_offset");
        var strUser = e.options[e.selectedIndex].value;
        
        jQuery.ajax({
            url: webLocation + "api/point_value/getValuesFromTime/id/"+timestamp+"/"+dp_id,
            complete: function(data){},
            success: function(data){
                var chartData;
                var obj = jQuery.parseJSON(data);
                var LINE_COLOURS = ["#22bd3c","#bd7722","#bd22b0","#0b43bd","#0bc218","#bd760b"];
        
                if (strUser === "min_10") {
                    chartData = aproximateDataMinutes(obj.values, 10);
                } else if (strUser === "min_30"){
                    chartData = aproximateDataMinutes(obj.values, 30);
                } else {
                    chartData = splitToDays7(obj.values);
                }
                
                data_chartJS.labels = chartData.labels;
                data_chartJS.datasets[i].data = chartData.dataset;
                data_chartJS.datasets[i].backgroundColor = LINE_COLOURS[i];
                data_chartJS.datasets[i].borderColor = LINE_COLOURS[i];
                data_chartJS.datasets[i].label = obj.name;
                data_chartJS.datasets[i].fill = false;
        
            }
        });

    }

    var temp;
    function refreshDataFromApi(dp_id,i) {


        jQuery.ajax({
            url: webLocation + "api/point_value/getValue/id/" + dp_id,
            complete: function(data){},
            success: function(data){
                var obj = jQuery.parseJSON(data);
                temp.labels = new Date(obj.ts).getMinutes().toString();
                temp.datasets[i] = {data:[]}
                temp.datasets[i].data.push(obj.value);
            }
        })

    }



    
    




    function initNewChart(){
        
        data_chartJS = {
            labels: [],
            datasets: [],
            fill: false
        };
        
        var e = document.getElementById("time_offset");
        
        var strUser = e.options[e.selectedIndex].value;
        var timestamp = Date.now() - multiTime(strUser);
        
        var pointList = getChartPointList();
        for(var i = 0; i < pointList.length; i++) {
            data_chartJS.datasets[i] = {};
            loadDataFromApi(timestamp,pointList[i],i);
        }
        initCHT();
    }

    function initCHT() {

        if ( data_chartJS.labels.length !== 0) {
            var ctx = document.getElementById("myChart");
            myChart = new Chart(ctx, {
                type: 'line',
                data: data_chartJS,
            });
        } else {
            setTimeout(function() {initCHT();}, 1000);
        }

    }

    function aproximateDataMinutes(values, count) {

        var labels  = [];
        var now     = new Date();
        var retrunObject = {
            labels: [],
            dataset: []
        }

        values.forEach(value => {
            value.ts = new Date(value.ts).getMinutes().toString();
            
            if (labels[value.ts] === undefined) {
                labels[value.ts] = parseFloat(value.value);
            } else {
                labels[value.ts] = (labels[value.ts] + parseFloat(value.value)/2);
            }
        });

        var minutesLabel = now.getMinutes();
        for (var x = count; x > 0; x--) {
            retrunObject.labels.unshift(minutesLabel.toString())
            if (labels[minutesLabel] === undefined) {
                labels[minutesLabel] = 0;
                retrunObject.dataset.unshift(0);
            } else {
                retrunObject.dataset.unshift(labels[minutesLabel])
            }
            minutesLabel = minutesLabel - 1;
            if (minutesLabel < 0) {
                minutesLabel = minutesLabel + 60;
            }

        }

        return retrunObject;
        
    }

    function splitToDays7(values) {

        var today = new Date();
        var dates = [];
        // console.log(dates);
        values.forEach(value => {
            value.ts = new Date(value.ts).toLocaleDateString("en-US");
            if (dates[value.ts] === undefined) {
                dates[value.ts] = parseFloat(value.value);
            } else {
                dates[value.ts] = (dates[value.ts] + parseFloat(value.value))/2;
            }
            

        });
        var day = 86400000; //day in timestamp
        var date_string = today.toLocaleDateString("en-US");
        // console.log(date_string);
        var returnData = {
            labels: [],
            dataset:[],
        }
        returnData.labels.unshift(date_string);
        if (dates[date_string] === undefined) {
            dates[date_string] = 0;
            returnData.dataset.unshift(0);
        } else {
            returnData.dataset.unshift(dates[date_string])
        }
        for (var o = 6; o > 0; o--) {
            today = new Date(today - day);
            date_string = today.toLocaleDateString("en-US");
            returnData.labels.unshift(date_string);
            if (dates[date_string] === undefined) {
                dates[date_string] = 0;
                returnData.dataset.unshift(0);
            } else {
                returnData.dataset.unshift(dates[date_string])
            }

        }


        return returnData;

    }

   

    function updateChartNew() {

        for ( var x = 0; x < getChartPointList().length; x++) {
            if (temp.datasets[x] === undefined) {
                console.log("Empty!");
                return 0;
            }
        }
        console.log("Finished");
        lastIndex = myChart.data.labels.length-1
        if (myChart.data.labels[lastIndex] === temp.labels) {
            for (var x = 0; x < myChart.data.datasets.length; x++) {
                myChart.data.datasets[x].data[lastIndex] = (Number(myChart.data.datasets[x].data[lastIndex]) + parseFloat(temp.datasets[x].data[0])) / 2;
            }
        } else {
            myChart.data.labels.push(temp.labels);
            myChart.data.labels.shift();
            for (var x = 0; x < myChart.data.datasets.length; x++) {
                myChart.data.datasets[x].data.push(
                    temp.datasets[x].data[0]
                )
                myChart.data.datasets[x].data.shift();
            }
        }

        
        myChart.update();
        return 1;
            
    }

    function initChartUpdate() {

        temp = {
            labels: [],
            datasets: [],
            fill: false
        };
        var pointList = getChartPointList();
        for(var i = 0; i < pointList.length; i++){
            refreshDataFromApi(pointList[i],i);
        }

        if (updateChartNew() === 0) {
            console.log("Update");
            setTimeout(function() {updateChartNew();},1000);
        }

        setTimeout(function(){initChartUpdate();}, 25000);


    }

    </script>

    <table width="100%">
    <tr><td>
      <div id="splitContainer" dojoType="SplitContainer" orientation="horizontal" sizerWidth="3" activeSizing="true" class="borderDiv"
              widgetId="splitContainer" style="width: 100%; height: 500px; resize:vertical;">
        <div dojoType="ContentPane" sizeMin="20" sizeShare="20" style="overflow:auto;padding:2px;">
          <span class="smallTitle"><fmt:message key="watchlist.points"/></span> <tag:help id="watchListPoints"/><br/>
        <!-- <div style="margin:5px 0 10px 5px;">
          <select id="dpSelector" data-placeholder="Choose data point ..." class="chosen-select" style="width:80%;margin-bottom:10px;">
          	<option></option>
          </select>
          <img title="Add to watch list" src="images/bullet_go.png" onclick="addSelectedToWatchList()" style="cursor:pointer;">
        </div>
        <div class="horzSeparator" style="margin-bottom:10px;"></div> -->
        <img src="images/hourglass.png" id="loadingImg"/>
        <div id="treeDiv" style="display:none;"><div dojoType="Tree" widgetId="tree"></div></div>
        </div>
        <div dojoType="ContentPane" sizeMin="50" sizeShare="50" style="overflow:auto; padding:2px 10px 2px 2px;">
          <table cellpadding="0" cellspacing="0" width="100%">
            <tr>
              <td class="smallTitle"><fmt:message key="watchlist.watchlist"/> <tag:help id="watchList"/></td>
              <td align="right">
                <sst:select id="watchListSelect" value="${selectedWatchList}" onchange="watchListChanged()"
                        onmouseover="closeLayers();">
                  <c:forEach items="${watchLists}" var="wl">
                    <sst:option value="${wl.key}">${sst:escapeLessThan(wl.value)}</sst:option>
                  </c:forEach>
                </sst:select>

                <div id="wlEditDiv" style="display:inline;" onmouseover="showWatchListEdit()">
                  <tag:img id="wlEditImg" png="pencil" title="watchlist.editListName"/>
                  <div id="wlEdit" style="visibility:hidden;left:0px;top:15px;" class="labelDiv"
                          onmouseout="hideLayer(this)">
                    <fmt:message key="watchlist.newListName"/><br/>
                    <input type="text" id="newWatchListName"
                            onkeypress="if (event.keyCode==13) $('saveWatchListNameLink').onclick();"/>
                    <a class="ptr" id="saveWatchListNameLink" onclick="saveWatchListName()"><fmt:message key="common.save"/></a>
                  </div>
                </div>

                <div id="usersEditDiv" style="display:inline;" onmouseover="showWatchListUsers()">
                  <tag:img png="user" title="share.sharing" onmouseover="closeLayers();"/>
                  <div id="usersEdit" style="visibility:hidden;left:0px;top:15px;" class="labelDiv">
                    <tag:sharedUsers doxId="watchListSharing" noUsersKey="share.noWatchlistUsers"
                            closeFunction="hideLayer('usersEdit')"/>
                  </div>
                </div>

                <tag:img png="copy" onclick="addWatchList(true)" title="watchlist.copyList" onmouseover="closeLayers();"/>
                <tag:img png="add" onclick="addWatchList(false)" title="watchlist.addNewList" onmouseover="closeLayers();"/>
                <tag:img png="delete" id="watchListDeleteImg" onclick="deleteWatchList()" title="watchlist.deleteList"
                        style="display:none;" onmouseover="closeLayers();"/>
                <tag:img png="report_add" onclick="createReport()" title="watchlist.createReport" onmouseover="closeLayers();"/>
              </td>
            </tr>
          </table>
          <div id="watchListDiv" class="watchListAttr">
            <table style="display:none;">
              <tbody id="p_TEMPLATE_">
                <tr id="p_TEMPLATE_BreakRow"><td class="horzSeparator" colspan="5"></td></tr>
                <tr>
                  <td width="1">
                    <table cellpadding="0" cellspacing="0" class="rowIcons">
                      <tr>
                        <td onclick="mango.view.showChange('p'+ getMangoId(this) +'Change', 4, 12);"
                                ondblclick="mango.view.hideChange('p'+ getMangoId(this) +'Change');"
                                id="p_TEMPLATE_ChangeMin" style="display:none;"><img alt="" id="p_TEMPLATE_Changing"
                                src="images/icon_edit.png"/><div id="p_TEMPLATE_Change" class="labelDiv"
                                style="visibility:hidden;top:10px;left:1px;" ondblclick="hideLayer(this);">
                          <tag:img png="hourglass" title="common.gettingData"/>
                        </div></td>
                        <td id="p_TEMPLATE_ChartMin" style="display:none;" onmouseover="showChart(getMangoId(this), event, this);"
                                onmouseout="hideChart(getMangoId(this), event, this);"><img alt=""
                                src="images/icon_chart.png"/><div id="p_TEMPLATE_ChartLayer" class="labelDiv"
                                style="visibility:hidden;top:0;left:0;"></div><textarea
                                style="display:none;" id="p_TEMPLATE_Chart"><tag:img png="hourglass"
                                title="common.gettingData"/></textarea></td>
                      </tr>
                    </table>
                  </td>
                  <td id="p_TEMPLATE_Name" style="font-weight:bold"></td>
                  <td id="p_TEMPLATE_Value" align="center"><img src="images/hourglass.png"/></td>
                  <td id="p_TEMPLATE_Time" align="center"></td>
                  <td style="width:1px; white-space:nowrap;">
                    <input type="checkbox" name="chartCB" id="p_TEMPLATE_ChartCB" value="_TEMPLATE_" checked="checked"
                            title="<fmt:message key="watchlist.consolidatedChart"/>"/>
                    <tag:img png="icon_comp" title="watchlist.pointDetails"
                            onclick="window.location='data_point_details.shtm?dpid='+ getMangoId(this)"/>
                    <tag:img png="arrow_up_thin" id="p_TEMPLATE_MoveUp" title="watchlist.moveUp" style="display:none;"
                            onclick="moveRowUp('p'+ getMangoId(this));"/><tag:img png="arrow_down_thin"
                            id="p_TEMPLATE_MoveDown" title="watchlist.moveDown" style="display:none;"
                            onclick="moveRowDown('p'+ getMangoId(this));"/>
                    <tag:img id="p_TEMPLATE_Delete" png="bullet_delete" title="watchlist.delete" style="display:none;"
                            onclick="removeFromWatchList(getMangoId(this))"/>
                  </td>
                </tr>
                <tr><td colspan="5" style="padding-left:16px;" id="p_TEMPLATE_Messages"></td></tr>
              </tbody>
            </table>
            <table id="watchListTable" width="100%"></table>
            <div id="emptyListMessage" style="color:#888888;padding:10px;text-align:center;">
              <fmt:message key="watchlist.emptyList"/>
            </div>
          </div>
        </div>
      </div>
    </td></tr>

    <tr><td>
            <div>LiveChart</div>
            <div>
                <span>Time: </span>
                <select id="time_offset" form="carform">
                    <option value="min_10" selected>10 minutes</option>
                    <option value="min_30">30 minutes</option>
                    <option value="day_7">7 days</option>
                </select>
                <button onclick="initNewChart()">Render</button>
            </div>
            <div>
                <span>Refresh time:</span>
                <select id="time_refresh">
                    <option value="sec_1">1 second</option>
                    <option value="sec_5">5 seconds</option>
                    <option value="sec_10" selected>10 seconds</option>
                    <option value="sec_30">30 seconds</option>
                    <option value="min_1">1 minute</option>
                    <option value="min_2">2 minutes</option>
                    <option value="min_5">5 minutes</option>
                    <option value="min_10">10 minutes</option>
                </select>
                <button onclick="initChartUpdate()">StartLiveChart</button>
            </div>
            <canvas id="myChart" width="400" height="200"></canvas>
            <script>
   
            </script>
            <!-- CHART -->
      <div id="chartContainer" class="borderDiv" style="width: 100%; resize: vertical; overflow: hidden; height: 500px;">
        <table width="100%">
          <tr>
            <td class="smallTitle"><fmt:message key="watchlist.chart"/> <tag:help id="watchListCharts"/></td>
            <td align="right"><input type="text" id="prevPeriodCount" class="formVeryShort"/>
            	<select id="prevPeriodType">
                	<tag:timePeriodOptions min="true" h="true" d="true" w="true" mon="true" y="true"/>
            	</select>
            </td>
            <td  align="left"><tag:img id="imageChartLiveImg" png="control_play_blue" title="watchlist.imageChartLiveButton"
                      onclick="switchChartMode()"/><br/></td>
            <td class="vertSeparator"></td>
            <td align="right"><tag:dateRange/></td>
            <td>
              <tag:img id="imageChartImg" png="control_play_blue" title="watchlist.imageChartButton"
                      onclick="getImageChart()"/>
<%--               <tag:img id="chartDataImg" png="bullet_down" title="watchlist.chartDataButton" --%>
<!--                       onclick="getChartData()"/> -->
            </td>
          </tr>
          <tr><td colspan="6" id="imageChartDiv"></td></tr>
          <tr><td colspan="6" id="temp" style="display:none"></td></tr>
        </table>
      </div>
    </td></tr>

    </table>
  </jsp:body>
</tag:page>
