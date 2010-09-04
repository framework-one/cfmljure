component {
/*
	Copyright (c) 2010, Sean Corfield

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/
	
	variables.clj = { };
	
	public any function init( string project = '' ) {
		variables.project = project;
		variables.rt = createObject( 'java', 'clojure.lang.RT' );
		return this;
	}
	
	public void function load( string fileList ) {
		var prefix = variables.project == '' ? '' : variables.project & '/src/';
		var files = listToArray( fileList );
		var file = 0; // CFBuilder barfs on for ( var file in files ) so declare it separately!
		for ( file in files ) {
			variables.rt.loadResourceScript( 'clj/' & prefix & file & '.clj' );
		}
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

	public any function def( any defn ) {
		this.defn = defn;
		return this;
	}
	
	public any function call() {
		switch ( arrayLen( arguments ) ) {
		case 0:
			return this.defn.invoke();
		case 1:
			return this.defn.invoke( arguments[1] );
		case 2:
			return this.defn.invoke( arguments[1], arguments[2] );
		case 3:
			return this.defn.invoke( arguments[1], arguments[2], arguments[3] );
		case 4:
			return this.defn.invoke( arguments[1], arguments[2], arguments[3], arguments[4] );
		case 5:
			return this.defn.invoke( arguments[1], arguments[2], arguments[3], arguments[4], arguments[5] );
		default:
			throw "Unsupported call();";
		}
	}
	
}
