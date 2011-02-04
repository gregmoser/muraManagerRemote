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
			Status.Plugins = application.pluginManager.getAllPlugins();
			Status.Sites = application.settingsManager.getList();
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
}