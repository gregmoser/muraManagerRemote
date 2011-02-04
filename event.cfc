component extends="mura.plugin.pluginGenericEventHandler" {
	
	public void function onApplicationLoad() {
		application.muraMonitorRemote = structNew();
		application.muraMonitorRemote.remote = new remote(variables.pluginConfig.getSetting("Passkey"));
		application.muraMonitorRemote.pluginConfig = variables.pluginConfig;
	}
}
