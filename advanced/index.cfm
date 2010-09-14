<cfset start = getTickCount() />
<cfscript>
	
	writeOutput( '<h1>Calls via implicit method lookup after implicit installation</h1>' );

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
<cfoutput>
	Time taken: #end - start#ms.<br />
	<a href="?reload=true">Reload the runtime</a>.
</cfoutput>
