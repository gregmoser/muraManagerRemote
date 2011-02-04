component extends="mura.plugin.plugincfc" output="false" { 

	public void function init(any config) {
		variables.config = arguments.config;
	}
	
	// On install
	public void function install() {
		application.appInitialized=false;
	}
	
	// On update
	public void function update() {
		application.appInitialized=false;
	}
	
	// On delete
	public void function delete() {
	}
	
}