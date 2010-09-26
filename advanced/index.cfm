<cfset start = getTickCount() />
<cfoutput>
	<h1>Calls via implicit method lookup after implicit installation</h1>
	
	(greet "World") = #cfml.examples.greet( 'World' )#<br />
	
	<!--- pass CFML array to Clojure and loop over Clojure sequence that comes back: --->
	<cfset list = cfml.examples.twice( [ 1, 2, 3 ] ) />
	(twice [ 1 2 3 ]) = <cfloop index="n" array="#list#">#n# </cfloop><br />
	
	<!--- simple function call (times_2 is def'd to an anonymous function literal: --->
	(times_2 42) = #cfml.examples.times_2( 42 )#<br />
	
	<!--- call built-in Clojure function, passing raw definition of times_2 function: --->
	<cfset list = clojure.core.map( cfml.examples._( 'times_2' ), [ 4, 5, 6 ] ) />
	(map times_2 [ 4 5 6 ]) = <cfloop index="n" array="#list#">#n# </cfloop><br />
	
	<!--- loop over raw Clojure object (a list) in CFML: --->
	<cfset x = cfml.examples._( 'x' ) />
	x = <cfloop item="n" collection="#x#">#n# </cfloop><br />
	<cfset end = getTickCount() />
	
	Time taken: #end - start#ms.<br />
	<a href="?reload=true">Reload the runtime</a>.
	<a href="?reload=false">Run (without reloading)</a>.
</cfoutput>
