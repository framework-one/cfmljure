;; examples.clj
;; provides a number of example Clojure functions
(ns cfml.examples)

(def x '(1 2 3 4))

;; takes a string, returns a string
(defn greet [who]
	(str "Hello " who "!"))

;; #(* 2 %) is a function literal equivalent to (fn [x] (* 2 x))
;; the equivalent defn form would be: (defn times-2 [n] (* 2 n))
(def times-2 #(* 2 %))

;; takes a sequence, returns a sequence by applying times-2 to each element
(defn twice [coll]
	(map times-2 coll))
