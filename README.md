# Installation

To use cfmljure, you need the Clojure libraries. I think the easiest way to do that is with Leiningen, the Clojure build tool.

**Note: cfmljure.cfc requires Adobe ColdFusion 9.0.1 or Railo 3.1.2 BER build!**

## Installation with Leiningen

Copy the **clj/** folder from the cfmljure project to your server's classpath. Install the
**lein** script from http://github.com/technomancy/leiningen (download the **lein** script, make
it executable, run **lein self-install** to complete the installation).

Run the **cfmljure** tests:

	lein clean, deps, test

You should see (with a different file path, I expect):

	Cleaning up.
	Copying 2 files to /Developer/tomcat-ws/lib/clj/cfml/lib
	Testing cfml.test.examples
	Ran 7 tests containing 7 assertions.
	0 failures, 0 errors.

Now you can copy the two Clojure JARs from the **clj/cfml/lib/** folder to your server's classpath
and restart your CFML engine. Now go hit the cfmljure **index.cfm** file in your browser!

## Installation without Leiningen

If you really don't want to mess with Leiningen, you can install Clojure manually. However, without Leiningen
you're not going to be able to run the tests and build JAR files etc so I strongly recommend the first installation
approach above.

Download the Clojure libraries from here: http://clojure.org/downloads

Download both Clojure and Clojure Contrib and unzip them. Copy **clojure.jar** (from the clojure-1.2.0.zip)
and **clojure-contrib-1.2.0.jar** (from the target subfolder of clojure-contrib-1.2.0.zip) to your classpath.
I put them in **{tomcat}/lib** - and restart your CFML engine. You can ignore the rest of those ZIP files.

Copy the **clj/** folder from the cfmljure project to your server's classpath. Now go hit the cfmljure **index.cfm**
file in your browser!

# Your Clojure Code

Your Clojure code also needs to be on your classpath. cfmljure assumes there is a **clj/** folder on your class
path and all your Clojure code lives under that folder.

If you're working with Leiningen, your code will be organized into projects under the **clj/** folder. If you're
not using Leiningen, you can organize your files however you want but I think you're missing out...

# Understanding cfmljure.cfc

The API is pretty simple but there are some things about Clojure code organization which you might find non-intuitive.

## Loading the Clojure runtime (RT)

The first thing you need to do is create an instance of **cfmljure.cfc** which loads the Clojure runtime system. If
you're working with Leiningen, tell cfmljure which project to load from:

	clj = new cfmljure( 'cfml' ); // load from the cfml project tree, the cfmljure examples project

Otherwise, omit the project argument and cfmljure will load files by their relative path.

## Clojure Script Files

First off, the filename is unrelated to the contents of the file. So in the **cfml/** project folder, under the
**src/cfml/** folder, we have **examples.clj** and it declares that it's contents live in the **cfml.examples**
namespace - but it could be anything you want. A reasonable convention for the namespace is to follow the folder
path. Namespaces are used for packaging code and importing functions between files.

You load Clojure files into the runtime with the **load()** method which takes a list of script names, relative to
the project folder (if specified - otherwise relative to the **clj/** folder). cfmljure automatically appends
**.clj** to each file. If you have subfolders, you can just put the paths in the list:

	clj.load( 'main,account/info,acccount/admin' )

This will load **clj/{project}/src/main.clj**, **clj/{project}/src/account/info.clj** and **clj/{project}/src/account/admin.clj**
if you specified a project, **clj/main.clj**, **clj/account/info.clj** and **clj/account/admin.clj** if you did not.

This makes it easy to work with Leiningen projects as well as ad hoc code organization.

## Clojure Functions

Once your scripts are loaded, you can get references to them by calling the **get()** method which takes a string
specifying the namespace qualified name of the function. In the example **index.cfm**, you'll see:

	greet = clj.get( 'cfml.examples.greet' );
	map = clj.get( 'clojure.core.map' );

The first line gets a reference to the **greet** function from the **cfml.examples** namespace.
The second line gets a reference to the built-in **map** function from the **clojure.core** namespace.

## Calling Clojure

You use the **call()** method to invoke Clojure functions and you pass positional arguments.
Currently, up to five arguments are supported.
