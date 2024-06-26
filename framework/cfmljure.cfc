component {
    variables._fw1_version      = "4.1.0-SNAPSHOT";
    variables._cfmljure_version = "1.2.0-SNAPSHOT";
/*
	Copyright (c) 2012-2024, Sean Corfield

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
    public any function init( string project = "", numeric timeout = 300,
                              string lein = "lein", // to allow default to be overridden
                              string boot = "", // to allow Boot to be selected instead
                              string clojure = "", // to allow clojure to be selected instead
                              string ns = "", any root = 0 ) {
        variables.refCache = { };
        var javaLangSystem = createObject( "java", "java.lang.System" );
        variables.out = javaLangSystem.out;
        var debug = javaLangSystem.getenv( "DEBUG_CFMLJURE" );
        variables.debug = isNull( debug ) ? false : ( debug == "true" );
        if ( project != "" ) {
            variables._clj_root = this;
            variables._clj_ns = "";
            var nl = javaLangSystem.getProperty( "line.separator" );
            var fs = javaLangSystem.getProperty( "file.separator" );
            var nixLike = fs == "/";
            var script = "";
            var cmd = { };
            var tmpDir = "";
            var buildType = "";
            var buildCommand = "";
            if ( len( clojure ) ) {
                buildType = "clojure";
                buildCommand = clojure;
            } else if ( len( boot ) ) {
                // select Boot build tool
                buildType = "boot";
                buildCommand = boot & " aot show -C";
            } else {
                buildType = "lein";
                buildCommand = lein & " with-profile production do clean, compile, classpath";
            }
            if ( nixLike ) {
                // *nix / Mac
                tmpDir = "/tmp";
                script = getTempFile( tmpDir, buildType );
                cmd = {
                    cd = "cd", run = "/bin/sh", arg = script,
                    // make sure we are not trying to run under root account!
                    preflightCmd = "if [ `id -u` -eq 0 ]; then >&2 echo 'DO NOT RUN CFML OR CFMLJURE AS ROOT!'; exit 1; fi#nl#",
                    exitCmd = "exit 0#nl#"
                };
                // ensure Servlet container's options do not affect the build tool:
                buildCommand = "JAVA_OPTS= " & buildCommand;
            } else {
                // Windows
                tmpDir = replace( javaLangSystem.getenv( "TEMP" ), chr(92), "/", "all" );
                script = getTempFile( tmpDir, buildType );
                script &= ".bat";
                cmd = {
                    cd = "chdir", run = script, arg = "",
                    preflightCmd = "", exitCmd = ""
                };
            }
            variables.__lockFilePath = tmpDir & "/cfmljure.lock";
            fileWrite(
                script,
                "#cmd.cd# #project#" & nl &
                    cmd.preflightCmd &
                    buildCommand & nl &
                    cmd.exitCmd
            );
            var classpath = "";
            var errors = "";
            __acquireLock( variables.__lockFilePath );
            try {
                if ( variables.debug ) variables.out.println( "cmd: #buildCommand#" );
                cfexecute(
                    name="#cmd.run#", arguments="#cmd.arg#",
                    variable="classpath", errorVariable="errors",
                    timeout="#timeout#" );
            } catch ( any e ) {
                __releaseLock( variables.__lockFilePath );
                if ( structKeyExists( URL, "cfmljure" ) &&
                     URL.cfmljure == "abortOnFailure" ) {
                    writeDump( var = cmd, label = "Unable to cfexecute this script" );
                    if ( !isNull( classpath ) ) writeDump( var = classpath, label = "Build (#buildType#) stdout" );
                    if ( !isNull( errors ) ) writeDump( var = errors, label = "Build (#buildType#) stderr" );
                    writeDump( var = e, label = "Full stack trace" );
                    abort;
                }
                throw e;
            }
            __releaseLock( variables.__lockFilePath );
            try {
                fileDelete( script );
            } catch ( any e ) {
                variables.out.println( "Unable to delete #script#!!!" );
            }
            // could be multiple lines so clean it up:
            classpath = listLast( classpath, nl );
            classpath = replace( classpath, nl, "" );
            // turn the classpath into a URL list:
            var classpathParts = listToArray( classpath, javaLangSystem.getProperty( "path.separator" ) );
            if ( variables.debug ) arraySort( classpathParts, "text" );
            var urls = [ ];
            var cfmlInteropAvailable = false;
            for ( var part in classpathParts ) {
                if ( !fileExists( part ) && !directoryExists( part ) ) {
                    try {
                        directoryCreate( part );
                    } catch ( any e ) {
                        // ignore and hope for the best - really!
                    }
                }
                if ( !part.endsWith( ".jar" ) && !part.endsWith( fs ) ) {
                    part &= fs;
                }
                if ( REFind( "cfml-interop-[-.0-9a-zA-Z_]+\.jar", part ) ) {
                    cfmlInteropAvailable = true;
                }
                // TODO: shortcut this...
                if ( variables.debug ) variables.out.println( "cp: #part#" );
                var file = createObject( "java", "java.io.File" ).init( part );
                var asURL = file.toURI().toURL();
                if ( find( "servlet-api", asURL.toString() ) ) {
                    variables.out.println( "Refusing to load #asURL# because it may conflict with CFML's context!" );
                } else {
                    arrayAppend( urls, asURL );
                }
            }
            var clazz = createObject( "java", "java.lang.Class" );
            var arrayType = createObject( "java", "java.lang.reflect.Array" );
            var arrayInstance = arrayType.newInstance( clazz.forName("java.net.URL"), urls.size() );
            // replace the classloader with all the necessary URLs added:
            var threadProxy = createObject( "java", "java.lang.Thread" );
            var appCL = threadProxy.currentThread().getContextClassLoader();
            appCL = createObject( "java", "java.net.URLClassLoader" ).init(
                urls.toArray( arrayInstance ),
                appCL
            );
            threadProxy.currentThread().setContextClassLoader( appCL );
            try {
                var clj6 = appCL.loadClass( "clojure.java.api.Clojure" );
                variables.out.println( "Detected Clojure 1.6 or later (API)" );
                this._clj_var  = clj6.getMethod( "var", __classes( "Object", 2 ) );
                this._clj_read = clj6.getMethod( "read", __classes( "String" ) );
            } catch ( any e ) {
                try {
                    var clj5 = appCL.loadClass( "clojure.lang.RT" );
                    variables.out.println( "Falling back to Clojure 1.5 or earlier (RT)" );
                    this._clj_var  = clj5.getMethod( "var", __classes( "String", 2 ) );
                    this._clj_read = clj5.getMethod( "readString", __classes( "String" ) );
                } catch ( any e ) {
                    variables.out.println( "Unable to load any version of Clojure" );
                    variables.out.println( "Aborting install of Clojure integration!" );
                    // promote the only part of the API that will work
                    this.isAvailable = this.__isAvailable;
                    return this;
                }
            }
            // promote API:
            this.install = this.__install;
            this.isAvailable = this.__isAvailable;
            this.read = this.__read;
            var autoLoaded = "clojure.core,clojure.walk";
            if ( cfmlInteropAvailable ) {
                variables.out.println( "Detected cfml-interop for interop" );
                // perform the best interop we can:
                autoLoaded = listAppend( autoLoaded, "cfml.interop" );
                this.toCFML = this.__toCljStruct;
                this.toClojure = this.__toCljStruct;
            } else {
                variables.out.println( "Falling back to clojure.walk for interop" );
                // fall back to basic interop:
                this.toCFML = this.__toCFML;
                this.toClojure = this.__toClojure;
            }
            __install( autoLoaded, this );
            __install_proxy();
        } else if ( ns != "" ) {
            variables._clj_root = root;
            variables._clj_ns = ns;
        } else {
            throw "cfmljure requires the path of a Clojure project.";
        }
        return this;
    }

    public any function _( string name ) {
        return __( name, true );
    }

    private void function __acquireLock( string lockFilePath ) {
        var waits = 0;
        while ( fileExists( lockFilePath ) ) {
            if ( waits > 3 ) throw "cfmljure waited a long time for #lockFilePath# to be deleted - perhaps you should delete it manually and try again?";
            variables.out.println( "Waiting for #lockFilePath# to be deleted..." );
            sleep( ( 15 * randRange( 1, 15 ) ) * 1000 );
            ++waits;
        }
        fileWrite( lockFilePath, "" );
    }

    private void function __releaseLock( string lockFilePath ) {
        try {
            fileDelete( lockFilePath );
        } catch ( any e ) {
            variables.out.println( "Unable to delete #lockFilePath#!!!" );
        }
    }

    public any function __install( any nsList, struct target ) {
        if ( !isArray( nsList ) ) nsList = listToArray( nsList );
        try {
            __acquireLock( variables.__lockFilePath );
            for ( var ns in nsList ) {
                try {
                    if ( variables.debug ) variables.out.println( "About to install #trim( ns )#..." );
                    __1_install( trim( ns ), target );
                } catch ( any e ) {
                    variables.out.println( "Unable to install #trim( ns )# due to #e.message#... rethrowing..." );
                    var javaLangSystem = createObject( "java", "java.lang.System" );
                    javaLangSystem.exit( 1 );
                    rethrow;
                }
            }
        } finally {
            __releaseLock( variables.__lockFilePath );
        }
    }

    public boolean function __isAvailable() {
        return structKeyExists( this, "_clj_var" ) ||
            structKeyExists( variables, "_clj_root" ) &&
            structKeyExists( variables._clj_root, "_clj_var" );
    }

    public any function __read( string expr ) {
        var args = [ expr ];
        return variables._clj_root._clj_read.invoke( javaCast( "null", 0 ), args.toArray() );
    }

    public any function __toCFML( any expr ) {
        return this.clojure.walk.stringify_keys(
            isNull( expr ) ? javaCast( "null", 0 ) : expr
        );
    }

    public any function __toCljStruct( any expr ) {
        return this.cfml.interop.to_clj_struct(
            isNull( expr ) ? javaCast( "null", 0 ) : expr
        );
    }

    public any function __toClojure( any expr ) {
        return this.clojure.walk.keywordize_keys(
            isNull( expr ) ? javaCast( "null", 0 ) :
                ( isStruct( expr ) ?
                  this.clojure.core.into( this.clojure.core.hash_map(), expr ) :
                  expr )
        );
    }

    // helper functions:

    public any function __( string name, boolean autoDeref ) {
        if ( !structKeyExists( variables.refCache, name ) ) {
            if ( autoDeref ) {
                variables.refCache[ name ] = variables._clj_root.clojure.core.deref( __var( variables._clj_ns, name ) );
            } else {
                variables.refCache[ name ] = __var( variables._clj_ns, name );
            }
        }
        return variables.refCache[ name ];
    }

    public any function __classes( string name, numeric n = 1, string prefix = "java.lang" ) {
        var result = createObject( "java", "java.util.ArrayList" ).init();
        var clazz = createObject( "java", "java.lang.Class" );
        var type = clazz.forName( prefix & "." & name );
        while ( n-- > 0 ) result.add( type );
        var classType = createObject( "java", "java.lang.Class" );
        var arrayType = createObject( "java", "java.lang.reflect.Array" );
        var arrayInstance = arrayType.newInstance( clazz.forName("java.lang.Class"), result.size() );
        return result.toArray( arrayInstance );
    }

    public any function __1_install( string ns, struct target ) {
        __require( ns );
        __2_install( listToArray( ns, "." ), target );
    }

    public any function __2_install( array nsParts, struct target ) {
        var first = replace( nsParts[ 1 ], "-", "_", "all" );
        var ns = replace( nsParts[ 1 ], "_", "-", "all" );
        var n = arrayLen( nsParts );
        if ( !structKeyExists( target, first ) ) {
            target[ first ] = new cfmljure(
                ns = listAppend( variables._clj_ns, ns, "." ),
                root = variables._clj_root
            );
        }
        if ( n > 1 ) {
            arrayDeleteAt( nsParts, 1 );
            target[ first ].__2_install( nsParts, target[ first ] );
        }
    }

    public any function __call( any v, any argsArray ) {
        var args = [];
        for ( var ix in argsArray ) {
          args[ ix ] = argsArray[ ix ];
        }
        try {
          return variables._clj_root.__cfml_proxy.invoke( v, args );
        } catch ( any _ ) {
          throw "invocation failed for: #variables._clj_root.clojure.core.str( v )#";
        }
    }

    public string function __name() {
        return variables._clj_ns;
    }

    public void function __install_proxy() {
      var eval = __var( "clojure.core", "eval" );
      eval.invoke( this.read(
        // this ends up in clojure.core:
        "(defn cfml-invoke [v args]
          (try
            (apply v args)
            (catch Throwable t
              (println (ex-info (name :invocation-failed)
                                {:fn v :args (seq args)}
                                t))
              (throw t))))"

      ) );
      variables._clj_root.__cfml_proxy = __var( "clojure.core", "cfml-invoke" );
    }

    public void function __require( string ns ) {
        if ( !structKeyExists( variables, "_clj_resolve" ) ) {
            this._clj_resolve = __var( "clojure.core", "resolve" );
        }
        if ( !structKeyExists( variables, "_clj_require" ) ) {
            // use Clojure 1.10's serialized-require if available
            var require = this._clj_resolve.invoke( this.read( "clojure.core/serialized-require" ) );
            if ( isNull( require ) ) {
                variables.out.println( "Falling back to Clojure 1.9 or earlier (require)" );
                require = this._clj_resolve.invoke( this.read( "clojure.core/require" ) );
            } else {
                variables.out.println( "Detected Clojure 1.10 or later (serialized-require)" );
            }
            variables._clj_require = require;
        }
        variables._clj_require.invoke( this.read( ns ) );
    }

    public any function __clj_name( string name ) {
        var encodes = [ "_qmark_", "_bang_", "_gt_", "_lt_", "_eq_", "_star_", "_" ];
        var decodes = [ "?",       "!",      ">",    "<",    "=",    "*",      "-" ];
        var n = encodes.len();
        for ( var i = 1; i <= n; ++i ) {
            name = replaceNoCase( name, encodes[i], decodes[i], "all" );
        }
        return lCase( name );
    }

    public any function __var( string ns, string name ) {
      name = __clj_name( name );
      var args = [ lCase( ns ), name ];
      return variables._clj_root._clj_var.invoke( javaCast( "null", 0 ), args.toArray() );
  }

    public any function onMissingMethod( string missingMethodName, any missingMethodArguments ) {
        if ( variables.debug ) {
          var args = "";
          for ( var a in missingMethodArguments ) {
            if ( isNull( missingMethodArguments[a] ) ) {
              args &= ", nil";
            } else if ( isSimpleValue( missingMethodArguments[a] ) ) {
              args &= ", " & missingMethodArguments[a];
            } else {
              var arg = "*";
              try {
                var name = __var( "clojure.core", "name" );
                var namespace = __var( "clojure.core", "namespace" );
                var is_kw = __var( "clojure.core", "keyword?" );
                var is_sym = __var( "clojure.core", "symbol?" );
                var add_name = "";
                if ( is_kw.invoke( missingMethodArguments[a] ) ) {
                  add_name = ":";
                }
                if ( is_sym.invoke( missingMethodArguments[a] ) ) {
                  add_name = "'";
                }
                if ( len( add_name ) ) {
                  arg = add_name;
                  var ns = namespace.invoke( missingMethodArguments[a] );
                  if ( !isNull( ns ) ) arg &= ns & "/";
                  arg &= name.invoke( missingMethodArguments[a] );
                }
              } catch ( any ) { }
              args &= ", " & arg;
            }
          }
          variables.out.println( "Calling: #variables._clj_ns#/#missingMethodName# #args#" );
        }
        var var_reference = false;
        if ( left( missingMethodName, 1 ) == "_" ) {
            // watch out for names that begin with something that maps to _
            var poss_clj_var = variables._clj_root._clj_resolve.invoke(
                this.__read( variables._clj_ns & "/" & __clj_name( missingMethodName ) )
            );
            var_reference = isNull( poss_clj_var );
        }
        if ( var_reference ) {
            return __( right( missingMethodName, len( missingMethodName ) - 1 ), true );
        } else {
            var clj_var = __( missingMethodName, false );
            if ( isNull( clj_var ) ) {
                throw "Unable to resolve #variables._clj_ns#/#missingMethodName#";
            }
            return __call( clj_var, missingMethodArguments );
        }
    }

}
