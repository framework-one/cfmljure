<cfscript>
	start = getTickCount();
	// load Clojure runtime:
	clj = new cfmljure();
	// load scripts (from project source folder - that's cfml/examples.clj):
	clj.load( '/cfml/examples' );
	end = getTickCount();
	writeOutput( 'Time taken for creation and load: #end - start#ms.<br />' );
	
	start = getTickCount();

// 1. Call Clojure by getting handles on specific functions:

	// get handle on individual functions (from namespace cfml.examples):
	greet = clj.get( 'cfml.examples.greet' );
	twice = clj.get( 'cfml.examples.twice' );
	times_2 = clj.get( 'cfml.examples.times_2' );
	// get handle on built-in map function (from namespace clojure.core):
	map = clj.get( 'clojure.core.map' );
</cfscript>
<cfoutput>
	<h1>Calls via explicit handles on methods</h1>
	
	(greet "World") = #greet._call( 'World' )#<br />
	
	<!--- pass CFML array to Clojure and loop over Clojure sequence that comes back: --->
	<cfset list = twice._call( [ 1, 2, 3 ] ) />
	(twice [ 1 2 3 ]) = <cfloop index="n" array="#list#">#n# </cfloop><br />
	
	<!--- simple function call (times_2 is def'd to an anonymous function literal: --->
	(times_2 42) = #times_2._call( 42 )#<br />
	
	<!--- call built-in Clojure function, passing raw definition of times_2 function: --->
	<cfset list = map._call( times_2._(), [ 4, 5, 6 ] ) />
	(map times_2 [ 4 5 6 ]) = <cfloop index="n" array="#list#">#n# </cfloop><br />
	
	<!--- loop over raw Clojure object (a list) in CFML: --->
	<cfset x = clj._( 'cfml.examples.x' ) />
	x = <cfloop item="n" collection="#x#">#n# </cfloop><br />
	<cfset end = getTickCount() />
	
	Time taken: #end - start#ms.<br />
	
	<cfset start = getTickCount() />
</cfoutput>
<cfscript>
// 2. Call Clojure by getting the namespaces and then calling methods directly:

	// setup my namespaces:
	cfml.examples = clj.ns( 'cfml.examples' );
	clojure.core = clj.ns( 'clojure.core' );
	
</cfscript>
<cfoutput>
	<h1>Calls via implicit method lookup (lowercase only, no -)</h1>

	(greet "World") = #cfml.examples.greet( 'World' )#<br />
	
	<!--- pass CFML array to Clojure and loop over Clojure sequence that comes back: --->
	<cfset list = cfml.examples.twice( [ 1, 2, 3 ] ) />
	(twice [ 1 2 3 ]) = <cfloop index="n" array="#list#">#n# </cfloop><br />
	
	<!--- simple function call (times_2 is def'd to an anonymous function literal: --->
	(times_2 42) = #cfml.examples.times_2( 42 )#<br />
	
	<!--- call built-in Clojure function, passing raw definition of times_2 function: --->
	<cfset list = clojure.core.map( times_2._(), [ 4, 5, 6 ] ) />
	(map times_2 [ 4 5 6 ]) = <cfloop index="n" array="#list#">#n# </cfloop><br />
	
	<!--- loop over raw Clojure object (a list) in CFML: --->
	<cfset x = cfml.examples._( 'x' ) />
	x = <cfloop item="n" collection="#x#">#n# </cfloop><br />
	<cfset end = getTickCount() />
	
	Time taken: #end - start#ms.<br />
	
	<cfset start = getTickCount() />
</cfoutput>
<cfscript>
// 3. Call Clojure by configuration and installation:
	
	namespaces = 'cfml.examples, clojure.core';
	target = { }; // normally you'd target a scope - this is just an example
	
	// install the configuration to the target 'scope':
	clj.install( namespaces, target );
	
</cfscript>
<cfoutput>
	<h1>Calls via implicit method lookup after installation to a target scope</h1>

	(greet "World") = #target.cfml.examples.greet( 'World' )#<br />
	
	<!--- pass CFML array to Clojure and loop over Clojure sequence that comes back: --->
	<cfset list = target.cfml.examples.twice( [ 1, 2, 3 ] ) />
	(twice [ 1 2 3 ]) = <cfloop index="n" array="#list#">#n# </cfloop><br />
	
	<!--- simple function call (times_2 is def'd to an anonymous function literal: --->
	(times_2 42) = #target.cfml.examples.times_2( 42 )#<br />
	
	<!--- call built-in Clojure function, passing raw definition of times_2 function: --->
	<cfset list = target.clojure.core.map( times_2._(), [ 4, 5, 6 ] ) />
	(map times_2 [ 4 5 6 ]) = <cfloop index="n" array="#list#">#n# </cfloop><br />
	
	<!--- loop over raw Clojure object (a list) in CFML: --->
	<cfset x = target.cfml.examples._( 'x' ) />
	x = <cfloop item="n" collection="#x#">#n# </cfloop><br />
	<cfset end = getTickCount() />
	
	Time taken: #end - start#ms.<br />
</cfoutput>