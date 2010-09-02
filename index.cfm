<cfscript>
c = new cfmljure();
c.load( 'foo' );
test = c.get( 'user.test' );
result = test.call( 'Hi', 'there' );
writeOutput( result );
</cfscript>
