# Clojure and CFML Sitting in a tree

cfmljure is a utility that lets you easily call Clojure code from CFML!

It works by leveraging Leiningen to obtain the classpath for a Clojure project that you want to load into
your CFML project. The examples provided use two Clojure projects in the `clj` folder. One is very basic
Clojure code that is loaded and run directly in the `index.cfm` page, the other loads the Clojure code
at application startup and makes that code available in the `variables` scope of each page of the example.

## Installation (with Leiningen)

Install the **lein** script from http://github.com/technomancy/leiningen 
(download the **lein** script, make it executable, run **lein self-install** to complete 
the installation). If you're on Windows, use the Windows installer for Leiningen.

**Note: cfmljure expects the `lein` command to be on the path used by `cfexecute` inside your CFML engine!**

### Verifying Leiningen / Clojure

In each of the projects, `clj/cfml` and `clj/tasks`, you should be able to run the tests with Leiningen:

    lein test

In `clj/cfml` you should see:

    lein test cfml.test.examples
    
    Ran 7 tests containing 7 assertions.
    0 failures, 0 errors.

In `clj/task` you should see:

    lein test task.test.core
    
    lein test task.test.create
    
    Ran 4 tests containing 14 assertions.
    0 failures, 0 errors.

The first time you run `lein test` you may see all sorts of stuff being downloaded from Maven Central. Do not panic! This is how Leiningen (Clojure's build tool) manages dependencies automatically for you.

### Running the CFML/Clojure examples

Assuming you deployed `cfmljure` (via cloning from Github or unzipping a release) to a folder within a CFML webroot somewhere, you should be able to navigate your browser to the cfmljure home page, e.g.,

    http://localhost:8080/cfmljure/

This will take a few seconds the first time but should then show the output of the **Basic Examples**. You can click through to the more advanced **Task** example which uses Clojure for all the business logic, including reading and writing to a Derby database!

## Using Your Own Clojure Code

Create a new project somewhere with Leiningen:

    lein new mystuff

That will create a complete Clojure project with a `mystuff.core` namespace containing a `foo` function that accepts a string argument and prints a message (to the console of your CFML engine).

Now create a CFML page containing:

    <cfset clj = new cfmljure("/path/to/project/mystuff") />
    <cfset clj.install("mystuff.core",variables) />
    <cfset mystuff.core.foo("From CFML") />
    Done!

And now hit that page in your browser - it should say `Done!` in your browser and if you look in your CFML engine's console you should see:

    Detected Clojure 1.6 or later
    From CFML Hello, World!

The first line is cfmljure telling you whether it found a recent version of Clojure or an older one (Clojure 1.6 introduced a new, improved way to embed Clojure into an application).

The second line was printed by the Clojure code in that `core.clj` example!

### Installing Namespaces

CFML can only "see" the Clojure code in the namespaces you specify in `install()`. This allows you to organize your Clojure code however you want and only expose a specific API to your CFML code.

You can expose any of the namespaces in your Clojure project, including those from third party libraries specified as dependencies in your `project.clj` file. It's often convenient to install `clojure.core` as it provides a lot of useful functions!

## Using Clojure Functions

As you can see above, you can call any (public) function in a Clojure namespace just by using the dotted path to it. CFML strings work as Clojure strings, CFML numbers are Clojure floating point (double) values - on Lucee and Railo at least, on ColdFusion they're still strings... duh! You can pass CFML arrays and structs to Clojure and they can be treated as sequences and hashmaps (with "UPPERCASE" string keys) respectively. If Clojure passes back a vector or list, CFML can treat it like an array (in most cases). If Clojure passes back a traditional hashmap, it will usually have keywords as keys. You can make a keyword from a string by calling `clojure.core.keyword("str")` which produces `:str` in Clojure terms - a keyword. You will often need to use Clojure functions to get stuff out of hashmaps if they use keywords:

    <cfset v = clojure.core.get( cljMap, clojure.core.keyword( "k" ) ) />

That returns the `:k` key value from `cljMap` or null if there's no such key.

Sometimes, instead of calling a function, you want to get a reference to it. For example, here's Clojure code that increments every element of a list:

    (map inc [1 2 3 4])

To do that from CFML, you would need this code:

    <cfset vs = clojure.core.map( clojure.core._inc(), [1, 2, 3, 4] ) />

The `_inc()` call returns a reference to `inc`. In general `name.space._func()` will return a reference to the `func` function in the specified `name.space` namespace, so that you can pass it to other functions.
