<cfset start = getTickCount() />
<cfscript>
	// load Clojure runtime (for cfml project - search path root is clj/cfml/src/):
	clj = new cfmljure( 'cfml' );
	// load scripts (from project source folder - that's clj/cfml/src/cfml/examples.clj):
	clj.load( 'cfml/examples' );
</cfscript>
<cfset end = getTickCount() />
<cfoutput>Time taken for creation and load: #end - start#ms.<br /></cfoutput>
<cfset start = getTickCount() />
<cfscript>
// we can either get handles on specific functions like this:

	writeOutput( '<h1>Calls via explicit handles on methods</h1>' );

	// get handle on individual functions (from namespace cfml.examples):
	greet = clj.get( 'cfml.examples.greet' );
	twice = clj.get( 'cfml.examples.twice' );
	times2 = clj.get( 'cfml.examples.times2' );
	// get handle on built-in map function (from namespace clojure.core):
	map = clj.get( 'clojure.core.map' );
	
	// call functions:
	
	// simple function call:
	writeOutput( '(greet "World") = ' & greet.call( 'World' ) & '<br />' );
	
	// pass CFML array to Clojure and loop over Clojure sequence that comes back:
	list = twice.call( [ 1, 2, 3 ] );
	writeOutput( '(twice [ 1 2 3 ]) = ' );
	for ( n in list ) writeOutput( n & ' ' );
	writeOutput( '<br />' );
	
	// simple function call (times2 is def'd to an anonymous function literal:
	writeOutput( '(times2 42) = ' & times2.call( 42 ) & '<br />' );
	
	// call built-in Clojure function, passing raw definition of times2 function:
	list = map.call( times2.defn, [ 4, 5, 6 ] );
	writeOutput( '(map times2 [ 4 5 6 ]) = ' );
	for ( n in list ) writeOutput( n & ' ' );
	writeOutput( '<br />' );
	
</cfscript>
<cfset end = getTickCount() />
<cfoutput>Time taken: #end - start#ms.<br /></cfoutput>
<cfset start = getTickCount() />
<cfscript>
// or we can get the namespaces and then call methods directly:

	// setup my namespaces:
	cfml.examples = clj.ns( 'cfml.examples' );
	clojure.core = clj.ns( 'clojure.core' );
	
	writeOutput( '<h1>Calls via implicit method lookup (lowercase only, no -)</h1>' );

	// call functions:
	
	// simple function call:
	writeOutput( '(greet "World") = ' & cfml.examples.greet( 'World' ) & '<br />' );
	
	// pass CFML array to Clojure and loop over Clojure sequence that comes back:
	list = cfml.examples.twice( [ 1, 2, 3 ] );
	writeOutput( '(twice [ 1 2 3 ]) = ' );
	for ( n in list ) writeOutput( n & ' ' );
	writeOutput( '<br />' );
	
	// simple function call (times2 is def'd to an anonymous function literal:
	writeOutput( '(times2 42) = ' & cfml.examples.times2( 42 ) & '<br />' );
	
	// call built-in Clojure function, passing raw definition of times2 function:
	list = clojure.core.map( cfml.examples._( 'times2' ), [ 4, 5, 6 ] );
	writeOutput( '(map times2 [ 4 5 6 ]) = ' );
	for ( n in list ) writeOutput( n & ' ' );
	writeOutput( '<br />' );

</cfscript>
<cfset end = getTickCount() />
<cfoutput>Time taken: #end - start#ms.<br /></cfoutput>
<cfset start = getTickCount() />
<cfscript>
// by configuration and installation:
	
	config = {
		project = 'cfml',
		files = 'cfml/examples',
		ns = 'cfml.examples, clojure.core'
	};
	target = { }; // normally you'd target a scope - this is just an example
	
	// install the configuration to the target 'scope':
	clj.install( config, target );
	
	writeOutput( '<h1>Calls via implicit method lookup after installation to a target scope</h1>' );

	// call functions:
	
	// simple function call:
	writeOutput( '(greet "World") = ' & target.cfml.examples.greet( 'World' ) & '<br />' );
	
	// pass CFML array to Clojure and loop over Clojure sequence that comes back:
	list = target.cfml.examples.twice( [ 1, 2, 3 ] );
	writeOutput( '(twice [ 1 2 3 ]) = ' );
	for ( n in list ) writeOutput( n & ' ' );
	writeOutput( '<br />' );
	
	// simple function call (times2 is def'd to an anonymous function literal:
	writeOutput( '(times2 42) = ' & target.cfml.examples.times2( 42 ) & '<br />' );
	
	// call built-in Clojure function, passing raw definition of times2 function:
	list = target.clojure.core.map( target.cfml.examples._( 'times2' ), [ 4, 5, 6 ] );
	writeOutput( '(map times2 [ 4 5 6 ]) = ' );
	for ( n in list ) writeOutput( n & ' ' );
	writeOutput( '<br />' );

</cfscript>
<cfset end = getTickCount() />
<cfoutput>Time taken: #end - start#ms.</cfoutput>