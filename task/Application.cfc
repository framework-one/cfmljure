component {
	this.name = hash( expandPath( "." ) );
	// cfmljure configuration:
	config = {
		project = expandPath( '../clj/task' ),
		ns = 'task.create, task.core'
	};
	
	// magic that auto-installs Clojure stuff into variables scope:
	function onRequestStart() {
		if ( !structKeyExists( application, 'clj') ||
				( structKeyExists( URL, 'reload' ) && isBoolean( URL.reload ) && URL.reload ) ) {
            writeOutput("<p>INITIALIZING THE CLOJURE RUNTIME</p>");
			application.clj = new cfmljure( config.project );
        }
        // better to install to an application variable once at startup
        // but this makes it convenient for the example:
        application.clj.install( config.ns, variables );
	}
	
	function onRequest( string targetPath ) {
		include targetPath;
	}
}
