component accessors="true" {
			
	property name="instanceKey" type="string";
	
	public any function init() {
		return this;
	}
	
	public any function authenticate (required string transactionKey) {
		if(getExpectedTransactionKey() == arguments.transactionKey) {
			return true;	
		} else {
			return false;
		}
	}
	
	public string function getInstanceKey() {
		if(!isDefined("variables.instanceKey")) {
			var enviornment = createObject("java", "java.lang.System").getenv();
			var tempID = "#enviornment.computername##enviornment.userdomain##getDirectoryFromPath(getCurrentTemplatePath())#";
			variables.instanceKey = lcase(hash(lcase(tempID)));
		}
		return variables.instanceKey;
	}
	
	public string function getExpectedTransactionKey() {
		var passkey = application.muraMonitorRemote.pluginConfig.getSetting("Passkey");
		var date = #DateFormat(now(), "MM-DD-YYYY")#;
		var passdate = lcase(hash(lcase("#passkey##date#")));
		return lcase(hash(lcase("#passdate##getInstanceKey()#")));
	}
	
	// Functions for filling status struct
	remote any function getStatus(required string transactionKey) {
		var Status = structNew();
		
		if(!authenticate(arguments.transactionKey)) {
			Status.error = "Could Not Authenticate";
		} else {
			Status.Plugins = getStatusPlugins();
			Status.Sites = getStatusSites();
			Status.Version = application.autoUpdater.getCurrentCompleteVersion();
		}
		
		return SerializeJSON(Status);
	}
	
	private array function getStatusSites() {
		var sitesArray = arrayNew(1);
		var sitesQuery = application.settingsManager.getList();
		for(var i=1; i <= sitesQuery.recordcount; i++) {
			var siteStruct = queryRowToStruct(sitesQuery, i);
			siteStruct.siteVersion = application.autoUpdater.getCurrentCompleteVersion(siteStruct.siteid);
			arrayAppend(sitesArray, siteStruct);
		}
		return sitesArray;
	}
	
	private array function getStatusPlugins() {
		var pluginsArray = arrayNew(1);
		var pluginsQuery = application.pluginManager.getAllPlugins();
		for(var i=1; i <= pluginsQuery.recordcount; i++) {
			arrayAppend(pluginsArray, queryRowToStruct(pluginsQuery, i));
		}
		return pluginsArray;
	}
	
	private array function getStatusComments() {
		var commentsArray = arrayNew(1);
		var cqo = new Query();
		cqo.setDataSource(application.configBean.getDatasource());
		cqo.setUsername(application.configBean.getUsername());
		cqo.setPassword(application.configBean.getPassword());
		cqo.setSql("
			SELECT 
				commentid,
				contentid,
				url,
				name,
				comments,
				entered,
				email,
				siteid,
				ip,
				isApproved,
				subscribe,
				userID,
				parentID,
				path
			FROM
				tcontentcomments
			WHERE
				isApproved = 0
		");
		var commentsQuery = cqo.execute().getResult();
		for(var i=1; i <= commentsQuery.recordcount; i++) {
			arrayAppend(commentsArray, queryRowToStruct(commentsQuery, i));
		}
		return commentsArray;
	}
	
	private array function getStatusTraffic() {
		var trafficArray = arrayNew(1);
		
		return trafficArray;
	}
	
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
}