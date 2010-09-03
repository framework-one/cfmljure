# Installation

You need to download the Clojure libraries and place them on your classpath. You can find the Clojure libraries here: http://clojure.org/downloads

Download Clojure and Clojure Contrib and unzip them. Copy **clojure.jar** (from the clojure-1.2.0.zip) and **clojure-contrib-1.2.0.jar** (from the target subfolder of clojure-contrib-1.2.0.zip) to your classpath - I put them in **{tomcat}/lib** - and restart your CFML engine.

**Note: cfmljure.cfc requires Adobe ColdFusion 9.0.1 or Railo 3.1.2 BER build!**

# Your Clojure Code

Your Clojure code also needs to be on your classpath. cfmljure assumes there is a **clj/** folder on your class path and all your Clojure code lives in that folder. Therefore, to run the example, you need to copy the **clj/** folder (containing **examples.clj** etc) to the same place you put the JAR files.

Now you should be able to hit **index.cfm** in a browser and you'll see some functions being executed.

# Understanding cfmljure.cfc

The API is pretty simple but there are some things about Clojure code organization which you might find non-intuitive.

## Clojure Script Files

First off, the filename is unrelated to the contents of the file. So we have examples.clj and it declares that it's contents live in the cfmljure.examples namespace but it could be anything you want.

You create an instance of the cfmljure CFC which creates the Clojure runtime and then you load Clojure files into the runtime with the **load()** method which takes a list of script names. cfmljure automatically appends **.clj** for you, as well as prepending **clj/** (the folder in your classpath). If you have subfolders, you can just put the paths in the list:

	clj.load( 'main,account/info,acccount/admin' )

This will load **clj/main.clj**, **clj/account/info.clj** and **clj/account/admin.clj**.

## Clojure Functions

Once your scripts are loaded, you can get references to them by calling the **get()** method which takes a string specifying the namespace qualified name of the function. In the example **index.cfm**, you'll see:

	greet = clj.get( 'cfmljure.examples.greet' );
	map = clj.get( 'clojure.core.map' );

The first line gets a reference to the **greet** function from the **cfmljure.examples** namespace. The second line gets a reference to the built-in **map** function from the **clojure.core** namespace.

## Calling Clojure

You use the **call()** method to invoke Clojure functions and you pass positional arguments. Currently, up to five arguments are supported.
