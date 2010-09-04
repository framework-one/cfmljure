;; examples.clj
;; provides a number of example Clojure functions
(ns cfml.examples)

;; takes a string, returns a string
(defn greet [who]
	(str "Hello " who "!"))

;; #(* 2 %) is a function literal equivalent to (fn [x] (* 2 x))
;; the equivalent defn form would be: (defn times2 [n] (* 2 n))
(def times2 #(* 2 %))

;; takes a sequence, returns a sequence by applying times2 to each element
(defn twice [coll]
	(map times2 coll))
