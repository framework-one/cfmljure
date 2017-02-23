<!---
    cfmljure examples, reworked for Adobe ColdFusion (ACF).

    The changes are as follows:

        * ACF wrongly interprets int literals as strings, so they must be cast as java ints using javaCast
        * The 4th example has been changed from a collection loop to an array loop, as the collection loop will not work
          on an array in ACF (see http://blog.getrailo.com/post.cfm/fun-with-cfloop-collection-array)
--->
<h1>cfmljure examples</h1>

<h2>Basic example</h2>
<p>This example is inline in index.cfm. Normally you'd load the Clojure runtime and
    install the namespaces you want to use just once, at application startup (instead of inline
    on every request like this).</p>
<cfscript>
	start = getTickCount();
	// Load Clojure runtime - you'd normally do this once at application startup:
	clj = new framework.cfmljure( project = expandPath( "./clj/cfml" ) );
	end = getTickCount();
	writeOutput( 'Time taken for creation and load: #end - start#ms.<br />' );

    // Call Clojure by configuration and installation:
	start = getTickCount();

	namespaces = 'cfml.examples, clojure.core'; // could be an array
	target = { }; // normally you'd target a scope - this is just an example

	// install the configuration to the target 'scope':
	clj.install( namespaces, target );

	end = getTickCount();
    writeOutput( '<h3>Calls after installation to a target scope</h3>' );
	writeOutput( 'Time taken for install: #end - start#ms.<br /><br />' );

	start = getTickCount();
</cfscript>
<cfoutput>
	(greet "World") = #target.cfml.examples.greet( 'World' )#<br />

	<!--- pass CFML array to Clojure and loop over Clojure sequence that comes back: --->
	<cfset list = target.cfml.examples.twice( [ javaCast("int", 1), javaCast("int", 2), javaCast("int", 3) ] ) />
	(twice [ 1 2 3 ]) = <cfloop index="n" array="#list#">#n# </cfloop><br />

	<!--- simple function call (times_2 is def'd to an anonymous function literal: --->
	(times_2 42) = #target.cfml.examples.times_2( javaCast("int",42) )#<br />

	<!--- call built-in Clojure function, passing raw definition of times_2 function: --->
	<cfset list = target.clojure.core.map( target.cfml.examples._times_2(), [ javaCast("int", 4), javaCast("int", 5), javaCast("int", 6) ] ) />
	(map times_2 [ 4 5 6 ]) = <cfloop index="n" array="#list#">#n# </cfloop><br />

	<!--- loop over raw Clojure object (a list) in CFML: --->
	<cfset x = target.cfml.examples._x() />
	x = <cfloop index="n" array="#x#">#n# </cfloop><br />
	<cfset end = getTickCount() />

	Time taken for code examples: #end - start#ms.<br />
</cfoutput>
<h2>Advanced example</h2>
<p>This example sets up the Clojure runtime at application startup and
    uses a Derby database to store tasks. The view files are CFML but
    all the business logic is Clojure.</p>
<p><a href="task/index.cfm">Click to try the Tasks example</a>.</p>
