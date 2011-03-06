<cfparam name="url.showTKey" default="false" />
<cfoutput>
	<cfsavecontent variable="body">
		<cfif isUserInRole('S2')>
			<p>You will need the following two values to connect you "mura Manger" to this remote instance of mura.</p>
			<p>
				<strong>Instance Key: </strong>#application.muraMonitorRemote.remote.getInstanceKey()#<br />
				<strong>Passkey: </strong>#application.muraMonitorRemote.pluginConfig.getSetting("Passkey")#<br />
				<cfif url.showTKey><strong>Expected Transactoin Key: </strong>#application.muraMonitorRemote.remote.getExpectedTransactionKey()#<br /></cfif>
			</p>
		<cfelse>
			<p>You must be a Super Admin to view the settings in this plugin.</p>
		</cfif>
	</cfsavecontent>
	#application.pluginManager.renderAdminTemplate(body=body, pageTitle="mura Manager Remote")#
</cfoutput>