# Installation

To use cfmljure, you need the Clojure libraries. I think the easiest way to do that is with Leiningen, the Clojure build tool.

**Note: cfmljure.cfc requires Adobe ColdFusion 9.0.1 or Railo 3.1.2 BER build!**

## Installation with Leiningen

Copy the **clj/** folder from the cfmljure project to your server's classpath (or create a 
symbolic link). Install the **lein** script from http://github.com/technomancy/leiningen 
(download the **lein** script, make it executable, run **lein self-install** to complete 
the installation).

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

Copy the **clj/** folder from the cfmljure project to your server's classpath (or create a symbolic link).
Now go hit the cfmljure **index.cfm** file in your browser!

# Your Clojure Code

Your Clojure code also needs to be on your classpath. By default, cfmljure assumes there is a **clj/** folder on your class
path and all your Clojure code lives under that folder.

If you're working with Leiningen, your code will be organized into projects under the **clj/** folder. If you're
not using Leiningen, you can organize your files however you want but I think you're missing out...

# Understanding cfmljure.cfc

The API is pretty simple but there are some things about Clojure code organization which you might find non-intuitive.

## Basic (Low-Level) Usage

There are two examples supplied with **cfmljure**: a basic example which uses the low-level APIs to show how you can
work with Clojure inside a single page or component as an isolated usage. The APIs used in that example is explored
first so that you understand some of the *basics* of Clojure projects, files, namespaces and functions.

The advanced / automated example is explored below.

### Loading the Clojure runtime (RT)

The first thing you need to do is create an instance of **cfmljure.cfc** which loads the Clojure runtime system. If
you're working with Leiningen, tell cfmljure which project to load from:

	clj = new cfmljure( 'cfml' ); // load from the cfml project tree, the cfmljure examples project

Otherwise, omit the project argument and cfmljure will load files by their relative path. If you're working with a large,
multi-file project, you're probably using the **classpathonly** option and will not be using a project name. See below.

### Clojure Script Files

The convention is that the relative path name of your Clojure script should match the namespace it declares -
just like Java, and just like the dotted-path you're already used to in CFML. In the **cfml/** project folder, under the
**src/cfml/** folder, we have **examples.clj** and it declares that it's contents live in the **cfml.examples**
namespace. Namespaces are used for packaging code and importing functions between files.

You load Clojure files into the runtime with the **load()** method which takes a list of script names, relative to
the project folder (if specified - otherwise relative to the **clj/** folder - except when using **classpathonly** mode,
see below). **cfmljure** automatically appends **.clj** to each file. If you have subfolders, you can just put the paths in the list:

	clj.load( 'main,account/info,acccount/admin' )

This will load **clj/{project}/src/main.clj**, **clj/{project}/src/account/info.clj** and **clj/{project}/src/account/admin.clj**
if you specified a project, **clj/main.clj**, **clj/account/info.clj** and **clj/account/admin.clj** if you did not.

This makes it easy to work with Leiningen projects as well as ad hoc code organization. Again, see **classpathonly** below.

### Clojure Functions

Once your scripts are loaded, you can get direct references to them by calling the **get()** method which takes a string
specifying the namespace qualified name of the function. In the example **index.cfm**, you'll see:

	greet = clj.get( 'cfml.examples.greet' );
	map = clj.get( 'clojure.core.map' );

The first line gets a reference to the **greet** function from the **cfml.examples** namespace.
The second line gets a reference to the built-in **map** function from the **clojure.core** namespace.

### Calling Clojure (via function references)

You use the **call()** method to invoke Clojure functions and you pass positional arguments.
Currently, up to five arguments are supported. See the next section for a cleaner way to call functions in namespaces.

### Clojure Namespaces

As indicated under **Clojure Functions** above, functions live in namespaces and whilst you can get direct
references to individual functions and call them, it may actually be easier to get references to the namespaces
themselves so that can call functions *directly* (well, actually via the magic of **onMissingMethod()**). You
can get a reference to a namespace like this:

	cfml.examples = clj.ns( 'cfml.examples' );
	clojure.core = clj.ns( 'clojure.core' );

You don't have to store the namespace references into variables that match the same structure but it makes for
clearer CFML code in my opinion.

Note: these aren't really references to the Clojure namespaces - they are new instances of the **cfmljure.cfc**
initialized with the namespace so that method calls via **onMissingMethod()** can work!

### Calling Clojure (via namespace references)

Once you have a namespace reference, you can call any function in that namespace directly. Behind the scenes,
**onMissingMethod()** delegates the call to the **call()** API but it lets you do things like:

	list = cfml.examples.twice( [ 1, 2, 3 ] );

Note: that means you can't call certain functions using this approach. Any function name that matches an API
method in **cfmljure.cfc** cannot be called via a namespace reference (because **onMissingMethod()** is not
called in that situation). Those function names are: **call**, **get**, **init**, **install**, **load**, **ns**
(and a few *special* methods that I wouldn't expect to collide with Clojure functions: **\_**, **\_def**, **\_makePath**
and **onMissingMethod**).

## Advanced (Integrated) Usage

There's one API method we haven't discussed so far: **install()**

After reading all the low-level API usage, you're probably wondering if there's an easier way to use Clojure from
CFML without having to call all of the low-level API and the answer is... of course!

The third example in the *basic* **index.cfm** shows how **cfmljure** allows you to write a simple configuration
structure and then *install* Clojure into a designated scope or struct. The *advanced* **Application.cfc** takes
this a little further by taking a simple configuration structure like this:

	config = {
		project = 'cfml',
		ns = 'cfml.examples, clojure.core'
	};

and via the **install()** method it creates the necessary instance(s) of **cfmljure.cfc** and places that into a
target scope (or struct) along with creating structured variables that match the specified namespaces.

Given the above **config** structure, the **install()** API creates an instance of **cfmljure.cfc** for the 'cfml'
project, loads the 'cfml/examples' script (i.e., 'clj/cfml/src/cfml/examples.clj') and creates variables **cfml.examples**
and **clojure.core** in the target scope (or struct). In addition **clj** is added to that scope (or struct) holding the
configured instance of **cfmljure.cfc**. The *advanced* example uses the **Application.cfc** **variables** scope as the
target so all pages in the application can access the namespaces and call functions in an idiomatic way:

	list = cfml.examples.twice( [ 1, 2, 3 ] );

### Namespaces and Files

By default, the **install()** API loads files based on their namespace, automatically ignoring **clojure.\*** namespaces. In
the supplied example, that means it loads 'cfml/examples' (i.e., **clj/cfml/src/cfml/examples.clj**). You can, if you wish,
specify an explicit list of **files** to load instead of relying on the conventions. The **config** above is equivalent to:

	config = {
		project = 'cfml',
		files = 'cfml/examples',
		ns = 'cfml.examples, clojure.core'
	};

Specifying **files =** overrides the convention for loading files by namespace and can be useful if you want to load,
and install, ad hoc files instead of using namespaces.

## Original Clojure Function Or Variable References

You'll need this when you want to pass a Clojure function to another Clojure function,
such as the **map()** examplea that passes a reference to **times2** into the call, or you
want to manipulate an entity declared as a variable in Clojure, such as the **cfml.examples.x** examples.

If you used **get()** to obtain a reference to a Clojure function or variable, you can get the underlying raw Clojure function or 
variable via the **.\_()** API. Calling **_reference_.\_()** will return the underlying Clojure entity.

If you have a reference to a namespace, you also can get an underlying Clojure entity by name via the **\_()** API. Calling
**_namespace_.\_( _name_ )** is identical to calling **_namespace_.get( _name_ ).\_()** so this is the more convenient API when you're
working with namespaces or an installed Clojure configuration.

## classpathonly Mode

All of the above works fairly well when you're dealing with small projects and only a few files. Once you start to have more
complex dependencies across multiple files, it begins to break down because the Clojure runtime (RT) only searches your
classpath for files that are *use*d in **ns** declarations.

**cfmljure** provides a mode that supports this better but you need to manage your class path more explicitly for your
JEE / Servlet container. If you instantiate **cfmljure** like this:

	clj = new cfmljure( classpathonly = true );

then you should not use a project name and all files will be loaded relative to the classpath *without the **clj/** directory prefix*.

In this situation, you'll need to add several paths to your JEE / Servlet container's classpath for Clojure to be able
to load files correctly:

	{project}/lib
	{project}/lib/*.jar
	{project}/src

With those three additions to your classpath, **cfmljure** will be able to find and load both compiled and source Clojure files,
libraries and additional resources such as property files.

For Tomcat, the easiest way to do this is to edit **common.loader** in the **{tomcat}/conf/catalina.properties** file.
Consult your server's documentation for more details.