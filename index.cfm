<cfscript>
// load Clojure runtime:
clj = new cfmljure();
// load scripts:
clj.load( 'examples' );

// get handle on individual functions:
greet = clj.get( 'cfmljure.examples.greet' );
twice = clj.get( 'cfmljure.examples.twice' );
times2 = clj.get( 'cfmljure.examples.times2' );
// get handle on built-in map function:
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
