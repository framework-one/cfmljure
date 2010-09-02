<cfscript>
c = new cfmljure();
c.load( 'foo' );
sex = c.get( 'user.sex' );
result = sex.call( 'Hi', 'there' );
writeOutput( result );
</cfscript>
