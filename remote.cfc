<cfcomponent name="remote">
	<cfset variables.instanceKey = "" />
	
	<cffunction name="init" returnType="Any" access="public">
		<cfreturn this />
	</cffunction>	
	
	<cffunction name="authenticate">
		<cfargument name="transactionKey" required="true" type="string" /> 
		
		<cfif getExpectedTransactionKey() eq arguments.transactionKey>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="getInstanceKey">
		<cfset var sysObj = "" />
		<cfset var enviornment = "" />
		<cfset var tempID = "" />
		
		<cfif variables.instanceKey eq "">
			<cfset sysObj = createObject("java", "java.lang.System") />
			<cfset enviornment = sysObj.getenv() />
			<cfset tempID = "#enviornment.computername##enviornment.userdomain##getDirectoryFromPath(getCurrentTemplatePath())#" />
			<cfset variables.instanceKey = lcase(hash(lcase(tempID))) />
		</cfif>
		
		<cfreturn variables.InstanceKey />
	</cffunction>
	
	<cffunction name="getExpectedTransactionKey">
		<cfset var passkey = application.muraMonitorRemote.pluginConfig.getSetting("Passkey") />
		<cfset var date = #DateFormat(now(), "MM-DD-YYYY")# />
		<cfset var passdate = lcase(hash(lcase("#passkey##date#"))) />
		<cfreturn lcase(hash(lcase("#passdate##getInstanceKey()#"))) />
	</cffunction>
	
	<cffunction name="getStatus" access="remote" returntype="Any">
		<cfargument name="transactionKey" default="" />
		
		<cfset var status = structNew() />

		<cfif not authenticate(arguments.transactionKey)>
			<cfset status.error = "Could Not Authenticate" />
		<cfelse>
			<cfset status.plugins = getStatusPlugins() />
			<cfset status.sites = getStatusSites() />
			<cfset status.comments = getStatusComments() />
			<cfset status.drafts = getStatusDrafts() />
			<cfset status.coreVersion = application.autoUpdater.getCurrentCompleteVersion() />	
		</cfif>
		
		<cfreturn status />
	</cffunction>
	
	<cffunction name="getStatusComments">
		<cfset var commentsArray = arrayNew(1) />
		<cfquery name="commentsQuery" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getUsername()#" password="#application.configBean.getPassword()#" >
			SELECT 
				tcontent.Title,
				tcontent.MenuTitle,
				tcontent.Filename,
				tcontent.path,
				tsettings.site,
				tcontentcomments.commentid,
				tcontentcomments.contentid,
				tcontentcomments.url,
				tcontentcomments.name,
				tcontentcomments.comments,
				tcontentcomments.entered,
				tcontentcomments.email,
				tcontentcomments.siteid,
				tcontentcomments.ip,
				tcontentcomments.isApproved,
				tcontentcomments.subscribe,
				tcontentcomments.userID
			FROM
				tcontentcomments
			  inner join
			  	tcontent on tcontentcomments.contentid = tcontent.contentid and tcontent.Active = 1
			  inner join
				tsettings on tcontentcomments.siteid = tsettings.siteid
			WHERE
				isApproved = <cfqueryparam value="0" />
		</cfquery>
		<cfloop query="commentsQuery">
			<cfset arrayAppend(commentsArray, queryRowToStruct(commentsQuery, commentsQuery.currentRow)) />
		</cfloop>
		<cfreturn commentsArray />
	</cffunction>
	
	<cffunction name="getStatusDrafts">
		<cfset var draftsArray = arrayNew(1) />
		<cfquery name="draftsQuery" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getUsername()#" password="#application.configBean.getPassword()#" >
			SELECT
				tcontent.tcontent_ID,
				tcontent.SiteID,
				tcontent.ModuleID,
				tcontent.ParentID,
				tcontent.ContentID,
				tcontent.ContentHistID,
				tcontent.RemoteID,
				tcontent.RemoteURL,
				tcontent.RemotePubDate,
				tcontent.RemoteSourceURL,
				tcontent.RemoteSource,
				tcontent.Credits,
				tcontent.FileID,
				tcontent.Template,
				tcontent.Type,
				tcontent.subType,
				tcontent.Active,
				tcontent.OrderNo,
				tcontent.Title,
				tcontent.MenuTitle,
				tcontent.Summary,
				tcontent.Filename,
				tcontent.MetaDesc,
				tcontent.MetaKeyWords,
				tcontent.Body,
				tcontent.lastUpdate,
				tcontent.lastUpdateBy,
				tcontent.lastUpdateByID,
				tcontent.DisplayStart,
				tcontent.DisplayStop,
				tcontent.Display,
				tcontent.Approved,
				tcontent.IsNav,
				tcontent.Restricted,
				tcontent.RestrictGroups,
				tcontent.Target,
				tcontent.TargetParams,
				tcontent.responseChart,
				tcontent.responseMessage,
				tcontent.responseSendTo,
				tcontent.responseDisplayFields,
				tcontent.moduleAssign,
				tcontent.displayTitle,
				tcontent.Notes,
				tcontent.inheritObjects,
				tcontent.isFeature,
				tcontent.ReleaseDate,
				tcontent.IsLocked,
				tcontent.nextN,
				tcontent.sortBy,
				tcontent.sortDirection,
				tcontent.featureStart,
				tcontent.featureStop,
				tcontent.forceSSL,
				tcontent.audience,
				tcontent.keyPoints,
				tcontent.searchExclude,
				tcontent.path,
				tcontent.tags,
				tcontent.doCache,
				tcontent.urltitle,
				tcontent.htmltitle,
				tcontent.created,
				tcontent.mobileExclude,
				tcontent.changesetID
			FROM
				tcontent
			WHERE
				tcontent.approved = <cfqueryparam value="0" />
		</cfquery>
		<cfloop query="draftsQuery">
			<cfset arrayAppend(draftsArray, queryRowToStruct(draftsQuery, draftsQuery.currentRow)) />
		</cfloop>
		<cfreturn draftsArray /> 
	</cffunction>
		
	<cffunction name="getStatusPlugins">
		<cfset var pluginsArray = arrayNew(1) />
		<cfset var pluginsQuery = application.pluginManager.getAllPlugins() />
		<cfloop query="pluginsQuery">
			<cfset arrayAppend(pluginsArray, queryRowToStruct(pluginsQuery, pluginsQuery.currentRow)) />
		</cfloop>
		<cfreturn pluginsArray /> 
	</cffunction>
		
	<cffunction name="getStatusSites">
		<cfset var sitesArray = arrayNew(1) />
		<cfset var sitesQuery = application.settingsManager.getList() />
		<cfset var siteStruct = structNew() />
		<cfloop query="sitesQuery">
			<cfset siteStruct = queryRowToStruct(sitesQuery, sitesQuery.currentRow) />
			<cfset siteStruct.siteVersion = application.autoUpdater.getCurrentCompleteVersion(siteStruct.siteid) />
			<cfset arrayAppend(sitesArray, siteStruct) />
		</cfloop>
		<cfreturn sitesArray />
	</cffunction>
	
	<cfscript>
	/**
	* Makes a row of a query into a structure.
	* 
	* @param query      The query to work with. 
	* @param row      Row number to check. Defaults to row 1. 
	* @return Returns a structure. 
	* @author Nathan Dintenfass (nathan@changemedia.com) 
	* @version 1, December 11, 2001 
	*/
	function queryRowToStruct(query){
	    //by default, do this to the first row of the query
	    var row = 1;
	    //a var for looping
	    var ii = 1;
	    //the cols to loop over
	    var cols = listToArray(query.columnList);
	    //the struct to return
	    var stReturn = structnew();
	    //if there is a second argument, use that for the row number
	    if(arrayLen(arguments) GT 1)
	        row = arguments[2];
	    //loop over the cols and build the struct from the query row    
	    for(ii = 1; ii lte arraylen(cols); ii = ii + 1){
	        stReturn[cols[ii]] = query[cols[ii]][row];
	    }        
	    //return the struct
	    return stReturn;
	}
	</cfscript>
	
</cfcomponent>