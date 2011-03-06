<cfcomponent extends="mura.plugin.pluginGenericEventHandler">
	
	<cffunction name="onApplicationLoad">
		<cfset application.muraMonitorRemote = structNew() />
		<cfset application.muraMonitorRemote.remote = new remote(variables.pluginConfig.getSetting("Passkey")) />
		<cfset application.muraMonitorRemote.pluginConfig = variables.pluginConfig />
	</cffunction>
	
</cfcomponent>