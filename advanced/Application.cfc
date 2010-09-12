component {
	this.name = hash( getBaseTemplatePath() );
	// cfmljure configuration:
	config = {
		project = 'cfml',
		files = 'cfml/examples',
		ns = 'cfml.examples, clojure.core'
	};
	
	// magic that auto-installs Clojure stuff into variables scope:
	function onRequestStart() {
		if ( !structKeyExists( application, 'clj') ||
				( structKeyExists( URL, 'reload' ) && isBoolean( URL.reload ) && URL.reload ) ) {
			application.clj = new cfmljure();
		}
		application.clj.install( config, variables );
	}
	
	function onRequest( string targetPath ) {
		include targetPath;
	}
}