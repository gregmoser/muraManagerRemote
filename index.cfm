<cfoutput>
	<cfsavecontent variable="body">
	<p>You will need the following two values to connect you "mura Manger" to this remote instance of mura.</p>
	<p>
		<strong>Instance Key: </strong> #application.muraMonitorRemote.remote.getInstanceKey()#<br />
		<strong>Passkey: </strong>#application.muraMonitorRemote.pluginConfig.getSetting("Passkey")#<br />
		<strong>expTran: </strong>#application.muraMonitorRemote.remote.getExpectedTransactionKey()#
	</p>
	</cfsavecontent>
	#application.pluginManager.renderAdminTemplate(body=body, pageTitle="mura Manager Remote")#
</cfoutput>