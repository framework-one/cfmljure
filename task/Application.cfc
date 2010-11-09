component {
	this.name = hash( getBaseTemplatePath() );
	// cfmljure configuration:
	config = {
		project = 'task',
		ns = 'task.create, task.core'
	};
	
	// magic that auto-installs Clojure stuff into variables scope:
	function onRequestStart() {
		if ( !structKeyExists( application, 'clj') ||
				( structKeyExists( URL, 'reload' ) && isBoolean( URL.reload ) && URL.reload ) ) {
			application.clj = new cfmljure( config.project );
		}
		application.clj.install( config, variables );
	}
	
	function onRequest( string targetPath ) {
		include targetPath;
	}
}