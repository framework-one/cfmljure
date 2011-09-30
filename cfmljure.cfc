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
	
	// constructor
	public any function init( any rt = 0, string ns = "" ) {
		variables._ns = ns;
		variables._refCache = { };
		variables._nsCache = { };
		if ( isObject( rt ) ) {
			variables._rt = rt;
		} else {
			variables._rt = createObject( "java", "clojure.lang.RT" );
			// set up the public API:
			var publicNames = [ "call", "get", "install", "load", "ns" ];
			for ( var name in publicNames ) {
				this[ name ] = this[ "_" & name ];
			}
		}
		return this;
	}
	
	// public API: call(), get( string ref ), install( string namespaceList, struct target ), load( string fileList ), ns( string ref )
	// also _( string name = "" ) to deference an item or to get a reference to named item
	
	// shorthand to retrieve the raw definition
	public any function _( string name = "" ) {
		return name == "" ? variables._ref.deref() : this._get( name )._();
	}
	
	// explicit call method with up to ten positional arguments
	public any function _call() {
		switch ( arrayLen( arguments ) ) {
		case 0:
			return variables._ref.invoke();
		case 1:
			return variables._ref.invoke( arguments[1] );
		case 2:
			return variables._ref.invoke( arguments[1], arguments[2] );
		case 3:
			return variables._ref.invoke( arguments[1], arguments[2], arguments[3] );
		case 4:
			return variables._ref.invoke( arguments[1], arguments[2], arguments[3], arguments[4] );
		case 5:
			return variables._ref.invoke( arguments[1], arguments[2], arguments[3], arguments[4], arguments[5] );
		case 6:
			return variables._ref.invoke( arguments[1], arguments[2], arguments[3], arguments[4], arguments[5],
											arguments[6] );
		case 7:
			return variables._ref.invoke( arguments[1], arguments[2], arguments[3], arguments[4], arguments[5],
											arguments[6], arguments[7] );
		case 8:
			return variables._ref.invoke( arguments[1], arguments[2], arguments[3], arguments[4], arguments[5],
											arguments[6], arguments[7], arguments[8] );
		case 9:
			return variables._ref.invoke( arguments[1], arguments[2], arguments[3], arguments[4], arguments[5],
											arguments[6], arguments[7], arguments[8], arguments[9] );
		case 10:
			return variables._ref.invoke( arguments[1], arguments[2], arguments[3], arguments[4], arguments[5],
											arguments[6], arguments[7], arguments[8], arguments[9], arguments[10] );
		default:
			throw "Unsupported call();";
		}
	}
	
	// tag this instance with a specific Clojure function definition so it can be called
	public any function _def( any ref ) {
		variables._ref = ref;
		return this;
	}
	
	// get a specific Clojure function
	public any function _get( string ref ) {
		var fqRef = replace( listAppend( variables._ns, ref, "." ), "_", "-", "all" );
		if ( !structKeyExists( variables._refCache, fqRef ) ) {
			var fn = listLast( fqRef , "." );
			var ns = left( fqRef, len( fqRef ) - len( fn ) - 1 );
			var r = variables._rt.var( ns, fn );
			variables._refCache[ref] = new cfmljure( variables._rt, variables._ns )._def( r );
		}
		return variables._refCache[ref];
	}
	
	// install from a configuration into a target
	public void function _install( string namespaceList, struct target ) {
		var namespaces = listToArray( namespaceList );
		var implicitFileList = "";
		var clj = this;
		for ( var ns in namespaces ) {
			ns = trim( ns );
			var pair = variables._makePath( ns, target );
			pair.s[pair.key] = clj._ns( ns );
			// autoload based on namespaces:
			if ( ns != "clojure.core" ) {
				implicitFileList = listAppend( implicitFileList, "/" & replace( ns, ".", "/", "all" ) );
			}
		}
		clj._load( implicitFileList );
		target.clj = clj;
	}
	
	// load a list of files
	public void function _load( string fileList ) {
		// clear the reference cache if we load any files
		variables._refCache = { };
		var files = listToArray( fileList );
		for ( var file in files ) {
			variables._rt.var( "clojure.core", "load" ).invoke( file );
		}
	}
	
	// set up a context for a Clojure namespace
	public any function _ns( string ref ) {
		if ( !structKeyExists( variables._nsCache, ref ) ) {
			variables._nsCache[ref] = new cfmljure( variables._rt, ref ); 
		}
		return variables._nsCache[ref];
	}
	
	// support dynamic calling of any method in the current namespace
	public any function onMissingMethod( string missingMethodName, any missingMethodArguments ) {
		if ( left( missingMethodName, 1 ) == "_" ) {
			return this._( lCase( right( missingMethodName, len( missingMethodName ) - 1 ) ) );
		} else {
			var ref = this._get( lCase( missingMethodName ) );
			return ref._call( argumentCollection = missingMethodArguments );
		}
	}
	
	// helper for installing namespace paths
	private struct function _makePath( string path, struct target ) {
		var head = listFirst( path, "." );
		if ( listLen( path, "." ) == 1 ) {
			return { s = target, key = head };
		} else {
			if ( !structKeyExists( target, head ) ) target[head] = { };
			return _makePath( listRest( path, "." ), target[head] );
		}
	}
	
}
