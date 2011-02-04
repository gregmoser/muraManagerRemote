<plugin>
<name>mura Manager Remote</name>
<package>"muraMonitorRemote"</package>
<version>0.1</version>
<provider>Greg Moser</provider>
<providerURL>http://www.gregmoser.com</providerURL>
<category>Application</category>
<directoryFormat>packageOnly</directoryFormat>
<settings>
	<setting>
		<name>Passkey</name>  
		<label>Remote Access Passkey</label>  
		<hint>This should be a unique key that only you know.  Think of it like a password.</hint>  
		<type>text</type>
		<required>true</required>
		<validation></validation>  
		<regex></regex>
		<message></message>
		<defaultvalue></defaultvalue>  
		<optionlist></optionlist>  
		<optionlabellist></optionlabellist>  
	</setting>
</settings>

<eventHandlers>
	<eventHandler event="onApplicationLoad" component="event" persist="false"/>	
</eventHandlers>
<displayobjects location="global"></displayobjects>
</plugin>