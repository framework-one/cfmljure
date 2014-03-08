component {

    public any function init( string project = "", numeric timeout = 300,
                              string ns = "", any v = 0 ) {
        if ( project != "" ) {
            variables._clj_ns = "";
            var script = getTempFile( getTempDirectory(), "lein" );
            var nl = server.separator.line;
            var cmd = { };
            if ( server.separator.file == "/" ) {
                // *nix / Mac
                cmd = { cd = "cd", run = "sh", arg = script };
            } else {
                // Windows
                script &= ".bat";
                cmd = { cd = "chdir", run = script, arg = "" };
            }
            fileWrite( script,
                       "#cmd.cd# #project#" & nl &
                       "lein classpath" & nl );
            var classpath = "";
            // TODO: not sure if this is ACF-compatible...
            execute name="#cmd.run#" arguments="#cmd.arg#" variable="classpath" timeout="#timeout#";
            // could be multiple lines so clean it up:
            classpath = listLast( classpath, nl );
            classpath = replace( classpath, nl, "" );
            // turn the classpath into a URL list:
            var classpathParts = listToArray( classpath, server.separator.path );
            var urls = [ ];
            for ( var part in classpathParts ) {
                if ( !fileExists( part ) && !directoryExists( part ) ) {
                    try {
                        directoryCreate( part );
                    } catch ( any e ) {
                        // ignore and hope for the best - really!
                    }
                }
                if ( !part.endsWith( ".jar" ) && !part.endsWith( server.separator.file ) ) {
                    part &= server.separator.file;
                }
                // TODO: shortcut this...
                var file = createObject( "java", "java.io.File" ).init( part );
                arrayAppend( urls, file.toURI().toURL() );
            }
            // rebuild the classloader - not at all sketchy, honest!
            var threadProxy = createObject( "java", "java.lang.Thread" );
            var appCL = threadProxy.getContextClassLoader();
            var newCL = createObject( "java", "java.net.URLClassLoader" ).init(
                urls.toArray(), appCL
            );
            // hopefully this won't throw a security exception...
            threadProxy.currentThread().setContextClassLoader( newCL );
            var out = createObject( "java", "java.lang.System" ).out;
            try {
                var clj6 = newCL.loadClass( "clojure.java.api.Clojure" );
                out.println( "Detected Clojure 1.6 or later" );
                variables._clj_var  = clj6.getMethod( "var", __classes( "Object", 2 ) );
                variables._clj_read = clj6.getMethod( "read", __classes( "String" ) );
            } catch ( any e ) {
                var clj5 = newCL.loadClass( "clojure.lang." );
                out.println( "Falling back to Clojure 1.5 or earlier" );
                variables._clj_var  = clj5.getMethod( "var", __classes( "String", 2 ) );
                variables._clj_read = clj5.getMethod( "readString", __classes( "String" ) );
            }
            // auto-load clojure.core
            _install( "clojure.core" );
        } else if ( ns != "" ) {
            variables._clj_ns = ns;
        } else if ( !isSimpleValue( v ) ) {
            variables._clj_v = v;
        } else {
            throw "cfmljure requires the path of a Leiningen project.";
        }
        return this;
    }

    public any function install( string nsList ) {
        var nsArray = listToArray( nsList );
        for ( var ns in nsArray ) {
            _install( trim( ns ) );
        }
    }

    public any function keyword( string s ) {
        return this.clojure.core.keyword( s );
    }

    public any function read( string expr ) {
        var args = [ expr ];
        return variables._clj_read.invoke( javaCast( "null", 0 ), args.toArray() );
    }

    // helper functions:

    private any function __classes( string name, numeric n = 1 ) {
        var result = [ ];
        var type = createObject( "java", "java.lang." & name ).getClass();
        while ( n-- > 0 ) arrayAppend( result, type );
        return result.toArray();
    }

    private any function __install( array nsParts ) {
        var first = nsParts[ 1 ];
        var n = arrayLen( nsParts );
        if ( !structKeyExists( this, first ) ) {
            this[ first ] = duplicate( this ).init(
                ns = listAppend( variables._clj_ns, first, "." )
            );
        }
        if ( n > 1 ) {
            arrayDeleteAt( nsParts, 1 );
            this[ first ].__install( nsParts );
        }
    }

    private any function _call() {
        switch ( arrayLen( arguments ) ) {
        case 0:
            return variables._clj_v.invoke();
            break;
        case 1:
            return variables._clj_v.invoke( arguments[1] );
            break;
        case 2:
            return variables._clj_v.invoke( arguments[1], arguments[2] );
            break;
        case 3:
            return variables._clj_v.invoke( arguments[1], arguments[2], arguments[3] );
            break;
        case 4:
            return variables._clj_v.invoke( arguments[1], arguments[2], arguments[3],
                                            arguments[4] );
            break;
        case 5:
            return variables._clj_v.invoke( arguments[1], arguments[2], arguments[3],
                                            arguments[4], arguments[5] );
            break;
        case 6:
            return variables._clj_v.invoke( arguments[1], arguments[2], arguments[3],
                                            arguments[4], arguments[5], arguments[6] );
            break;
        case 7:
            return variables._clj_v.invoke( arguments[1], arguments[2], arguments[3],
                                            arguments[4], arguments[5], arguments[6],
                                            arguments[7] );
            break;
        case 8:
            return variables._clj_v.invoke( arguments[1], arguments[2], arguments[3],
                                            arguments[4], arguments[5], arguments[6],
                                            arguments[7], arguments[8] );
            break;
        case 9:
            return variables._clj_v.invoke( arguments[1], arguments[2], arguments[3],
                                            arguments[4], arguments[5], arguments[6],
                                            arguments[7], arguments[8], arguments[9] );
            break;
        case 10:
            return variables._clj_v.invoke( arguments[1], arguments[2], arguments[3],
                                            arguments[4], arguments[5], arguments[6],
                                            arguments[7], arguments[8], arguments[9],
                                            arguments[10] );
            break;
        case 11:
            return variables._clj_v.invoke( arguments[1], arguments[2], arguments[3],
                                            arguments[4], arguments[5], arguments[6],
                                            arguments[7], arguments[8], arguments[9],
                                            arguments[10], arguments[11]  );
            break;
        default:
            throw "cfmljure cannot call that method with that many arguments.";
            break;
        }
    }

    private any function _install( string ns ) {
        _require( ns );
        __install( listToArray( ns, "." ) );
    }

    private void function _require( string ns ) {
        if ( !structKeyExists( variables, "_clj_require" ) ) {
            variables._clj_require = _var( "clojure.core", "require" );
        }
        variables._clj_require.invoke( this.read( ns ) );
    }

    private any function _var( string ns, string name ) {
        var args = [ ns, name ];
        return variables._clj_var.invoke( javaCast( "null", 0 ), args.toArray() );
    }

    public any function onMissingMethod( string missingMethodName, any missingMethodArguments ) {
        if ( left( missingMethodName, 1 ) == "_" ) {
            missingMethodName = right( missingMethodName, len( missingMethod ) - 1 );
            if ( !structKeyExists( this, missingMethodName ) ) {
                this[ missingMethodName ] = duplicate( this ).init(
                    v = _var( variables._clj_ns, missingMethodName )
                );
            }
            return this[ missingMethod ];
        } else {
            if ( !structKeyExists( this, missingMethodName ) ) {
                this[ missingMethodName ] = duplicate( this ).init(
                    v = _var( variables._clj_ns, missingMethodName )
                );
            }
            return this[ missingMethodName ]._call( argumentCollection = missingMethodArguments );
        }
    }

}
