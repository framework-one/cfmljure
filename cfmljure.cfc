component {
	
	variables.clj = { };
	
	public any function init() {
		variables.rt = createObject( 'java', 'clojure.lang.RT' );
		return this;
	}
	
	public void function load( string file ) {
		variables.rt.loadResourceScript( file & '.clj' );
	}
	
	public any function get( string ref ) {
		if ( !structKeyExists( variables.clj, ref ) ) {
			var fn = listLast( ref , '.' );
			var ns = left( ref, len( ref ) - len( fn ) - 1 );
			var r = variables.rt.var( ns, fn );
			variables.clj[ref] = createObject( 'component', 'cfmljure' ).def( r );
		}
		return variables.clj[ref];
	}

	public any function def( any ref ) {
		variables.ref = ref;
		return this;
	}
	
	public any function call() {
		switch ( arrayLen( arguments ) ) {
		case 0:
			return variables.ref.invoke();
		case 1:
			return variables.ref.invoke( arguments[1] );
		case 2:
			return variables.ref.invoke( arguments[1], arguments[2] );
		case 3:
			return variables.ref.invoke( arguments[1], arguments[2], arguments[3] );
		case 4:
			return variables.ref.invoke( arguments[1], arguments[2], arguments[3], arguments[4] );
		case 5:
			return variables.ref.invoke( arguments[1], arguments[2], arguments[3], arguments[4], arguments[5] );
		default:
			throw "Unsupported call();";
		}
	}
	
}
