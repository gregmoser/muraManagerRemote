component accessors="true" {
			
	property name="instanceKey" type="string";
	
	public any function init() {
		return this;
	}
	
	remote any function getStatus(required string transactionKey) {
		var Status = structNew();
		
		if(!authenticate(arguments.transactionKey)) {
			Status.error = "Could Not Authenticate";
		} else {
			Status.Plugins = getStatusPlugins();
			Status.Sites = getStatusSites();
		}
		
		return SerializeJSON(Status);
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
	private array function getStatusSites() {
		var sitesArray = arrayNew(1);
		var sitesQuery = application.settingsManager.getList();
		for(var i=1; i <= sitesQuery.recordcount; i++) {
			var site = structNew();
			site.siteID = sitesQuery.siteID[i];
			site.site = sitesQuery.site[i];
			site.theme = sitesQuery.theme[i];
			arrayAppend(sitesArray, site);
		}
		return sitesArray;
	}
	
	private array function getStatusPlugins() {
		var pluginsArray = arrayNew(1);
		var pluginsQuery = application.pluginManager.getAllPlugins();
		for(var i=1; i <= pluginsQuery.recordcount; i++) {
			var plugin = structNew();
			plugin.pluginID = pluginsQuery.pluginID[i];
			plugin.moduleID = pluginsQuery.moduleID[i];
			plugin.name = pluginsQuery.name[i];
			plugin.provider = pluginsQuery.provider[i];
			plugin.providerURL = pluginsQuery.providerURL[i];
			plugin.version = pluginsQuery.version[i];
			arrayAppend(pluginsArray, plugin);
		}
		return pluginsArray;
	}
}