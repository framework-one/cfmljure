component {
	this.name = hash( getBaseTemplatePath() );
	// cfmljure configuration:
	config = {
		project = 'cfml',
		// files = 'cfml/examples', -- this is implicitly deduced from the namespaces
		ns = 'cfml.examples, clojure.core'
	};
	
	// magic that auto-installs Clojure stuff into variables scope:
	function onRequestStart() {
		if ( !structKeyExists( application, 'clj') ||
				( structKeyExists( URL, 'reload' ) && isBoolean( URL.reload ) && URL.reload ) ) {
			application.clj = new cfmljure( config.project );
		}
		request.start = getTickCount();
		application.clj.install( config, variables );
		request.end = getTickCount();
	}
	
	function onRequest( string targetPath ) {
		include targetPath;
		writeOutput( '<br />Time taken for install: #request.end - request.start#ms.<br />' );
	}
}