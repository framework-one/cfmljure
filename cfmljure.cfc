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
	public any function init( string project = '', any rt = 0, string ns = '' ) {
		variables._project = project;
		variables._ns = ns;
		variables._files = '';
		variables._refCache = { };
		variables._nsCache = { };
		if ( isObject( rt ) ) {
			variables._rt = rt;
		} else {
			variables._rt = createObject( 'java', 'clojure.lang.RT' );
		}
		return this;
	}
	
	// public API
	
	// explicit call method with up to five positional arguments
	public any function call() {
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
		default:
			throw "Unsupported call();";
		}
	}
	
	// get a specific Clojure function
	public any function get( string ref ) {
		var fqRef = listAppend( variables._ns, ref, '.' );
		if ( !structKeyExists( variables._refCache, fqRef ) ) {
			var fn = listLast( fqRef , '.' );
			var ns = left( fqRef, len( fqRef ) - len( fn ) - 1 );
			var r = variables._rt.var( ns, fn );
			variables._refCache[ref] = new cfmljure( variables._project, variables._rt, variables._ns )._def( r );
		}
		return variables._refCache[ref];
	}
	
	// install from a configuration into a target
	public void function install( struct config, struct target ) {
		var project = structKeyExists( config, 'project' ) ? config.project : '';
		var fileList = structKeyExists( config, 'files' ) ? config.files : '';
		var namespaceList = structKeyExists( config, 'ns' ) ? config.ns : '';
		var clj = this;
		if ( project != variables._project ) {
			clj = new cfmljure( project, variables._rt, variables._ns );
			clj.load( fileList );
		} else if ( fileList != variables._files ) {
			clj.load( fileList );
		}
		target.clj = clj;
		var namespaces = listToArray( namespaceList );
		var implicitFileList = '';
		var ns = 0; // CFBuilder barfs on for ( var ns in namespaces ) so declare it separately!
		for ( ns in namespaces ) {
			var _ns = trim( ns );
			var pair = _makePath( _ns, target );
			pair.s[pair.key] = clj.ns( _ns );
			if ( fileList == '' ) {
				// autoload based on namespaces:
				if ( listFirst( _ns, '.' ) != 'clojure' ) {
					implicitFileList = listAppend( implicitFileList, replace( _ns, '.', '/', 'all' ) );
				}
			}
		}
		if ( implicitFileList != '' && implicitFileList != variables._files ) {
			clj.load( implicitFileList );
		}
	}
	
	// load a list of files
	public void function load( string fileList ) {
		if ( fileList == '' ) return;
		// clear the reference cache if we load any files
		variables._refCache = { };
		variables._files = listAppend( variables._files, fileList );
		var prefix = variables._project == '' ? '' : variables._project & '/src/';
		var files = listToArray( fileList );
		var file = 0; // CFBuilder barfs on for ( var file in files ) so declare it separately!
		for ( file in files ) {
			variables._rt.loadResourceScript( 'clj/' & prefix & trim( file ) & '.clj' );
		}
	}
	
	// set up a context for a Clojure namespace
	public any function ns( string ref ) {
		if ( !structKeyExists( variables._nsCache, ref ) ) {
			variables._nsCache[ref] = new cfmljure( variables._project, variables._rt, ref ); 
		}
		return variables._nsCache[ref];
	}
	
	// shorthand to retrieve the raw definition
	public any function _( string name = '' ) {
		return name == '' ? variables._ref.deref() : get( name )._();
	}
	
	// tag this instance with a specific Clojure function definition so it can be called
	public any function _def( any ref ) {
		variables._ref = ref;
		return this;
	}
	
	// support dynamic calling of any method in the current namespace
	public any function onMissingMethod( string missingMethodName, any missingMethodArguments ) {
		var ref = get( lCase( missingMethodName ) );
		return ref.call( argumentCollection = missingMethodArguments );
	}
	
	// helper for installing namespace paths
	private struct function _makePath( string path, struct target ) {
		var head = listFirst( path, '.' );
		if ( listLen( path, '.' ) == 1 ) {
			return { s = target, key = head };
		} else {
			if ( !structKeyExists( target, head ) ) target[head] = { };
			return _makePath( listRest( path, '.' ), target[head] );
		}
	}
	
}
